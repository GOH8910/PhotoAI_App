//
//  CameraService.swift
//  PhotoAI
//

@preconcurrency import AVFoundation
import Combine
import os
import UIKit

/// Owns the capture session. Every session mutation happens on `sessionQueue`;
/// every published change happens on the main thread.
/// `@unchecked Sendable` rests on that queue discipline, which the compiler cannot verify.
final class CameraService: NSObject, ObservableObject, @unchecked Sendable {

    /// The system calls the service makes. Tests inject these to drive the
    /// permission and hardware paths without a camera.
    struct Dependencies {
        var authorizationStatus: () -> AVAuthorizationStatus
        var requestAccess: () async -> Bool
        var backCamera: () -> AVCaptureDevice?

        static let live = Dependencies(
            authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) },
            requestAccess: { await AVCaptureDevice.requestAccess(for: .video) },
            backCamera: { AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) }
        )
    }

    let session = AVCaptureSession()
    let previewLayer: AVCaptureVideoPreviewLayer

    @Published private(set) var state: CameraState = .idle
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published private(set) var zoomFactor: CGFloat = 1.0
    @Published private(set) var shotType: ShotType = .none

    private let dependencies: Dependencies
    private let sessionQueue = DispatchQueue(label: "com.goh8910.PhotoAI.session")
    private let videoQueue = DispatchQueue(label: "com.goh8910.PhotoAI.video")
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var deviceInput: AVCaptureDeviceInput?
    private var isConfigured = false
    private let logger = Logger(subsystem: "com.goh8910.PhotoAI", category: "camera")

    init(dependencies: Dependencies = .live) {
        self.dependencies = dependencies
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init()
        previewLayer.videoGravity = .resizeAspectFill
    }

    // MARK: - Lifecycle

    /// Resolves permission, then hardware, configures once, and starts the session.
    /// Safe to call again: a running session is left alone.
    @MainActor
    func start() async {
        if state == .running { return }

        let authorization = await resolveAuthorization()
        guard authorization == .authorized else {
            state = .unauthorized(authorization)
            return
        }

        guard let camera = dependencies.backCamera() else {
            state = .unavailable
            return
        }

        let result: Result<Void, CameraError> = await withCheckedContinuation { continuation in
            sessionQueue.async {
                continuation.resume(returning: self.configureAndRun(camera: camera))
            }
        }

        switch result {
        case .success:
            state = .running
        case .failure(let error):
            logger.error("Camera session failed: \(String(describing: error))")
            state = .failed(error)
        }
    }

    private func resolveAuthorization() async -> CameraAuthorization {
        let current = CameraAuthorization(dependencies.authorizationStatus())
        guard current == .notDetermined else { return current }
        return await dependencies.requestAccess() ? .authorized : .denied
    }

    /// Runs on `sessionQueue`.
    private func configureAndRun(camera: AVCaptureDevice) -> Result<Void, CameraError> {
        if !isConfigured {
            if case .failure(let error) = configure(camera: camera) {
                return .failure(error)
            }
            isConfigured = true
        }
        if !session.isRunning {
            session.startRunning()
        }
        return .success(())
    }

    /// Runs on `sessionQueue`. Every path commits, so the session is never left
    /// between `beginConfiguration` and `commitConfiguration`.
    private func configure(camera: AVCaptureDevice) -> Result<Void, CameraError> {
        session.beginConfiguration()
        defer { session.commitConfiguration() }

        session.sessionPreset = .photo

        guard let input = try? AVCaptureDeviceInput(device: camera), session.canAddInput(input) else {
            return .failure(.cannotAddInput)
        }
        session.addInput(input)
        deviceInput = input

        guard session.canAddOutput(photoOutput) else {
            return .failure(.cannotAddOutput)
        }
        session.addOutput(photoOutput)

        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        guard session.canAddOutput(videoOutput) else {
            return .failure(.cannotAddOutput)
        }
        session.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90 // portrait
        }
        return .success(())
    }

    // MARK: - Controls

    /// `layerPoint` is in the preview layer's coordinate space. Call on the main thread.
    func focus(at layerPoint: CGPoint) {
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: layerPoint)
        sessionQueue.async { [weak self] in
            guard let self, let device = self.deviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(.autoFocus) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = .autoFocus
                }
                if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.autoExpose) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = .autoExpose
                }
            } catch {
                self.logger.error("Focus failed: \(error.localizedDescription)")
            }
        }
    }

    func setZoom(factor: CGFloat) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.deviceInput?.device else { return }
            let clamped = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = clamped
                device.unlockForConfiguration()
                DispatchQueue.main.async { self.zoomFactor = clamped }
            } catch {
                self.logger.error("Zoom failed: \(error.localizedDescription)")
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        if photoOutput.supportedFlashModes.contains(flashMode) {
            settings.flashMode = flashMode
        }
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - Capture delegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            logger.error("Capture failed: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            logger.error("Capture produced no image data")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            logger.error("Save failed: \(error.localizedDescription)")
            return
        }
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

// MARK: - Frame delegate

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        HumanDetector.detectHuman(in: pixelBuffer) { [weak self] detected in
            DispatchQueue.main.async { self?.shotType = detected }
        }
    }
}
