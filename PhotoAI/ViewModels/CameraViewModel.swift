//
//  CameraViewModel.swift
//  PhotoAI
//
//  Created by Edward Goh on 05/06/2025.
//

import Foundation
import Combine

class CameraViewModel: ObservableObject {
    @Published var frameState = CameraFrameState()
    private var cancellables = Set<AnyCancellable>()

    init(cameraService: CameraService) {
        cameraService.$shotType
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (shotType: ShotType) in
                self?.frameState.shotType = shotType
            }
            .store(in: &cancellables)
    }
}
