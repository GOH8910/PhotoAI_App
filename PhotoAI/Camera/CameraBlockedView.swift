//
//  CameraBlockedView.swift
//  PhotoAI
//

import SwiftUI

/// Explains why the camera isn't running and, when the user can fix it, links to Settings.
struct CameraBlockedView: View {
    let state: CameraState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 44))
            Text(Self.title(for: state))
                .font(.title2.bold())
            Text(Self.message(for: state))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if Self.offersSettings(for: state), let url = URL(string: UIApplication.openSettingsURLString) {
                Link("Open Settings", destination: url)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .foregroundStyle(.white)
    }

    static func title(for state: CameraState) -> String {
        switch state {
        case .unauthorized: "PhotoAI needs the camera"
        case .unavailable: "No camera on this device"
        case .failed: "The camera didn't start"
        case .idle, .running: ""
        }
    }

    static func message(for state: CameraState) -> String {
        switch state {
        case .unauthorized(.restricted):
            "Camera access is restricted on this device, for example by Screen Time. Ask whoever manages it to allow the camera."
        case .unauthorized:
            "Your photographer needs the live camera to match your reference. Allow camera access in Settings, then come back."
        case .unavailable:
            "PhotoAI needs an iPhone with a back camera. The simulator doesn't have one."
        case .failed:
            "Close the app and open it again. If it keeps happening, restart the phone."
        case .idle, .running:
            ""
        }
    }

    /// Only a plain denial can be fixed by the user in Settings.
    static func offersSettings(for state: CameraState) -> Bool {
        if case .unauthorized(.denied) = state { return true }
        return false
    }
}

#Preview("Denied") {
    CameraBlockedView(state: .unauthorized(.denied))
}

#Preview("No camera") {
    CameraBlockedView(state: .unavailable)
}
