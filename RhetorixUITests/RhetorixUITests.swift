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

        // The self-assessment comparison is collapsed by default; when
        // expanded, its heading must appear exactly once — the collapsible
        // header already carries the title, so the content must not repeat it.
        let selfAssessmentSection = app.buttons["Your view and the coach's view"]
        XCTAssertTrue(scrollToElement(selfAssessmentSection, in: app))
        selfAssessmentSection.tap()
        XCTAssertTrue(app.staticTexts["You 3"].firstMatch.waitForExistence(timeout: 5))
        let headerButtons = app.buttons.matching(identifier: "Your view and the coach's view")
        XCTAssertEqual(headerButtons.count, 1)
        // The header button exposes its own title as a static-text child, so
        // "no duplicated heading" means: every matching static text on the
        // page lives inside the header button, none in the expanded content.
        let headingTextsInsideHeader = headerButtons.firstMatch.staticTexts.matching(identifier: "Your view and the coach's view").count
        XCTAssertEqual(app.staticTexts.matching(identifier: "Your view and the coach's view").count, headingTextsInsideHeader)
        selfAssessmentSection.tap()
        XCTAssertTrue(app.staticTexts["You 3"].firstMatch.waitForNonExistence(timeout: 5))

        XCTAssertTrue(scrollToElement(app.staticTexts["Five-skill coach rubric"], in: app))
        XCTAssertTrue(app.staticTexts["Argument structure"].waitForExistence(timeout: 5))

        let likeButton = app.buttons["result.feedback.like"]
        XCTAssertTrue(scrollToElement(likeButton, in: app))
        likeButton.tap()
        let categoryButton = app.buttons["result.feedback.category"].firstMatch
        XCTAssertTrue(categoryButton.waitForExistence(timeout: 5))
        categoryButton.tap()
        XCTAssertTrue(app.staticTexts["Saved: Like · Category"].waitForExistence(timeout: 5))

        // Deep review is collapsed by default; expanding reveals it, and
        // collapsing again keeps the rest of the page short.
        let judgeReview = app.buttons["Full judge review"]
        XCTAssertTrue(scrollToElement(judgeReview, in: app))
        XCTAssertFalse(app.staticTexts["Why the judge decided"].exists)
        judgeReview.tap()
        XCTAssertTrue(app.staticTexts["Why the judge decided"].waitForExistence(timeout: 5))
        judgeReview.tap()
        XCTAssertTrue(app.staticTexts["Why the judge decided"].waitForNonExistence(timeout: 5))

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
    func testSkillPathSelectionDoesNotChangeCurriculumPosition() throws {
        let app = launchApp()

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Step 1 / 5"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Next: Argument structure"].waitForExistence(timeout: 5))

        let impactNode = app.buttons["Impact comparison"]
        XCTAssertTrue(impactNode.waitForExistence(timeout: 5))
        impactNode.tap()

        XCTAssertTrue(app.staticTexts["Impact comparison"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Practicing: Impact comparison · Current step: Delivery and clarity"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Step 1 / 5"].exists)
        XCTAssertFalse(app.staticTexts["Step 5 / 5"].exists)
    }

    @MainActor
    func testSkillPathShowsMasteryFromJudgedDebates() throws {
        let app = launchApp(extraArguments: ["UITEST_SEED_JUDGED"])

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Step 1 / 5"].waitForExistence(timeout: 5))

        let structureNode = app.buttons["Argument structure"]
        XCTAssertTrue(structureNode.waitForExistence(timeout: 5))
        XCTAssertEqual(structureNode.value as? String, "Mastered")

        let evidenceNode = app.buttons["Evidence and examples"]
        XCTAssertTrue(evidenceNode.waitForExistence(timeout: 5))
        XCTAssertNotEqual(evidenceNode.value as? String, "Mastered")
    }

    @MainActor
    func testSkillPathCompleteShowsReviewState() throws {
        let app = launchApp(extraArguments: ["UITEST_SEED_MASTERED"])

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Path complete"].waitForExistence(timeout: 5))
        today.tap()

        // With one seeded mastery debate and the default goal (speaking
        // confidence), the first review must be the goal's home skill.
        XCTAssertTrue(app.staticTexts["Path complete · Reviewing: Delivery and clarity"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Next: Argument structure"].exists)

        let deliveryNode = app.buttons["Delivery and clarity"]
        XCTAssertTrue(deliveryNode.waitForExistence(timeout: 5))
        XCTAssertEqual(deliveryNode.value as? String, "Mastered")
    }

    @MainActor
    func testSkillPathReviewRotationFollowsJudgingOrder() throws {
        // Fixture: the mastery-completing session was created later but judged
        // first; an older-created session was resumed and judged after mastery.
        // Rotation must count by judging order, so one post-mastery review has
        // happened and the next review is the second path step, not the
        // goal's home skill.
        let app = launchApp(extraArguments: ["UITEST_SEED_MASTERED_RESUMED"])

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Path complete · Reviewing: Argument structure"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSingleStrongScoreDoesNotMasterSkill() throws {
        // Calibration: one generous judged debate (4+ once) must not master a
        // skill; it shows partial credit instead.
        let app = launchApp(extraArguments: ["UITEST_SEED_JUDGED_ONCE"])

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Step 1 / 5"].waitForExistence(timeout: 5))

        let structureNode = app.buttons["Argument structure"]
        XCTAssertTrue(structureNode.waitForExistence(timeout: 5))
        XCTAssertNotEqual(structureNode.value as? String, "Mastered")
        structureNode.tap()

        XCTAssertTrue(app.staticTexts["Strong scores: 1 / 2"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Step 1 / 5"].exists)
    }

    @MainActor
    func testGuidedPracticeFastTracksMastery() throws {
        // One guided practice focused on the first step, scoring 4+ on it,
        // masters that step alone and advances the curriculum to step 2.
        let app = launchApp(extraArguments: ["UITEST_SEED_GUIDED_MASTERY"])

        let today = app.buttons["home.todayPractice"]
        XCTAssertTrue(today.waitForExistence(timeout: 5))
        today.tap()

        XCTAssertTrue(app.staticTexts["Step 2 / 5"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Next: Evidence and examples"].waitForExistence(timeout: 5))

        let deliveryNode = app.buttons["Delivery and clarity"]
        XCTAssertTrue(deliveryNode.waitForExistence(timeout: 5))
        XCTAssertEqual(deliveryNode.value as? String, "Mastered")

        let clashNode = app.buttons["Direct clash and rebuttal"]
        XCTAssertTrue(clashNode.waitForExistence(timeout: 5))
        XCTAssertNotEqual(clashNode.value as? String, "Mastered")
    }

    @MainActor
    func testNavigationExposesBackButtonAndHidesPreviousScreens() throws {
        // Pushed screens must fully replace the previous screen in the
        // accessibility tree, and every pushed screen must expose a real
        // back button — VoiceOver users should never reach hidden controls.
        let app = launchApp()
        app.buttons["home.startVoiceDebate"].tap()

        XCTAssertTrue(app.buttons["topic.row.0"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["home.startVoiceDebate"].exists)
        let backButton = app.navigationBars.buttons["BackButton"]
        XCTAssertTrue(backButton.exists)
        XCTAssertTrue(backButton.isHittable)

        app.buttons["topic.row.0"].tap()
        XCTAssertTrue(app.buttons["setup.startDebate"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["topic.row.0"].exists)
        XCTAssertFalse(app.buttons["home.startVoiceDebate"].exists)
        XCTAssertFalse(app.tabBars.firstMatch.exists)
        XCTAssertTrue(app.navigationBars.buttons["BackButton"].exists)
    }

    @MainActor
    func testMemoryDetailLocksSignalsWithoutInferenceEvidence() throws {
        // One judged debate is below the inference-evidence bar: Memory
        // Detail must show the locked explainer instead of inferred signal
        // sections, matching the locked state Home already shows.
        let app = launchApp(extraArguments: ["UITEST_SEED_JUDGED_ONCE"])

        let details = app.buttons["home.memoryDetails"]
        XCTAssertTrue(scrollToElement(details, in: app))
        details.tap()

        XCTAssertTrue(app.staticTexts["Complete more debates to unlock reliable inferred profile signals."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Debate style"].exists)
        XCTAssertFalse(app.staticTexts["Practice focus"].exists)
    }

    @MainActor
    func testMemoryDetailShowsSignalsWithInferenceEvidence() throws {
        // Two judged debates cross the inference-evidence bar: the inferred
        // weakness signal must appear on Memory Detail and the locked
        // explainer must not.
        let app = launchApp(extraArguments: ["UITEST_SEED_WEAK_DELIVERY"])

        let details = app.buttons["home.memoryDetails"]
        XCTAssertTrue(scrollToElement(details, in: app))
        details.tap()

        XCTAssertTrue(app.staticTexts["Needs clearer delivery"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Complete more debates to unlock reliable inferred profile signals."].exists)
    }

    @MainActor
    func testDeliveryWeaknessSignalFromRubric() throws {
        // Two judged debates with low coach scores on delivery only: the
        // rubric-based weakness signal must surface on the Home memory card.
        let app = launchApp(extraArguments: ["UITEST_SEED_WEAK_DELIVERY"])

        XCTAssertTrue(app.buttons["home.todayPractice"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Needs clearer delivery"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSettingsHubOpensVoiceEnginePage() throws {
        let app = launchApp()
        app.tabBars.buttons["Settings"].tap()

        XCTAssertTrue(app.staticTexts["AI Providers"].waitForExistence(timeout: 5))

        let voiceRow = app.buttons["settings.voiceEngine"]
        XCTAssertTrue(scrollToElement(voiceRow, in: app))
        voiceRow.tap()

        XCTAssertTrue(app.staticTexts["Online voice engines read AI responses when configured. System voice remains the fallback if online speech is unavailable."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testScreenshotTour() throws {
        continueAfterFailure = true
        let dir = ProcessInfo.processInfo.environment["SHOT_DIR"] ?? "/tmp/rhetorix-shots"
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        func snap(_ name: String) {
            let png = XCUIScreen.main.screenshot().pngRepresentation
            try? png.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
        }

        let themeArguments = ProcessInfo.processInfo.environment["SHOT_THEME"] == "light" ? ["UITEST_THEME_LIGHT"] : []
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MODE", "UITEST_RESET_DATA", "UITEST_SEED_JUDGED"] + themeArguments
        app.launch()

        let continueButton = app.buttons["onboarding.continue"]
        if continueButton.waitForExistence(timeout: 3) {
            snap("00-onboarding")
            if continueButton.isHittable == false { app.swipeUp() }
            continueButton.tap()
        }

        XCTAssertTrue(app.buttons["home.todayPractice"].waitForExistence(timeout: 5))
        snap("01-home-top")
        app.swipeUp()
        snap("02-home-bottom")

        app.buttons["home.todayPractice"].tap()
        XCTAssertTrue(app.staticTexts["Worked example"].waitForExistence(timeout: 5))
        snap("03-guided-practice")
        let start = app.buttons["practice.start"]
        _ = scrollToElement(start, in: app)
        snap("04-guided-practice-bottom")
        start.tap()
        XCTAssertTrue(app.buttons["debate.keyboard"].waitForExistence(timeout: 5))
        snap("05-live-debate")

        app.terminate()
        app.launchArguments = ["UITEST_MODE", "UITEST_SEED_JUDGED"] + themeArguments
        app.launch()
        XCTAssertTrue(app.buttons["home.startVoiceDebate"].waitForExistence(timeout: 5))
        app.buttons["home.startVoiceDebate"].tap()
        XCTAssertTrue(app.buttons["topic.row.0"].waitForExistence(timeout: 5))
        snap("06-topic-selection")
        app.buttons["topic.row.0"].tap()
        XCTAssertTrue(app.buttons["setup.startDebate"].waitForExistence(timeout: 5))
        snap("07-debate-setup")
        app.navigationBars.buttons["BackButton"].tap()
        app.navigationBars.buttons["BackButton"].tap()

        app.tabBars.buttons.element(boundBy: 1).tap()
        snap("08-history")
        app.tabBars.buttons.element(boundBy: 2).tap()
        snap("09-tools")
        app.tabBars.buttons.element(boundBy: 3).tap()
        snap("10-settings")
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'OpenAI'")).firstMatch.tap()
        XCTAssertTrue(app.buttons["Save Configuration"].firstMatch.waitForExistence(timeout: 5))
        snap("11-provider")
    }

    @MainActor
    private func launchApp(extraArguments: [String] = []) -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MODE", "UITEST_RESET_DATA"] + extraArguments
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
