//
//  CameraStateTests.swift
//  PhotoAITests
//

import AVFoundation
import Testing
@testable import PhotoAI

struct CameraStateTests {

    @Test("Every AVAuthorizationStatus maps to the matching CameraAuthorization", arguments: [
        (AVAuthorizationStatus.authorized, CameraAuthorization.authorized),
        (AVAuthorizationStatus.denied, CameraAuthorization.denied),
        (AVAuthorizationStatus.restricted, CameraAuthorization.restricted),
        (AVAuthorizationStatus.notDetermined, CameraAuthorization.notDetermined),
    ])
    func mapsAuthorizationStatus(status: AVAuthorizationStatus, expected: CameraAuthorization) {
        #expect(CameraAuthorization(status) == expected)
    }

    @Test("Blocked states compare by case and payload")
    func statesAreEquatable() {
        #expect(CameraState.unauthorized(.denied) == CameraState.unauthorized(.denied))
        #expect(CameraState.unauthorized(.denied) != CameraState.unauthorized(.restricted))
        #expect(CameraState.failed(.cannotAddInput) != CameraState.failed(.cannotAddOutput))
        #expect(CameraState.unavailable != CameraState.running)
    }
}
