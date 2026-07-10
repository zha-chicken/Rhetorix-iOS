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

        let selfAssessmentSubmit = app.buttons["selfAssessment.submit"]
        XCTAssertTrue(selfAssessmentSubmit.waitForExistence(timeout: 5))
        selfAssessmentSubmit.tap()

        XCTAssertTrue(app.staticTexts["Mock judgment: the user wins by clearer clash and better weighing."].waitForExistence(timeout: 5))
        XCTAssertTrue(scrollToElement(app.staticTexts["Five-skill coach rubric"], in: app))
        XCTAssertTrue(app.staticTexts["Argument structure"].waitForExistence(timeout: 5))

        let likeButton = app.buttons["result.feedback.like"]
        XCTAssertTrue(scrollToElement(likeButton, in: app))
        likeButton.tap()
        let categoryButton = app.buttons["result.feedback.category"].firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()
        XCTAssertTrue(app.staticTexts["Saved: Like · Category"].waitForExistence(timeout: 5))

        let retryButton = app.buttons["result.retrySpeech"].firstMatch
        XCTAssertTrue(scrollToElement(retryButton, in: app, maxSwipes: 12))
        retryButton.tap()

        let retryInput = firstExistingElement([app.textViews["retry.input"], app.otherElements["retry.input"]])
        XCTAssertTrue(retryInput.waitForExistence(timeout: 5))
        retryInput.tap()
        retryInput.typeText(" This revision directly answers the cost claim and weighs safety as larger and harder to reverse.")
        app.buttons["retry.submit"].tap()
        let retryFeedback = app.staticTexts["Mock retry feedback: the revised speech answers the opposing claim more directly and explains the impact."]
        XCTAssertTrue(scrollToElement(retryFeedback, in: app, maxSwipes: 4))
    }

    @MainActor
    func testGuidedPracticeCarriesSkillIntoDebate() throws {
        let app = launchApp()

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Delivery and clarity"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Worked example"].waitForExistence(timeout: 5))

        let start = app.buttons["practice.start"]
        XCTAssertTrue(scrollToElement(start, in: app))
        start.tap()

        XCTAssertTrue(app.staticTexts["Practice focus"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Signpost → One idea per sentence → Clear conclusion"].waitForExistence(timeout: 5))
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
        completeLearningOnboardingIfNeeded(app: app)
        return app
    }

    @MainActor
    private func completeLearningOnboardingIfNeeded(app: XCUIApplication) {
        let continueButton = app.buttons["onboarding.continue"]
        if continueButton.waitForExistence(timeout: 3) {
            if continueButton.isHittable == false {
                app.swipeUp()
            }
            continueButton.tap()
        }
    }

    @MainActor
    private func firstExistingElement(_ elements: [XCUIElement]) -> XCUIElement {
        elements.first { $0.exists } ?? elements[0]
    }

    @MainActor
    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 8) -> Bool {
        for _ in 0..<maxSwipes {
            if element.exists, element.isHittable { return true }
            app.swipeUp()
        }
        return element.exists && element.isHittable
    }
}
