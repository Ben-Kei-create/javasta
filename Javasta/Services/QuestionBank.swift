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

struct QuestionCategoryDistribution: Identifiable {
    let level: JavaLevel
    let category: QuizCategory
    let practiceCount: Int
    let mockOnlyCount: Int

    var id: String {
        "\(level.rawValue)-\(category.rawValue)"
    }

    var totalCount: Int {
        practiceCount + mockOnlyCount
    }
}

struct ContentQualityIssue: Identifiable {
    enum Kind: String {
        case duplicateDesignIntent
        case duplicateCode
        case repeatedQuestionStem
        case repeatedChoiceSet
        case repeatedExplanationNarration
    }

    let kind: Kind
    let title: String
    let quizIds: [String]
    let detail: String

    var id: String {
        "\(kind.rawValue)-\(quizIds.joined(separator: "-"))-\(title)"
    }
}

enum QuestionBank {
    static var practiceQuizzes: [Quiz] { Quiz.samples.filter { !$0.isMockExamOnly } }
    static var mockExamOnlyQuizzes: [Quiz] { QuizExpansion.mockExamOnlyExpansion.map { $0.contextualizedForPresentation() } }
    static var allQuizzes: [Quiz] {
        deduplicated(Quiz.samples + mockExamOnlyQuizzes)
    }
    static var lessons: [Lesson] { Lesson.samples }

    static func quiz(id: String) -> Quiz? {
        allQuizzes.first { $0.id == id }
    }

    static func quizzes(
        version: JavaExamVersion = .se17,
        level: JavaLevel? = nil,
        category: QuizCategory? = nil
    ) -> [Quiz] {
        self.practiceQuizzes.filter { quiz in
            quiz.examVersion == version &&
            (level == nil || quiz.level == level) &&
            (category == nil || quiz.canonicalCategory == category)
        }
    }

    static func mockExamEligibleCount(version: JavaExamVersion, level: JavaLevel) -> Int {
        mockExamPool(version: version, level: level).count
    }

    static func makeSession(
        mode: QuizPracticeMode,
        version: JavaExamVersion,
        level: JavaLevel,
        progress: ProgressStore
    ) -> QuizSession? {
        if mode == .mockExam {
            return makeMockExamSession(variant: .full, version: version, level: level)
        }

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
            return nil
        }

