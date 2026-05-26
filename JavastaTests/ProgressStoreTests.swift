import XCTest
@testable import Javasta

final class ProgressStoreTests: XCTestCase {
    func testAnswerHistoryAndReviewQueuePersist() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrongChoice = quiz.choices.first { !$0.correct }!
        let correctChoice = quiz.choices.first { $0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.recordAnswer(quiz: quiz, choice: wrongChoice, elapsedSeconds: 42)

        XCTAssertEqual(store.totalAnswered, 1)
        XCTAssertEqual(store.totalCorrect, 0)
        XCTAssertEqual(store.reviewQueueQuizIds, [quiz.id])
        XCTAssertEqual(store.stats(for: quiz.id).attempts, 1)
        XCTAssertTrue(store.stats(for: quiz.id).needsReview)

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.totalAnswered, 1)
        XCTAssertEqual(reloaded.totalCorrect, 0)
        XCTAssertEqual(reloaded.reviewQueueQuizIds, [quiz.id])
        XCTAssertEqual(reloaded.answerHistory.first?.elapsedSeconds, 42)

        reloaded.recordAnswer(quiz: quiz, choice: correctChoice, elapsedSeconds: 30)

        XCTAssertEqual(reloaded.totalAnswered, 2)
        XCTAssertEqual(reloaded.totalCorrect, 1)
        XCTAssertFalse(reloaded.reviewQueueQuizIds.contains(quiz.id))
        XCTAssertEqual(reloaded.stats(for: quiz.id).attempts, 2)
        XCTAssertFalse(reloaded.stats(for: quiz.id).needsReview)
    }

    func testBookmarkAndDailyGoalPersist() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .gold).first!

        let store = ProgressStore(defaults: defaults)
        store.toggleBookmark(quizId: quiz.id)
        store.setDailyGoal(0)

        XCTAssertTrue(store.bookmarkedQuizIds.contains(quiz.id))
        XCTAssertEqual(store.dailyGoal, 1)

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertTrue(reloaded.bookmarkedQuizIds.contains(quiz.id))
        XCTAssertEqual(reloaded.dailyGoal, 1)

        reloaded.toggleBookmark(quizId: quiz.id)
        XCTAssertFalse(reloaded.bookmarkedQuizIds.contains(quiz.id))
    }

    func testResetAllClearsProgressButKeepsDailyGoalSetting() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrongChoice = quiz.choices.first { !$0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.setDailyGoal(20)
        store.toggleBookmark(quizId: quiz.id)
        store.recordAnswer(quiz: quiz, choice: wrongChoice, elapsedSeconds: 12)

        store.resetAll()

        XCTAssertEqual(store.totalAnswered, 0)
        XCTAssertEqual(store.totalCorrect, 0)
        XCTAssertEqual(store.todayAnswered, 0)
        XCTAssertTrue(store.answerHistory.isEmpty)
        XCTAssertTrue(store.reviewQueueQuizIds.isEmpty)
        XCTAssertTrue(store.bookmarkedQuizIds.isEmpty)
        XCTAssertEqual(store.dailyGoal, 20)

        let reloaded = ProgressStore(defaults: defaults)
        XCTAssertEqual(reloaded.totalAnswered, 0)
        XCTAssertTrue(reloaded.answerHistory.isEmpty)
        XCTAssertEqual(reloaded.dailyGoal, 20)
    }

    func testAccuracyPercentIsZeroWhenNoAnswerRecorded() {
        let store = ProgressStore(defaults: makeIsolatedDefaults())
        XCTAssertEqual(store.accuracyPercent, 0)
    }

    func testAccuracyPercentIsHundredWhenAllCorrect() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let correctChoice = quiz.choices.first { $0.correct }!

        let store = ProgressStore(defaults: defaults)
        store.recordAnswer(quiz: quiz, choice: correctChoice, elapsedSeconds: 10)

        XCTAssertEqual(store.accuracyPercent, 100)
    }

    func testWeakTagsSurfaceMostMissedTopics() {
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
        XCTAssertFalse(weak.isEmpty)
        // ミス率降順になっていること
        let missRates = weak.map(\.missRate)
        XCTAssertEqual(missRates, missRates.sorted(by: >))
        // 全エントリのmissRate > 0
        XCTAssertTrue(weak.allSatisfy { $0.misses > 0 })
    }

    func testMockExamAttemptPersistsAndPrunesOldestOver10() {
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
        XCTAssertEqual(stored.count, 10, "最大10件でプルーニングされる")
        // 古い順で並んでいることを確認
        let dates = stored.map(\.completedAt)
        XCTAssertEqual(dates, dates.sorted())
    }

    func testReviewQueueHasNoDuplicatesAfterRepeatedWrongAnswers() {
        let defaults = makeIsolatedDefaults()
        let quiz = QuestionBank.quizzes(version: .se17, level: .silver).first!
        let wrong = quiz.choices.first { !$0.correct }!

        let store = ProgressStore(defaults: defaults)
        // 同じ問題を3回連続で誤答
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)
        store.recordAnswer(quiz: quiz, choice: wrong, elapsedSeconds: 5)

        let occurrences = store.reviewQueueQuizIds.filter { $0 == quiz.id }
        XCTAssertEqual(occurrences.count, 1, "同じ問題IDは復習キューに重複しない")
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "ProgressStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            defaults.removePersistentDomain(forName: suiteName)
        }
        return defaults
    }
}
