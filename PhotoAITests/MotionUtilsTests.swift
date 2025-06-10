//
//  MotionUtilsTests.swift
//  PhotoAI
//
//  Created by Edward Goh on 10/06/2025.
//


import XCTest
@testable import PhotoAI

final class MotionUtilsTests: XCTestCase {

    func testPitchFacingUpright() {
        let pitch = MotionUtils.calculatePitchDegrees(gravityY: -1.0, gravityZ: 0.0)
        XCTAssertEqual(pitch, 0.0, accuracy: 0.01)
    }

    func testPitchFacingSky() {
        let pitch = MotionUtils.calculatePitchDegrees(gravityY: 0.0, gravityZ: -1.0)
        XCTAssertEqual(pitch, 90.0, accuracy: 0.01)
    }

    func testPitchFacingGround() {
        let pitch = MotionUtils.calculatePitchDegrees(gravityY: 0.0, gravityZ: 1.0)
        XCTAssertEqual(pitch, -90.0, accuracy: 0.01)
    }

    func testSmoothingWithSmallDelta() {
        let smoothed = MotionUtils.smooth(previous: 10.0, current: 11.0)
        XCTAssertEqual(smoothed, 10.0 * 0.7 + 11.0 * 0.3, accuracy: 0.001)
    }

    func testSmoothingWithLargeDelta() {
        let smoothed = MotionUtils.smooth(previous: 10.0, current: 20.0)
        XCTAssertEqual(smoothed, 20.0)
    }
}