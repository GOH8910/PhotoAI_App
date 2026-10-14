//
//  RootView.swift
//  PhotoAI
//

import SwiftUI

/// Starts the camera once and shows either the camera UI or why it can't run.
struct RootView: View {
    @StateObject private var cameraService = CameraService()

    var body: some View {
        // One start per window: this ZStack keeps its identity whichever branch shows.
        // Later starts come only from Try Again.
        ZStack { content }
            .preferredColorScheme(.dark)
            .task { await cameraService.start() }
    }

    @ViewBuilder
    private var content: some View {
        switch cameraService.state {
        case .idle:
            Color.black.ignoresSafeArea()
        case .running:
            CameraView(cameraService: cameraService)
        case .unauthorized, .unavailable, .failed:
            CameraBlockedView(state: cameraService.state) {
                Task { await cameraService.start() }
            }
        }
    }
}
