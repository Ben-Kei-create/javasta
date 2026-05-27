import Testing
@testable import Javasta

@Suite("進捗ストア") struct ProgressStoreTests {
    @Test("回答履歴と復習キューが永続化されること") func testAnswerHistoryAndReviewQueuePersist() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrongChoice = quiz.choices.first { !$0.correct }!
        let correctChoice = quiz.choices.first { $0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.recordAnswer(quiz: quiz, choice: wrongChoice, elapsedSeconds: 42)

        #expect(store.totalAnswered == 1)
        #expect(store.totalCorrect == 0)
        #expect(store.reviewQueueQuizIds == [quiz.id])
        #expect(store.stats(for: quiz.id).attempts == 1)
        #expect(store.stats(for: quiz.id).needsReview)

        let reloaded = ProgressStore(defaults: defaults)
        #expect(reloaded.totalAnswered == 1)
        #expect(reloaded.totalCorrect == 0)
        #expect(reloaded.reviewQueueQuizIds == [quiz.id])
        #expect(reloaded.answerHistory.first?.elapsedSeconds == 42)

        reloaded.recordAnswer(quiz: quiz, choice: correctChoice, elapsedSeconds: 30)

        #expect(reloaded.totalAnswered == 2)
        #expect(reloaded.totalCorrect == 1)
        #expect(!reloaded.reviewQueueQuizIds.contains(quiz.id))
        #expect(reloaded.stats(for: quiz.id).attempts == 2)
        #expect(!reloaded.stats(for: quiz.id).needsReview)
    }

    @Test("ブックマークと1日目標が永続化されること") func testBookmarkAndDailyGoalPersist() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .gold).first!

        let store = ProgressStore(defaults: defaults)
        store.toggleBookmark(quizId: quiz.id)
        store.setDailyGoal(0)

        #expect(store.bookmarkedQuizIds.contains(quiz.id))
        #expect(store.dailyGoal == 1)

        let reloaded = ProgressStore(defaults: defaults)
        #expect(reloaded.bookmarkedQuizIds.contains(quiz.id))
        #expect(reloaded.dailyGoal == 1)

        reloaded.toggleBookmark(quizId: quiz.id)
        #expect(!reloaded.bookmarkedQuizIds.contains(quiz.id))
    }

    @Test("全リセットが進捗をクリアし1日目標設定は保持されること") func testResetAllClearsProgressButKeepsDailyGoalSetting() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrongChoice = quiz.choices.first { !$0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.setDailyGoal(20)
        store.toggleBookmark(quizId: quiz.id)
        store.recordAnswer(quiz: quiz, choice: wrongChoice, elapsedSeconds: 12)

        store.resetAll()

        #expect(store.totalAnswered == 0)
        #expect(store.totalCorrect == 0)
        #expect(store.todayAnswered == 0)
        #expect(store.answerHistory.isEmpty)
        #expect(store.reviewQueueQuizIds.isEmpty)
        #expect(store.bookmarkedQuizIds.isEmpty)
        #expect(store.dailyGoal == 20)

        let reloaded = ProgressStore(defaults: defaults)
        #expect(reloaded.totalAnswered == 0)
        #expect(reloaded.answerHistory.isEmpty)
        #expect(reloaded.dailyGoal == 20)
    }

    @Test("回答なしの場合に正答率がゼロであること") func testAccuracyPercentIsZeroWhenNoAnswerRecorded() {
        let store = ProgressStore(defaults: makeIsolatedDefaults())
        #expect(store.accuracyPercent == 0)
    }

    @Test("全問正解の場合に正答率が100%であること") func testAccuracyPercentIsHundredWhenAllCorrect() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let correctChoice = quiz.choices.first { $0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.recordAnswer(quiz: quiz, choice: correctChoice, elapsedSeconds: 10)

        #expect(store.accuracyPercent == 100)
    }

    @Test("苦手タグが最も多く誤答したトピックを返すこと") func testWeakTagsSurfaceMostMissedTopics() {
        let defaults = makeIsolatedDefaults()
        let store = ProgressStore(defaults: defaults)

        // タグが付いた問題を選んで複数回誤答
        let taggedQuizzes = QuestionBank.quizzes(version: .se17, level: .silver)
            .filter { !$0.tags.isEmpty }
            .prefix(3)
        for quiz in taggedQuizzes {
            let wrong = quiz.choices.first { !$0.correct }!
            store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 20)
        }

        let weak = store.weakTags(limit: 5)
        // 誤答があるので必ず1件以上
        #expect(!weak.isEmpty)
        // ミス率降順になっていること
        let missRates = weak.map(\.missRate)
        #expect(missRates == missRates.sorted(by: >))
        // 全エントリのmissRate > 0
        #expect(weak.allSatisfy { $0.misses > 0 })
    }

    @Test("模試記録が永続化され10件を超えたら古いものが削除されること") func testMockExamAttemptPersistsAndPrunesOldestOver10() {
        let defaults = makeIsolatedDefaults()
        let store = ProgressStore(defaults: defaults)
        let quizzes = Array(QuestionBank.quizzes(version: .se17, level: .gold).prefix(5))

        // 11件記録 → 古い1件が刈り取られ10件になる
        let baseDate = Date()
        for i in 0..<11 {
            let answers: [MockExamAnswer] = quizzes.map { quiz in
                MockExamAnswer(
                    quizId: quiz.id,
                    category: quiz.canonicalCategoryRawValue,
                    tags: quiz.tags,
                    selectedChoiceId: quiz.choices.first?.id,
                    correctChoiceId: quiz.choices.first(where: \.correct)?.id ?? "",
                    correct: i % 2 == 0,
                    elapsedSeconds: 30
                )
            }
            let completedAt = baseDate.addingTimeInterval(Double(i) * 60)
            let attempt = MockExamAttempt(
                version: .se17,
                level: .gold,
                variant: .full,
                startedAt: completedAt.addingTimeInterval(-300),
                completedAt: completedAt,
                timeLimitSeconds: 9000,
                elapsedSeconds: 300,
                questionCount: answers.count,
                correctCount: answers.filter(\.correct).count,
                passingScorePercent: 65,
                answers: answers
            )
            store.recordMockExamAttempt(attempt, quizzes: quizzes)
        }

        let stored = store.mockExamAttempts(version: .se17, level: .gold, variant: .full)
        #expect(stored.count == 10, "最大10件でプルーニングされる")
        // 古い順で並んでいることを確認
        let dates = stored.map(\.completedAt)
        #expect(dates == dates.sorted())
    }

    @Test("繰り返し誤答後に復習キューに重複がないこと") func testReviewQueueHasNoDuplicatesAfterRepeatedWrongAnswers() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrong = quiz.choices.first { !$0.correct }!

        let store = ProgressStore(defaults: defaults)
        // 同じ問題を3回連続で誤答
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)

        let occurrences = store.reviewQueueQuizIds.filter { $0 == quiz.id }
        #expect(occurrences.count == 1, "同じ問題IDは復習キューに重複しない")
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "ProgressStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
