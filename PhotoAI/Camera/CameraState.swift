//
//  CameraState.swift
//  PhotoAI
//

import AVFoundation

/// Camera permission as the app understands it. Mirrors `AVAuthorizationStatus`
/// so views never import AVFoundation for this.
enum CameraAuthorization: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted

    init(_ status: AVAuthorizationStatus) {
        switch status {
        case .authorized: self = .authorized
        case .denied: self = .denied
        case .restricted: self = .restricted
        case .notDetermined: self = .notDetermined
        @unknown default: self = .denied
        }
    }
}

enum CameraError: Error, Equatable, Sendable {
    case cannotAddInput
    case cannotAddOutput
}

/// What `RootView` switches on.
enum CameraState: Equatable, Sendable {
    case idle
    /// Permission is denied or restricted.
    case unauthorized(CameraAuthorization)
    /// No back camera on this device (the simulator, for one).
    case unavailable
    case running
    case failed(CameraError)
}
