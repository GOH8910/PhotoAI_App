//
//  CameraView.swift
//  PhotoAI
//

import AVFoundation
import SwiftUI

struct CameraView: View {
    @ObservedObject var cameraService: CameraService
    @StateObject private var motionManager = MotionManager()
    @StateObject private var viewModel: CameraViewModel
    @State private var zoomLevels: [CGFloat] = [1.0, 2.0, 3.0]
    @State private var zoomIndex = 0
    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusRing = false
    @State private var showInstruction = true

    init(cameraService: CameraService) {
        _cameraService = ObservedObject(wrappedValue: cameraService)
        _viewModel = StateObject(wrappedValue: CameraViewModel(cameraService: cameraService))
    }

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    CameraFrame(aspectRatio: 3/4, showGrid: true) {
                        ZStack {
                            CameraPreview(previewLayer: cameraService.previewLayer)
                                .aspectRatio(3/4, contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            let tapPoint = value.location
                                            cameraService.focus(at: tapPoint)
                                            focusPoint = tapPoint
                                            showFocusRing = true
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
                                InstructionOverlay(message: viewModel.frameState.instruction, isVisible: $showInstruction)
                            }
                        }
                    }

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
                    .padding(.top, 30)
                    .padding(.trailing, 20)
                }

                HStack(spacing: 12) {
                    Text(String(format: "Vertical: %.1f°", motionManager.pitchDegrees))
                    Text(String(format: "Horizontal: %.1f°", motionManager.rollDegrees))
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.bottom, 4)

                HStack(spacing: 12) {
                    ForEach(zoomLevels.indices, id: \.self) { index in
                        let zoom = zoomLevels[index]
                        Button {
                            zoomIndex = index
                            cameraService.setZoom(factor: zoom)
                        } label: {
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

                HStack(spacing: 40) {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)

                    Button {
                        cameraService.capturePhoto()
                    } label: {
                        Circle()
                            .stroke(lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().fill(Color.white).frame(width: 60, height: 60))
                    }

                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 30)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }

    private func flashIcon(for mode: AVCaptureDevice.FlashMode) -> String {
        switch mode {
        case .auto: "bolt.badge.a"
        case .on: "bolt.fill"
        case .off: "bolt.slash"
        @unknown default: "bolt.slash"
        }
    }
}
