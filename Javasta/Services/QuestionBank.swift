import Foundation

struct ExplanationAuditReport {
    let quizCount: Int
    let authoredExplanationCount: Int
    let placeholderCount: Int
    let missingCount: Int
    let duplicateRefCount: Int
    let orphanedCount: Int
    let issues: [ExplanationAuditIssue]

    var needsAttentionCount: Int {
        placeholderCount + missingCount + duplicateRefCount + orphanedCount
    }
}

struct ExplanationAuditIssue: Identifiable {
    enum Kind: String {
        case placeholder
        case missing
        case duplicateRef
        case orphaned
    }

    let kind: Kind
    let quizId: String?
    let explanationRef: String
    let level: JavaLevel?
    let category: String?
    let question: String?
    let detail: String

    var id: String {
        "\(kind.rawValue)-\(quizId ?? "no-quiz")-\(explanationRef)"
    }
}

enum QuestionBank {
    static var allQuizzes: [Quiz] { Quiz.samples }
    static var lessons: [Lesson] { Lesson.samples }

    static func quiz(id: String) -> Quiz? {
        allQuizzes.first { $0.id == id }
    }

    static func quizzes(
        version: JavaExamVersion = .se17,
        level: JavaLevel? = nil,
        category: QuizCategory? = nil
    ) -> [Quiz] {
        self.allQuizzes.filter { quiz in
            quiz.examVersion == version &&
            (level == nil || quiz.level == level) &&
            (category == nil || quiz.category == category?.rawValue)
        }
    }

    static func makeSession(
        mode: QuizPracticeMode,
        version: JavaExamVersion,
        level: JavaLevel,
        progress: ProgressStore
    ) -> QuizSession? {
        let pool = quizzes(version: version, level: level)
        guard !pool.isEmpty else { return nil }

        let selected: [Quiz]
        switch mode {
        case .single:
            selected = Array(pool.prefix(1))
        case .daily:
            selected = Array(pool.shuffled().prefix(min(mode.limit, pool.count)))
        case .weak:
            selected = weak(pool, progress: progress, limit: mode.limit)
        case .mistakes:
            selected = mistakes(pool, progress: progress, limit: mode.limit)
        case .unattempted:
            selected = unattempted(pool, progress: progress, limit: mode.limit)
        case .mockExam:
            selected = Array(pool.shuffled().prefix(min(mode.limit, pool.count)))
        }

        let fallback = balanced(pool, limit: mode.limit)
        let quizzes = selected.isEmpty ? fallback : selected
        return QuizSession(mode: mode, level: level, version: version, quizzes: quizzes)
    }

    static func coverage(version: JavaExamVersion, level: JavaLevel) -> [(objective: ExamObjective, count: Int)] {
        ExamObjectiveCatalog.objectives(for: version, level: level).map { objective in
            let categories = coverageCategories(for: objective.category)
            let count = quizzes(version: version, level: level)
                .filter { quiz in
                    guard let category = QuizCategory(rawValue: quiz.category) else { return false }
                    return categories.contains(category)
                }
                .count
            return (objective, count)
        }
    }

    static func validationIssues() -> [String] {
        var issues: [String] = []
        let ids = allQuizzes.map(\.id)
        let duplicateIds = Dictionary(grouping: ids, by: { $0 }).filter { $0.value.count > 1 }.keys
        for id in duplicateIds {
            issues.append("Duplicate quiz id: \(id)")
        }

        let explanationIds = Set(Explanation.allSampleIds)
        for quiz in allQuizzes {
            if Explanation.sample(for: quiz.explanationRef) == nil {
                issues.append("\(quiz.id): unresolved explanation \(quiz.explanationRef)")
            }
            let correctCount = quiz.choices.filter(\.correct).count
            if quiz.isMultipleSelect {
                if correctCount < 2 {
                    issues.append("\(quiz.id): multiple-select needs at least two correct choices")
                }
            } else if correctCount != 1 {
                issues.append("\(quiz.id): single-select needs exactly one correct choice")
            }
            if QuizCategory(rawValue: quiz.category) == nil {
                issues.append("\(quiz.id): unknown category \(quiz.category)")
            }
        }

        let explanationRefs = allQuizzes.map(\.explanationRef)
        let duplicateExplanationRefs = Dictionary(grouping: explanationRefs, by: { $0 })
            .filter { $0.value.count > 1 }
            .keys
        for ref in duplicateExplanationRefs {
            issues.append("Duplicate explanation ref: \(ref)")
        }

        for ref in explanationIds.subtracting(Set(explanationRefs)) {
            issues.append("Authored explanation is not linked from any quiz: \(ref)")
        }

        for lesson in lessons {
            for id in lesson.relatedQuizIds where quiz(id: id) == nil {
                issues.append("\(lesson.id): missing related quiz \(id)")
            }
        }

        return issues
    }

