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

/// Session configuration failures only. `CameraState.failed` carries these.
enum CameraError: Error, Equatable, Sendable {
    case cannotAddInput
    case cannotAddOutput
}

/// Published by `CameraService`. `RootView` and `CameraBlockedView` switch on it.
enum CameraState: Equatable, Sendable {
    /// Before or during `start()`, including while the permission prompt is showing.
    case idle
    /// Permission is denied or restricted.
    case unauthorized(CameraAuthorization)
    /// No back camera on this device (the simulator, for one).
    case unavailable
    /// Configured and `startRunning()` returned. Interruptions and runtime errors are not tracked yet (Week 2).
    case running
    case failed(CameraError)
}
