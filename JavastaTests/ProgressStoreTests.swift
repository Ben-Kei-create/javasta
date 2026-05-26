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
