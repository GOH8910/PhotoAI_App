//
//  CameraView.swift
//  PhotoAI
//
//  Created by Edward Goh on 30/05/2025.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var cameraService = CameraService()

    var body: some View {
        ZStack {
                let screenWidth = UIScreen.main.bounds.width
                let previewHeight = screenWidth * 4 / 3

                CameraPreview(session: cameraService.session)
                    .frame(width: screenWidth, height: previewHeight)
                    .clipped()

                GridOverlayView()

                VStack {
                    Spacer()

                    // Capture Button
                    Button(action: {
                        cameraService.capturePhoto()
                    }) {
                        Circle()
                            .stroke(lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().fill(Color.white).frame(width: 60, height: 60))
                    }
                    .padding(.bottom, 20)

                    // Zoom Slider
                    Slider(value: $cameraService.zoomFactor, in: 1...3, step: 0.1)
                        .padding(.horizontal)
                        .onChange(of: cameraService.zoomFactor) { newValue in
                            cameraService.setZoom(factor: newValue)
                        }
                }
            }
        .onAppear {
            cameraService.startSession()
        }
    }
}
