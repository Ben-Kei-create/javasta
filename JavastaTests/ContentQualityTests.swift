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