        let fallback = balanced(pool, limit: mode.limit)
        let quizzes = selected.isEmpty ? fallback : selected
        return QuizSession(mode: mode, level: level, version: version, quizzes: quizzes)
    }

    static func makeMockExamSession(
        variant: MockExamVariant,
        version: JavaExamVersion,
        level: JavaLevel
    ) -> QuizSession? {
        let pool = mockExamPool(version: version, level: level)
        guard !pool.isEmpty else { return nil }

        let spec = MockExamSpec.official(version: version, level: level)
        let limit = min(spec.questionCount(for: variant), pool.count)
        let selected = mixedMockExamSelection(
            practicePool: quizzes(version: version, level: level),
            exclusivePool: mockExamOnlyQuizzes.filter { $0.examVersion == version && $0.level == level },
            limit: limit
        )

        return QuizSession(
            mode: .mockExam,
            level: level,
            version: version,
            quizzes: selected,
            customTitle: variant.displayName,
            mockExamVariant: variant
        )
    }

    static func coverage(version: JavaExamVersion, level: JavaLevel) -> [(objective: ExamObjective, count: Int)] {
        ExamObjectiveCatalog.objectives(for: version, level: level).map { objective in
            let categories = coverageCategories(for: objective.category)
            let count = quizzes(version: version, level: level)
                .filter { quiz in
                    guard let category = quiz.canonicalCategory else { return false }
                    return categories.contains(category)
                }
                .count
            return (objective, count)
        }
    }

    static func categoryDistribution(
        version: JavaExamVersion = .se17,
        level: JavaLevel
    ) -> [QuestionCategoryDistribution] {
        let practice = quizzes(version: version, level: level)
        let mockOnly = mockExamOnlyQuizzes.filter { $0.examVersion == version && $0.level == level }
        let categories = Set((practice + mockOnly).compactMap(\.canonicalCategory))

        return categories
            .map { category in
                QuestionCategoryDistribution(
                    level: level,
                    category: category,
                    practiceCount: practice.filter { $0.canonicalCategory == category }.count,
                    mockOnlyCount: mockOnly.filter { $0.canonicalCategory == category }.count
                )
            }
            .sorted { lhs, rhs in
                if lhs.category.displayName == rhs.category.displayName {
                    return lhs.totalCount > rhs.totalCount
                }
                return lhs.category.displayName < rhs.category.displayName
            }
    }

    static func contentBalanceIssues(
        version: JavaExamVersion = .se17,
        level: JavaLevel,
        minimumPracticeCount: Int = 5
    ) -> [String] {
        categoryDistribution(version: version, level: level).compactMap { bucket in
            guard bucket.practiceCount > 0 && bucket.practiceCount < minimumPracticeCount else { return nil }
            return "\(level.displayName) \(bucket.category.displayName): practice \(bucket.practiceCount), mock-only \(bucket.mockOnlyCount)"
        }
    }

    static func contentQualityIssues() -> [ContentQualityIssue] {
        var issues: [ContentQualityIssue] = []
        let quizzes = allQuizzes

        issues.append(
            contentsOf: duplicateQuizGroups(
                kind: .duplicateDesignIntent,
                title: "designIntentが同一",
                minimumCount: 2,
                quizzes: quizzes,
                key: { normalizedContentKey($0.designIntent) },
                detail: { key, ids in
                    "同じ狙いの問題が\(ids.count)件あります。意図が同じでも、片方は問う観点やコードをずらす候補です: \(key)"
                }
            )
        )

        issues.append(
            contentsOf: duplicateQuizGroups(
                kind: .duplicateCode,
                title: "コードが同一",
                minimumCount: 2,
                quizzes: quizzes,
                key: { normalizedContentKey($0.code) },
                detail: { key, ids in
                    "同じコードを使う問題が\(ids.count)件あります。通常問題と模試専用で丸かぶりしていないか確認します: \(String(key.prefix(120)))"
                }
            )
        )

        issues.append(
            contentsOf: duplicateQuizGroups(
                kind: .repeatedQuestionStem,
                title: "問題文の言い回しが多用",
                minimumCount: 10,
                quizzes: quizzes,
                key: { normalizedContentKey($0.question) },
                detail: { key, ids in
                    "同じ問題文が\(ids.count)件あります。出題の見え方が単調になるため、対象APIや判断ポイントを入れた文へ分散します: \(key)"
                }
            )
        )

        issues.append(
            contentsOf: duplicateQuizGroups(
                kind: .repeatedChoiceSet,
                title: "選択肢セットが多用",
                minimumCount: 8,
                quizzes: quizzes,
                key: { quiz in
                    quiz.choices
                        .map { normalizedContentKey($0.text) }
                        .sorted()
                        .joined(separator: " | ")
                },
                detail: { key, ids in
                    "同じ選択肢セットが\(ids.count)件あります。正誤だけで解ける癖を避けるため、近い誤答を問題ごとに調整します: \(key)"
                }
            )
        )

        issues.append(contentsOf: repeatedNarrationIssues(quizzes: quizzes))
        return issues.sorted { lhs, rhs in
            if lhs.kind.rawValue == rhs.kind.rawValue {
                return lhs.quizIds.count > rhs.quizIds.count
            }
            return lhs.kind.rawValue < rhs.kind.rawValue
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
            if quiz.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("Quiz id must not be empty")
            }
            if quiz.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("\(quiz.id): question must not be empty")
            }
            if quiz.choices.isEmpty {
                issues.append("\(quiz.id): choices must not be empty")
            }
            if quiz.estimatedSeconds <= 0 {
                issues.append("\(quiz.id): estimatedSeconds must be positive")
            }
            let choiceIds = quiz.choices.map(\.id)
            let duplicateChoiceIds = Dictionary(grouping: choiceIds, by: { $0 })
                .filter { $0.value.count > 1 }
                .keys
            for choiceId in duplicateChoiceIds {
                issues.append("\(quiz.id): duplicate choice id \(choiceId)")
            }
            let correctCount = quiz.choices.filter(\.correct).count
            if quiz.isMultipleSelect {
                if correctCount < 2 {
                    issues.append("\(quiz.id): multiple-select needs at least two correct choices")
                }
            } else if correctCount != 1 {
                issues.append("\(quiz.id): single-select needs exactly one correct choice")
            }
            if quiz.canonicalCategory == nil {
                issues.append("\(quiz.id): unknown category \(quiz.category)")
            }
            if let codeTabs = quiz.codeTabs {
                let tabIds = codeTabs.map(\.id)
                let duplicateTabIds = Dictionary(grouping: tabIds, by: { $0 })
                    .filter { $0.value.count > 1 }
                    .keys
                for tabId in duplicateTabIds {
                    issues.append("\(quiz.id): duplicate code tab id \(tabId)")
                }
                let filenames = codeTabs.map(\.filename)
                let duplicateFilenames = Dictionary(grouping: filenames, by: { $0 })
                    .filter { $0.value.count > 1 }
                    .keys
                for filename in duplicateFilenames {
                    issues.append("\(quiz.id): duplicate code tab filename \(filename)")
                }
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

        issues.append(contentsOf: boundaryValidationIssues())
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
        let grouped = Dictionary(grouping: pool) { $0.canonicalCategoryRawValue }
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

    private static func mockExamPool(version: JavaExamVersion, level: JavaLevel) -> [Quiz] {
        deduplicated(
            quizzes(version: version, level: level) +
            mockExamOnlyQuizzes.filter { $0.examVersion == version && $0.level == level }
        )
    }

    private static func boundaryValidationIssues() -> [String] {
        var issues: [String] = []

        for version in JavaExamVersion.allCases {
            for level in JavaLevel.allCases {
                let poolCount = mockExamPool(version: version, level: level).count
                guard poolCount > 0 else { continue }

                let spec = MockExamSpec.official(version: version, level: level)
                for variant in MockExamVariant.allCases {
                    let requested = spec.questionCount(for: variant)
                    if requested <= 0 {
                        issues.append("\(version.displayName) \(level.displayName) \(variant.displayName): requested question count must be positive")
                    }

                    guard let session = makeMockExamSession(variant: variant, version: version, level: level) else {
                        issues.append("\(version.displayName) \(level.displayName) \(variant.displayName): session could not be created")
                        continue
                    }

                    let expected = min(requested, poolCount)
                    if session.quizzes.count != expected {
                        issues.append("\(version.displayName) \(level.displayName) \(variant.displayName): expected \(expected) questions, got \(session.quizzes.count)")
                    }

                    let selectedIds = session.quizzes.map(\.id)
                    if Set(selectedIds).count != selectedIds.count {
                        issues.append("\(version.displayName) \(level.displayName) \(variant.displayName): duplicate quiz selected")
                    }
                }
            }
        }

        return issues
    }

    private static func mixedMockExamSelection(
        practicePool: [Quiz],
        exclusivePool: [Quiz],
        limit: Int
    ) -> [Quiz] {
        guard limit > 0 else { return [] }
        guard !exclusivePool.isEmpty else {
            return Array(practicePool.shuffled().prefix(min(limit, practicePool.count)))
        }

        let exclusiveTarget = min(exclusivePool.count, max(1, Int((Double(limit) * 0.25).rounded(.down))))
        let exclusive = Array(exclusivePool.shuffled().prefix(exclusiveTarget))
        let practiceTarget = max(0, limit - exclusive.count)
        let practice = Array(practicePool.shuffled().prefix(min(practiceTarget, practicePool.count)))

        var selected = deduplicated(exclusive + practice)
        if selected.count < limit {
            let selectedIds = Set(selected.map(\.id))
            let fill = deduplicated(practicePool + exclusivePool)
                .filter { !selectedIds.contains($0.id) }
                .shuffled()
                .prefix(limit - selected.count)
            selected.append(contentsOf: fill)
        }

        return Array(selected.shuffled().prefix(limit))
    }

    private static func deduplicated(_ quizzes: [Quiz]) -> [Quiz] {
        var seenIds = Set<String>()
        return quizzes.filter { quiz in
            seenIds.insert(quiz.id).inserted
        }
    }

    private static func duplicateQuizGroups(
        kind: ContentQualityIssue.Kind,
        title: String,
        minimumCount: Int,
        quizzes: [Quiz],
        key: (Quiz) -> String,
        detail: (String, [String]) -> String
    ) -> [ContentQualityIssue] {
        Dictionary(grouping: quizzes, by: key)
            .filter { !$0.key.isEmpty && $0.value.count >= minimumCount }
            .map { key, group in
                let ids = group.map(\.id).sorted()
                return ContentQualityIssue(
                    kind: kind,
                    title: title,
                    quizIds: ids,
                    detail: detail(key, ids)
                )
            }
    }

    private static func repeatedNarrationIssues(quizzes: [Quiz]) -> [ContentQualityIssue] {
        var ownersByNarration: [String: Set<String>] = [:]

        for quiz in quizzes {
            guard let explanation = Explanation.sample(for: quiz.explanationRef) else { continue }
            for step in explanation.steps {
                let key = normalizedContentKey(step.narration)
                guard key.count >= 20 else { continue }
                ownersByNarration[key, default: []].insert(quiz.id)
            }
        }

        return ownersByNarration
            .filter { $0.value.count >= 3 }
            .map { narration, ownerIds in
                let ids = ownerIds.sorted()
                return ContentQualityIssue(
                    kind: .repeatedExplanationNarration,
                    title: "解説文の同一フレーズが多用",
                    quizIds: ids,
                    detail: "同じ解説文が\(ids.count)問で使われています。コード固有の変数・分岐・出力理由へ寄せる候補です: \(narration)"
                )
            }
    }

    private static func normalizedContentKey(_ text: String) -> String {
        text
            .replacingOccurrences(of: "`", with: "")
            .replacingOccurrences(of: "　", with: " ")
            .replacingOccurrences(of: #"[\s\n\r\t]+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
