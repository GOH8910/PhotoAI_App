//
//  HumanDetectorTests.swift
//  PhotoAI
//
//  Created by Edward Goh on 10/06/2025.
//

import XCTest
@testable import PhotoAI

final class HumanDetectorTests: XCTestCase {

    func testFaceOnlyClassification() {
        let result = HumanDetector.classify(from: 0.85)
        XCTAssertEqual(result, ShotType.faceOnly)
    }

    func testHalfBodyClassification() {
        let result = HumanDetector.classify(from: 0.5)
        XCTAssertEqual(result, ShotType.halfBody)
    }

    func testFullBodyClassification() {
        let result = HumanDetector.classify(from: 0.2)
        XCTAssertEqual(result, ShotType.fullBody)
    }

    func testEdgeCaseExactlyAtFaceOnlyThreshold() {
        let result = HumanDetector.classify(from: 0.8)
        XCTAssertEqual(result, ShotType.faceOnly)
    }

    func testEdgeCaseExactlyAtHalfBodyThreshold() {
        let result = HumanDetector.classify(from: 0.4)
        XCTAssertEqual(result, ShotType.halfBody)
    }

    func testBelowFullBody() {
        let result = HumanDetector.classify(from: 0.05)
        XCTAssertEqual(result, ShotType.fullBody)
    }
}
