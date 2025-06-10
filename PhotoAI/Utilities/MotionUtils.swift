//
//  MotionUtils.swift
//  PhotoAI
//
//  Created by Edward Goh on 10/06/2025.
//


import Foundation

struct MotionUtils {
    static func calculatePitchDegrees(gravityY: Double, gravityZ: Double) -> Double {
        let radians = atan2(-gravityZ, -gravityY)
        return radians * 180.0 / .pi
    }

    static func smooth(previous: Double, current: Double, deltaThreshold: Double = 2.0) -> Double {
        let delta = abs(current - previous)
        return delta > deltaThreshold
            ? current
            : (previous * 0.7 + current * 0.3)
    }
}