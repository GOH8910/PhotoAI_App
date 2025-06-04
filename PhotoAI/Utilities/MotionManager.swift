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
    private let filterFactor = 0.1 // Lower = smoother
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

            // === VERTICAL TILT (pitch) via gravity ===
            // gravity.y = –cos(θ), gravity.z = –sin(θ)  if θ is "angle from upright"
            // So θ = atan2(–gravity.z, –gravity.y).
            let rawPitchRadians = atan2(-gravity.z, -gravity.y)
            let rawPitchDegrees = rawPitchRadians * 180.0 / .pi
            // Now: rawPitchDegrees is exactly
            //   0°   when device is upright,
            //  +90°  when screen faces sky,
            //  –90°  when screen faces ground.
            let correctedPitch = rawPitchDegrees

            // === HORIZONTAL TILT (roll) from attitude.roll ===
            // CoreMotion’s attitude.roll already goes
            //   –90° at left‐tilt, +90° at right‐tilt (when device is vertical).
            let rawRollDegrees = attitude.roll * 180.0 / .pi
            let correctedRoll = rawRollDegrees

            // === Apply light smoothing if you like ===
            let pitchDelta = abs(correctedPitch - self.previousPitch)
            let finalPitch = pitchDelta > 2.0
                ? correctedPitch
                : (self.previousPitch * 0.7 + correctedPitch * 0.3)

            let rollDelta = abs(correctedRoll - self.previousRoll)
            let finalRoll = rollDelta > 2.0
                ? correctedRoll
                : (self.previousRoll * 0.7 + correctedRoll * 0.3)

            self.previousPitch = finalPitch
            self.previousRoll  = finalRoll
            self.pitchDegrees  = finalPitch
            self.rollDegrees   = finalRoll
        }
    }
    

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
