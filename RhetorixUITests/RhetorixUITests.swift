import XCTest

final class RhetorixUITests: XCTestCase {
    @MainActor
    func testDebateHappyPathCreatesJudgment() throws {
        let app = launchApp()
        app.buttons["home.startVoiceDebate"].tap()

        let topic = app.buttons["topic.row.0"]
        XCTAssertTrue(topic.waitForExistence(timeout: 5))
        topic.tap()

        let start = app.buttons["setup.startDebate"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()

        let keyboard = app.buttons["debate.keyboard"]
        XCTAssertTrue(keyboard.waitForExistence(timeout: 5))
        keyboard.tap()

        let input = firstExistingElement([
            app.textFields["debate.input"],
            app.textViews["debate.input"],
            app.otherElements["debate.input"]
        ])
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("Regulation protects public safety and creates accountability.")

        app.buttons["debate.send"].tap()
        XCTAssertTrue(app.staticTexts["Mock AI response with direct clash, evidence, and impact weighing."].waitForExistence(timeout: 5))

        let endButton = firstExistingElement([app.buttons["debate.end"], app.buttons["End"]])
        XCTAssertTrue(endButton.waitForExistence(timeout: 5))
        endButton.tap()

        XCTAssertTrue(app.staticTexts["Mock judgment: the user wins by clearer clash and better weighing."].waitForExistence(timeout: 5))

        let likeButton = app.buttons["result.feedback.like"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        likeButton.tap()
        let categoryButton = app.buttons["result.feedback.category"].firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()
        XCTAssertTrue(app.staticTexts["Saved: Like · Category"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testConstructiveAnalysisRendersIssueCards() throws {
        let app = launchApp()
        app.tabBars.buttons["Tools"].tap()
        app.buttons["tools.constructiveAnalysis"].tap()

        let input = firstExistingElement([app.textViews["constructive.input"], app.otherElements["constructive.input"]])
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("School uniforms improve grades because my friend wore one and scored higher.")

        app.buttons["constructive.analyze"].tap()
        XCTAssertTrue(app.staticTexts["Mock claim about the topic"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Unsupported evidence"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ask for source quality."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testFallacyDetectorShowsNoFindingState() throws {
        let app = launchApp()
        app.tabBars.buttons["Tools"].tap()
        app.buttons["tools.fallacyDetector"].tap()

        let input = firstExistingElement([app.textViews["fallacy.input"], app.otherElements["fallacy.input"]])
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("This argument cites evidence, explains its warrant, and weighs impacts carefully.")

        app.buttons["fallacy.analyze"].tap()
        XCTAssertTrue(app.staticTexts["No logical fallacies were detected in this text."].waitForExistence(timeout: 5))
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MODE", "UITEST_RESET_DATA"]
        app.launch()
        skipMBTIIfNeeded(app: app)
        return app
    }

    @MainActor
    private func skipMBTIIfNeeded(app: XCUIApplication) {
        let skipButton = app.buttons["onboarding.skipMBTI"]
        if skipButton.waitForExistence(timeout: 3) {
            skipButton.tap()
        }
    }

    @MainActor
    private func firstExistingElement(_ elements: [XCUIElement]) -> XCUIElement {
        elements.first { $0.exists } ?? elements[0]
    }
}
