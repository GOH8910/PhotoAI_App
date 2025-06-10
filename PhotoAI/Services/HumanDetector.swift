//
//  HumanDetector.swift
//  PhotoAI
//
//  Created by Edward Goh on 05/06/2025.
//

import Vision
import CoreVideo

struct HumanDetector {

    static func detectHuman(in pixelBuffer: CVPixelBuffer, completion: @escaping (ShotType) -> Void) {
        let request = VNDetectHumanRectanglesRequest { request, error in
            guard let results = request.results as? [VNHumanObservation],
                  let person = results.first else {
                completion(.none)
                return
            }

            let shotType = classify(from: person.boundingBox.height)
            completion(shotType)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }

    // ✅ Add this for unit testing
    static func classify(from height: CGFloat) -> ShotType {
        if height >= 0.8 {
            return .faceOnly
        } else if height >= 0.4 {
            return .halfBody
        } else {
            return .fullBody
        }
    }
}
