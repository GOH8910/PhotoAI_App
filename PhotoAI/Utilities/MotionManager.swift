//
//  MotionManager.swift
//  PhotoAI
//
//  Created by Edward Goh on 04/06/2025.
//

import Foundation
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var previousPitch: Double = 0.0
    private var previousRoll: Double = 0.0

    @Published var pitchDegrees: Double = 0.0
    @Published var rollDegrees: Double = 0.0

    init() {
        startMotionUpdates()
    }

    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.05

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard
                let self = self,
                let gravity = motion?.gravity,
                let attitude = motion?.attitude
            else { return }

            let correctedPitch = MotionUtils.calculatePitchDegrees(gravityY: gravity.y, gravityZ: gravity.z)
            let correctedRoll = attitude.roll * 180.0 / .pi

            let finalPitch = MotionUtils.smooth(previous: self.previousPitch, current: correctedPitch)
            let finalRoll = MotionUtils.smooth(previous: self.previousRoll, current: correctedRoll)

            self.previousPitch = finalPitch
            self.previousRoll = finalRoll
            self.pitchDegrees = -finalPitch
            self.rollDegrees = finalRoll
        }
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
