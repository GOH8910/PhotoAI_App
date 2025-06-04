//
//  CameraPreview.swift
//  PhotoAI
//
//  Created by Edward Goh on 30/05/2025.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        guard let layer = previewLayer else { return view }
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(layer, at: 0)

        // Ensure the layer always matches the UIView’s bounds on rotation/layout:
        DispatchQueue.main.async {
            layer.frame = view.bounds
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Keep the layer resized if SwiftUI changes view size
        previewLayer?.frame = uiView.bounds
    }
}
