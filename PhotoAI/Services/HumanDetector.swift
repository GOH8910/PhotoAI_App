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

            let height = person.boundingBox.height // Normalized [0-1]
            if height >= 0.8 {
                completion(.faceOnly)
            } else if height >= 0.4 {
                completion(.halfBody)
            } else {
                completion(.fullBody)
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}
