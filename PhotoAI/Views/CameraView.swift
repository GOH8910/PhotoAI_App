//
//  CameraView.swift
//  PhotoAI
//
//  Created by Edward Goh on 30/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var motionManager = MotionManager()
    @State private var zoomLevels: [CGFloat] = [1.0, 2.0, 3.0]
    @State private var zoomIndex = 0
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusRing: Bool = false
    @State private var showInstruction: Bool = true
    @State private var instructionText: String = "Center the object in the frame"

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // Camera Preview (4:3 ratio) with grid
                    CameraFrame(aspectRatio: 3/4, showGrid: true) {
                        if let previewLayer = cameraService.previewLayer {
                            CameraPreview(previewLayer: previewLayer)
                                .aspectRatio(3/4, contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                                .contentShape(Rectangle()) // Makes entire area tappable
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            let tapPoint = value.location
                                            cameraService.focus(at: tapPoint)
                                            focusPoint = tapPoint
                                            showFocusRing = true

                                            // Hide after delay
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                showFocusRing = false
                                            }
                                        }
                                )
                                if showFocusRing {
                                    Circle()
                                        .stroke(Color.yellow, lineWidth: 2)
                                        .frame(width: 80, height: 80)
                                        .position(focusPoint)
                                        .transition(.opacity)
                                        .animation(.easeOut(duration: 0.3), value: showFocusRing)
                                }
                            if showInstruction {
                                        InstructionOverlay(message: instructionText, isVisible: $showInstruction)
                                    }
                        }
                    }
                    // Flash Toggle Button
                    Menu {
                        Button("Auto") { cameraService.flashMode = .auto }
                        Button("On") { cameraService.flashMode = .on }
                        Button("Off") { cameraService.flashMode = .off }
                    } label: {
                        Image(systemName: flashIcon(for: cameraService.flashMode))
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 30) // Adjust this value as needed
                    .padding(.trailing, 20)
                }
                
                // Tilt
                HStack(spacing: 12) {
                    Text(String(format: "Vertical: %.1f°", motionManager.pitchDegrees))
                    Text(String(format: "Horizontal: %.1f°", motionManager.rollDegrees))
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.bottom, 4)
                
                // Zoom Button Area
                HStack(spacing: 12) {
                    ForEach(zoomLevels.indices, id: \.self) { index in
                        let zoom = zoomLevels[index]
                        Button(action: {
                            zoomIndex = index
                            cameraService.zoomFactor = zoom
                            cameraService.setZoom(factor: zoom)
                        }) {
                            Text(zoom == floor(zoom) ? "\(Int(zoom))x" : String(format: "%.1fx", zoom))
                                .fontWeight(zoomIndex == index ? .bold : .regular)
                                .foregroundColor(zoomIndex == index ? .yellow : .white)
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.vertical, 10)

                Spacer()

                // Bottom Control Panel
                HStack(spacing: 40) {
                    // Left: Thumbnail placeholder
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)

                    // Center: Capture button
                    Button(action: {
                        cameraService.capturePhoto()
                    }) {
                        Circle()
                            .stroke(lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().fill(Color.white).frame(width: 60, height: 60))
                    }

                    // Right: Flip camera icon placeholder
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 30)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                cameraService.startSession()
            }
        }
    }
    private func flashIcon(for mode: AVCaptureDevice.FlashMode) -> String {
        switch mode {
        case .auto: return "bolt.badge.a"
        case .on: return "bolt.fill"
        case .off: return "bolt.slash"
        @unknown default: return "bolt.slash"
        }
    }
}
