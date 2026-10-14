//
//  CameraBlockedView.swift
//  PhotoAI
//

import SwiftUI

/// Explains why the camera isn't running and offers the one action that can fix it:
/// Settings for a plain denial, Try Again after a configuration failure.
struct CameraBlockedView: View {
    let state: CameraState
    var retry: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(Self.title(for: state), systemImage: "video.slash.fill")
        } description: {
            Text(Self.message(for: state))
        } actions: {
            if Self.offersSettings(for: state), let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            if Self.offersRetry(for: state), let retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }
        .background(Color.black)
        .environment(\.colorScheme, .dark)
    }

    static func title(for state: CameraState) -> String {
        switch state {
        case .unauthorized: String(localized: "Camera access needed")
        case .unavailable: String(localized: "No camera on this device")
        case .failed: String(localized: "The camera didn't start")
        case .idle, .running: ""
        }
    }

    static func message(for state: CameraState) -> String {
        switch state {
        case .unauthorized(.restricted):
            String(localized: "Camera access is restricted on this device, for example by Screen Time. Ask whoever manages it to allow the camera.")
        case .unauthorized:
            String(localized: "Your photographer needs the live camera to match your reference. Allow camera access in Settings, then come back.")
        case .unavailable:
            String(localized: "This app needs a phone with a back camera.")
        case .failed:
            String(localized: "The camera couldn't be set up. Try again, or restart the phone if it keeps happening.")
        case .idle, .running:
            ""
        }
    }

    /// Only a plain denial can be fixed by the user in Settings.
    static func offersSettings(for state: CameraState) -> Bool {
        if case .unauthorized(.denied) = state { return true }
        return false
    }

    /// A failed configuration is rolled back, so trying again is safe.
    static func offersRetry(for state: CameraState) -> Bool {
        if case .failed = state { return true }
        return false
    }
}

#Preview("Denied") {
    CameraBlockedView(state: .unauthorized(.denied))
}

#Preview("Denied, AX5") {
    CameraBlockedView(state: .unauthorized(.denied))
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Failed") {
    CameraBlockedView(state: .failed(.cannotAddInput), retry: {})
}
