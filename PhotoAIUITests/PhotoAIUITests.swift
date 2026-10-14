//
//  PhotoAIUITests.swift
//  PhotoAIUITests
//
//  Created by Edward Goh on 30/05/2025.
//

import XCTest

final class PhotoAIUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testSimulatorLaunchShowsNoCameraScreen() throws {
        #if targetEnvironment(simulator)
        let app = XCUIApplication()
        // Simulator clones inherit the base device's camera answer, so start from "not asked" every run.
        app.resetAuthorizationStatus(for: .camera)
        app.launch()

        let allow = XCUIApplication(bundleIdentifier: "com.apple.springboard").alerts.buttons["Allow"]
        XCTAssertTrue(allow.waitForExistence(timeout: 10), "The first launch should ask for the camera")
        allow.tap()

        XCTAssertTrue(
            app.staticTexts["No camera on this device"].waitForExistence(timeout: 10),
            "With access allowed, a camera-less simulator should show the no-camera screen"
        )
        #else
        throw XCTSkip("Only meaningful on the simulator, which has no back camera")
        #endif
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