    static func explanationAuditReport() -> ExplanationAuditReport {
        let quizzes = allQuizzes
        let authoredRefs = Explanation.authoredSampleIds
        let quizRefs = quizzes.map(\.explanationRef)
        let quizRefSet = Set(quizRefs)
        let duplicateRefs = Set(
            Dictionary(grouping: quizRefs, by: { $0 })
                .filter { $0.value.count > 1 }
                .keys
        )

        var issues: [ExplanationAuditIssue] = []

        for quiz in quizzes.sorted(by: { $0.id < $1.id }) {
            if duplicateRefs.contains(quiz.explanationRef) {
                issues.append(
                    ExplanationAuditIssue(
                        kind: .duplicateRef,
                        quizId: quiz.id,
                        explanationRef: quiz.explanationRef,
                        level: quiz.level,
                        category: quiz.categoryDisplayName,
                        question: quiz.question,
                        detail: "複数の問題が同じexplanationRefを共有しています。問題ごとに固有のrefへ分ける必要があります。"
                    )
                )
            }

            if Explanation.sample(for: quiz.explanationRef) == nil {
                issues.append(
                    ExplanationAuditIssue(
                        kind: .missing,
                        quizId: quiz.id,
                        explanationRef: quiz.explanationRef,
                        level: quiz.level,
                        category: quiz.categoryDisplayName,
                        question: quiz.question,
                        detail: "Explanation.sample(for:)で解決できません。refの打ち間違いか、問題がsamples未登録の可能性があります。"
                    )
                )
            } else if !authoredRefs.contains(quiz.explanationRef) {
                issues.append(
                    ExplanationAuditIssue(
                        kind: .placeholder,
                        quizId: quiz.id,
                        explanationRef: quiz.explanationRef,
                        level: quiz.level,
                        category: quiz.categoryDisplayName,
                        question: quiz.question,
                        detail: "手書き解説がないため、quickTraceの汎用3ステップ解説にフォールバックしています。"
                    )
                )
            }
        }

        for ref in authoredRefs.subtracting(quizRefSet).sorted() {
            issues.append(
                ExplanationAuditIssue(
                    kind: .orphaned,
                    quizId: nil,
                    explanationRef: ref,
                    level: nil,
                    category: nil,
                    question: nil,
                    detail: "手書き解説は存在しますが、このrefを使っている問題がありません。samples登録漏れか、ref変更漏れを確認してください。"
                )
            )
        }

        return ExplanationAuditReport(
            quizCount: quizzes.count,
            authoredExplanationCount: quizzes.filter { authoredRefs.contains($0.explanationRef) }.count,
            placeholderCount: issues.filter { $0.kind == .placeholder }.count,
            missingCount: issues.filter { $0.kind == .missing }.count,
            duplicateRefCount: issues.filter { $0.kind == .duplicateRef }.count,
            orphanedCount: issues.filter { $0.kind == .orphaned }.count,
            issues: issues
        )
    }

    private static func balanced(_ pool: [Quiz], limit: Int) -> [Quiz] {
        let grouped = Dictionary(grouping: pool) { $0.category }
        let orderedGroups = grouped.keys.sorted()
        var result: [Quiz] = []
        var cursors = Dictionary(uniqueKeysWithValues: orderedGroups.map { ($0, 0) })
        let sortedGroups = grouped.mapValues { $0.sorted { $0.id < $1.id } }

        while result.count < min(limit, pool.count) {
            var addedThisRound = false
            for category in orderedGroups {
                guard
                    let items = sortedGroups[category],
                    let cursor = cursors[category],
                    cursor < items.count
                else { continue }
                result.append(items[cursor])
                cursors[category] = cursor + 1
                addedThisRound = true
                if result.count >= min(limit, pool.count) { break }
            }
            if !addedThisRound { break }
        }

        return result
    }

    private static func weak(_ pool: [Quiz], progress: ProgressStore, limit: Int) -> [Quiz] {
        let weakTags = progress.weakTags(limit: 8).map(\.tag)
        guard !weakTags.isEmpty else {
            return mistakes(pool, progress: progress, limit: limit)
        }
        return pool
            .filter { quiz in quiz.tags.contains(where: weakTags.contains) }
            .sorted { lhs, rhs in
                let l = progress.stats(for: lhs.id)
                let r = progress.stats(for: rhs.id)
                if l.accuracy == r.accuracy { return lhs.id < rhs.id }
                return l.accuracy < r.accuracy
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func mistakes(_ pool: [Quiz], progress: ProgressStore, limit: Int) -> [Quiz] {
        pool
            .filter { progress.stats(for: $0.id).needsReview }
            .sorted { lhs, rhs in
                let lDate = progress.stats(for: lhs.id).latest?.answeredAt ?? .distantPast
                let rDate = progress.stats(for: rhs.id).latest?.answeredAt ?? .distantPast
                return lDate < rDate
            }
            .prefix(limit)
            .map { $0 }
    }

    private static func unattempted(_ pool: [Quiz], progress: ProgressStore, limit: Int) -> [Quiz] {
        pool
            .filter { !progress.stats(for: $0.id).isAnswered }
            .sorted { $0.id < $1.id }
            .prefix(limit)
            .map { $0 }
    }

    private static func coverageCategories(for category: QuizCategory) -> Set<QuizCategory> {
        switch category {
        case .dataTypes:
            return [.dataTypes, .string]
        case .classes:
            return [.classes, .overloadResolution]
        case .collections:
            return [.collections, .generics]
        case .lambdaStreams:
            return [.lambdaStreams, .optionalApi]
        default:
            return [category]
        }
    }
}
