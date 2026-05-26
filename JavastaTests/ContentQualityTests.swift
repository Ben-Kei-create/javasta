import XCTest
@testable import Javasta

final class ContentQualityTests: XCTestCase {
    func testReleaseContentQualityGatesAreClean() {
        let explanationReport = QuestionBank.explanationAuditReport()
        XCTAssertEqual(
            explanationReport.needsAttentionCount,
            0,
            formattedExplanationIssues(explanationReport.issues)
        )

        let contentIssues = QuestionBank.contentQualityIssues()
        XCTAssertTrue(
            contentIssues.isEmpty,
            formattedContentIssues(contentIssues)
        )

        let validationIssues = QuestionBank.validationIssues()
        XCTAssertTrue(
            validationIssues.isEmpty,
            validationIssues.joined(separator: "\n")
        )
    }

    func testExamObjectivesHavePracticeCoverage() {
        for version in JavaExamVersion.allCases {
            for level in JavaLevel.allCases {
                let uncovered = QuestionBank.coverage(version: version, level: level)
                    .filter { $0.count == 0 }

                XCTAssertTrue(
                    uncovered.isEmpty,
                    uncovered
                        .map { "\(version.displayName) \(level.displayName) \($0.objective.title)" }
                        .joined(separator: "\n")
                )
            }
        }
    }

    func testSE11GoldObjectivesHaveDirectPracticeCoverage() {
        let quizzes = QuestionBank.quizzes(version: .se11, level: .gold)
        let uncovered = ExamObjectiveCatalog.objectives(for: .se11, level: .gold)
            .filter { objective in
                !quizzes.contains { $0.examObjectiveId == objective.id }
            }

        XCTAssertTrue(
            uncovered.isEmpty,
            uncovered
                .map { "\($0.id): \($0.title)" }
                .joined(separator: "\n")
        )
    }

    func testPracticeQuestionsAreContextualizedForPresentation() {
        let genericStems: Set<String> = [
            "このコードを実行したとき、出力されるのはどれか？",
            "このコードをコンパイルしたときの結果として正しいものはどれか？",
            "このコードを実行したとき、出力される結果はどれか？",
            "このコードの出力はどれか？",
            "このコードについて正しい説明はどれか？",
            "このコードの出力として正しいものはどれか？"
        ]

        let genericQuestions = QuestionBank.practiceQuizzes
            .filter { genericStems.contains($0.question) }
            .map { "\($0.id): \($0.question)" }

        XCTAssertTrue(
            genericQuestions.isEmpty,
            genericQuestions.prefix(20).joined(separator: "\n")
        )
    }

    func testMockExamSessionsAreConstructibleWithoutDuplicates() {
        for version in JavaExamVersion.allCases {
            for level in JavaLevel.allCases {
                for variant in MockExamVariant.allCases {
                    guard let session = QuestionBank.makeMockExamSession(
                        variant: variant,
                        version: version,
                        level: level
                    ) else {
                        continue
                    }

                    let ids = session.quizzes.map(\.id)
                    XCTAssertEqual(Set(ids).count, ids.count, "\(version.displayName) \(level.displayName) \(variant.displayName)")
                    XCTAssertFalse(session.quizzes.isEmpty, "\(version.displayName) \(level.displayName) \(variant.displayName)")
                }
            }
        }
    }

    func testMockExamSessionsAvoidRepeatedVariantGroups() {
        for version in JavaExamVersion.allCases {
            for level in JavaLevel.allCases {
                for variant in MockExamVariant.allCases {
                    guard let session = QuestionBank.makeMockExamSession(
                        variant: variant,
                        version: version,
                        level: level
                    ) else {
                        continue
                    }

                    let variantGroups = session.quizzes.compactMap(\.variantGroupId)
                    XCTAssertEqual(
                        Set(variantGroups).count,
                        variantGroups.count,
                        "\(version.displayName) \(level.displayName) \(variant.displayName)"
                    )
                }
            }
        }
    }

    func testObjectiveProgressFindsWeakestExamArea() {
        let suiteName = "ContentQualityTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }
        let store = ProgressStore(defaults: defaults)
        let quiz = QuestionBank.quizzes(version: .se11, level: .gold)
            .first { $0.examObjectiveId != "unmapped" }!
        let wrongChoice = quiz.choices.first { !$0.correct }!

        store.recordAnswer(quiz: quiz, choice: wrongChoice, elapsedSeconds: 30)

        let weakest = store.weakestObjective(version: .se11, level: .gold, minimumAttempts: 1)
        XCTAssertEqual(weakest?.objective.id, quiz.examObjectiveId)
        XCTAssertEqual(weakest?.attempts, 1)
        XCTAssertEqual(weakest?.correct, 0)
    }

    private func formattedExplanationIssues(_ issues: [ExplanationAuditIssue]) -> String {
        issues
            .prefix(20)
            .map { issue in
                [
                    issue.kind.rawValue,
                    issue.quizId ?? "-",
                    issue.explanationRef,
                    issue.detail
                ].joined(separator: " | ")
            }
            .joined(separator: "\n")
    }

    private func formattedContentIssues(_ issues: [ContentQualityIssue]) -> String {
        issues
            .prefix(20)
            .map { issue in
                "\(issue.kind.rawValue) | \(issue.quizIds.joined(separator: ", ")) | \(issue.detail)"
            }
            .joined(separator: "\n")
    }
}
