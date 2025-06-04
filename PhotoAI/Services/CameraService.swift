//
//  CameraService.swift
//  PhotoAI
//
//  Created by Edward Goh on 30/05/2025.
//

import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    public let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var deviceInput: AVCaptureDeviceInput?
    
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var zoomFactor: CGFloat = 1.0
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    
    override init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo // Forces 4:3 resolution
        
        // input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            print("❌ Cannot access camera input")
            return
        }
        session.addInput(input)
        self.deviceInput = input
        
        // output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer

        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    func focus(at point: CGPoint) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.isFocusPointOfInterestSupported,
              device.isFocusModeSupported(.autoFocus),
              let previewLayer = self.previewLayer else { return }

        let focusPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)

        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = focusPoint
            device.focusMode = .autoFocus
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            print("⚠️ Failed to focus: \(error)")
        }
    }
    
    func setZoom(factor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
        } catch {
            print("Error setting zoom: \(error)")
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Capture error: \(error)")
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }

        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
        print("📸 Saved photo to gallery.")
    }
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("❌ Failed to save photo: \(error.localizedDescription)")
        } else {
            print("✅ Photo saved successfully!")
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
