import Testing
@testable import Javasta

@Suite("コンテンツ品質") struct ContentQualityTests {
    @Test("リリース品質ゲートがクリーンであること") func testReleaseContentQualityGatesAreClean() {
        let explanationReport = QuestionBank.explanationAuditReport()
        #expect(explanationReport.needsAttentionCount == 0, "\(formattedExplanationIssues(explanationReport.issues))")

        let contentIssues = QuestionBank.contentQualityIssues()
        #expect(contentIssues.isEmpty, "\(formattedContentIssues(contentIssues))")

        let validationIssues = QuestionBank.validationIssues()
        #expect(validationIssues.isEmpty, "\(validationIssues.joined(separator: "\n"))")
    }

    @Test("試験目標に練習問題カバレッジがあること") func testExamObjectivesHavePracticeCoverage() {
        // SE11 は UI から廃止し SE17 に統一。SE17 のみカバレッジをチェック。
        for level in JavaLevel.allCases {
            let uncovered = QuestionBank.coverage(version: .se17, level: level)
                .filter { $0.count == 0 }

            #expect(
                uncovered.isEmpty,
                "\(uncovered.map { "SE17 \(level.displayName) \($0.objective.title)" }.joined(separator: "\n"))"
            )
        }
    }

    /// SE11 は UI から廃止し SE17 に統一。
    /// データモデルはそのまま保持するが、SE11 カバレッジは CI ゲート対象外とする。
    @Test("SE11 Gold 目標に直接練習カバレッジがあること", .disabled("SE11 は SE17 に統一済み。データは保持するが CI ゲートから除外。"))
    func testSE11GoldObjectivesHaveDirectPracticeCoverage() {
    }

    @Test("練習問題がプレゼンテーション用にコンテキスト化されていること") func testPracticeQuestionsAreContextualizedForPresentation() {
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

        #expect(genericQuestions.isEmpty, "\(genericQuestions.prefix(20).joined(separator: "\n"))")
    }

    @Test("模試セッションが重複なしで構築できること") func testMockExamSessionsAreConstructibleWithoutDuplicates() {
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
                    #expect(Set(ids).count == ids.count, "\(version.displayName) \(level.displayName) \(variant.displayName)")
                    #expect(!session.quizzes.isEmpty, "\(version.displayName) \(level.displayName) \(variant.displayName)")
                }
            }
        }
    }

    @Test("模試セッションがバリアントグループ重複を避けること") func testMockExamSessionsAvoidRepeatedVariantGroups() {
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
                    #expect(
                        Set(variantGroups).count == variantGroups.count,
                        "\(version.displayName) \(level.displayName) \(variant.displayName)"
                    )
                }
            }
        }
    }

    @Test("目標進捗が最弱試験エリアを見つけること") func testObjectiveProgressFindsWeakestExamArea() {
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
        #expect(weakest?.objective.id == quiz.examObjectiveId)
        #expect(weakest?.attempts == 1)
        #expect(weakest?.correct == 0)
    }

    @Test("カバー済みカテゴリのコンテンツバランスに十分な深さがあること") func testContentBalanceHasSufficientDepthForCoveredCategories() {
        // 出題されているカテゴリは最低3問の通常問題があることを確認する。
        // 1〜2問しかない場合、弱点克服モードやバランス選択で
        // 同じ問題が繰り返し出題され学習効果が下がる。
        let minimumPracticeCount = 3
        for version in JavaExamVersion.allCases {
            for level in JavaLevel.allCases {
                let issues = QuestionBank.contentBalanceIssues(
                    version: version,
                    level: level,
                    minimumPracticeCount: minimumPracticeCount
                )
                #expect(
                    issues.isEmpty,
                    "\(version.displayName) \(level.displayName) で問題数が少ないカテゴリがあります:\n\(issues.joined(separator: "\n"))"
                )
            }
        }
    }

    @Test("全問題カテゴリが認識されること") func testAllQuizCategoriesAreRecognized() {
        // QuizCategory が CaseIterable になったことで全カテゴリを列挙できる。
        // rawValue が canonical() で解決できないカテゴリが混入していないことを確認。
        let unknownCategories = QuestionBank.allQuizzes
            .filter { $0.canonicalCategory == nil }
            .map { "\($0.id): '\($0.category)'" }

        #expect(
            unknownCategories.isEmpty,
            "カテゴリ名が canonical に解決できない問題があります:\n\(unknownCategories.prefix(20).joined(separator: "\n"))"
        )
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
