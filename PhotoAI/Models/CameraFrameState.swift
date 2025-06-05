//
//  CameraFrameState.swift
//  PhotoAI
//
//  Created by Edward Goh on 05/06/2025.
//

import Foundation


struct CameraFrameState {
    var shotType: ShotType = .none
    
    var instruction: String {
        switch shotType {
        case .fullBody:
            return "fullBody"
        case .halfBody:
            return "halfBody"
        case .faceOnly:
            return "faceOnly"
        case .none:
            return "Center yourself in the frame"
        }
    }
}
