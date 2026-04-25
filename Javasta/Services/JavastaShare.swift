import Foundation

enum JavastaShare {
    static let appInviteText = """
JavastaでJava Silver / Goldの対策中。
コードの流れを追いながら、出力問題と模擬試験を練習できます。
"""

    static func practiceResult(
        level: JavaLevel,
        version: JavaExamVersion,
        title: String,
        correctCount: Int,
        totalCount: Int,
        scorePercent: Int
    ) -> String {
        """
Javastaで\(level.displayName)対策。
\(version.examCode(for: level)) / \(title)
結果: \(correctCount)/\(totalCount)問 正解（\(scorePercent)%）
"""
    }

    static func mockExamResult(
        level: JavaLevel,
        version: JavaExamVersion,
        variant: MockExamVariant,
        correctCount: Int,
        totalCount: Int,
        scorePercent: Int,
        isPassing: Bool
    ) -> String {
        """
Javastaで\(level.displayName)の\(variant.displayName)を実施。
\(version.examCode(for: level))
結果: \(correctCount)/\(totalCount)問 正解（\(scorePercent)%）
\(isPassing ? "合格ゾーンに到達" : "合格ゾーンまであと少し")
"""
    }
}
