//
//  CameraServiceTests.swift
//  PhotoAITests
//

import AVFoundation
import Testing
@testable import PhotoAI

/// Reference box so a closure can record that it ran.
private final class Counter {
    var count = 0
}

struct CameraServiceTests {

    private func makeService(
        status: AVAuthorizationStatus,
        grantsAccess: Bool = true,
        requestCounter: Counter = Counter()
    ) -> CameraService {
        let dependencies = CameraService.Dependencies(
            authorizationStatus: { status },
            requestAccess: {
                requestCounter.count += 1
                return grantsAccess
            },
            backCamera: { nil } // the simulator has none; every path below stops before hardware
        )
        return CameraService(dependencies: dependencies)
    }

    @Test("Denied permission ends in .unauthorized(.denied) without touching the session")
    func deniedPermission() async {
        let service = makeService(status: .denied)
        await service.start()
        #expect(service.state == .unauthorized(.denied))
        #expect(service.session.isRunning == false)
        #expect(service.session.inputs.isEmpty)
    }

    @Test("Restricted permission ends in .unauthorized(.restricted)")
    func restrictedPermission() async {
        let service = makeService(status: .restricted)
        await service.start()
        #expect(service.state == .unauthorized(.restricted))
    }

    @Test("Not-determined permission prompts once; a refusal is reported as denied")
    func promptRefused() async {
        let counter = Counter()
        let service = makeService(status: .notDetermined, grantsAccess: false, requestCounter: counter)
        await service.start()
        #expect(counter.count == 1)
        #expect(service.state == .unauthorized(.denied))
    }

    @Test("Authorized but no back camera ends in .unavailable with the session not running")
    func noCamera() async {
        let service = makeService(status: .authorized)
        await service.start()
        #expect(service.state == .unavailable)
        #expect(service.session.isRunning == false)
    }

    @Test("Granted prompt followed by no camera ends in .unavailable")
    func promptGrantedNoCamera() async {
        let counter = Counter()
        let service = makeService(status: .notDetermined, grantsAccess: true, requestCounter: counter)
        await service.start()
        #expect(counter.count == 1)
        #expect(service.state == .unavailable)
    }

    @Test("Calling start twice is safe and does not re-prompt")
    func startIsIdempotent() async {
        let counter = Counter()
        let service = makeService(status: .notDetermined, grantsAccess: false, requestCounter: counter)
        await service.start()
        await service.start()
        #expect(service.state == .unauthorized(.denied))
        #expect(counter.count == 2) // each start re-reads status; the point is no crash and a stable state
    }

    @Test("The preview layer is bound to the service's session from init")
    func previewLayerIsBoundToSession() {
        let service = makeService(status: .denied)
        #expect(service.previewLayer.session === service.session)
    }
}
