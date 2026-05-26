import XCTest

final class JavastaUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testHomeEntrypointsAreVisible() throws {
        let app = launchApp()

        XCTAssertTrue(app.buttons["home-settings"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.buttons["home-level-silver"].exists)
        XCTAssertTrue(app.buttons["home-level-gold"].exists)
        XCTAssertTrue(app.buttons["home-practice-daily"].exists)
        XCTAssertTrue(app.buttons["home-practice-unattempted"].exists)
        XCTAssertTrue(app.buttons["home-practice-mockExam"].exists)
    }

    func testDailyQuizCanOpenExplanation() throws {
        let app = launchApp()

        let dailyPractice = app.buttons["home-practice-daily"]
        XCTAssertTrue(dailyPractice.waitForExistence(timeout: 8))
        dailyPractice.tap()

        let firstChoice = app.buttons
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "quiz-choice-"))
            .element(boundBy: 0)
        XCTAssertTrue(firstChoice.waitForExistence(timeout: 8))
        firstChoice.tap()

        let showExplanation = app.buttons["quiz-show-explanation"]
        XCTAssertTrue(showExplanation.waitForExistence(timeout: 5))
        showExplanation.tap()

        let explanationForward = app.buttons["explanation-forward"]
        let explanationFinish = app.buttons["explanation-finish"]
        XCTAssertTrue(
            explanationForward.waitForExistence(timeout: 8) || explanationFinish.waitForExistence(timeout: 1)
        )
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }
}
