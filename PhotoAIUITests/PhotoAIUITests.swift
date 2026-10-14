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
        // A camera-permission alert, if the simulator shows one, must not block the assertion.
        addUIInterruptionMonitor(withDescription: "Camera permission") { alert in
            let allow = alert.buttons.allElementsBoundByIndex.first { $0.label.hasPrefix("Allow") || $0.label == "OK" }
            allow?.tap()
            return allow != nil
        }
        app.launch()
        app.tap() // interruption monitors only fire on the next interaction
        XCTAssertTrue(
            app.staticTexts["No camera on this device"].waitForExistence(timeout: 10),
            "RootView should show the blocked screen on a camera-less simulator"
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
