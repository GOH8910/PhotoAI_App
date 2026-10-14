//
//  CameraBlockedViewTests.swift
//  PhotoAITests
//

import Testing
@testable import PhotoAI

struct CameraBlockedViewTests {

    @Test("Only a denied permission offers the Settings link")
    func settingsLinkOnlyWhenDenied() {
        #expect(CameraBlockedView.offersSettings(for: .unauthorized(.denied)))
        #expect(!CameraBlockedView.offersSettings(for: .unauthorized(.restricted)))
        #expect(!CameraBlockedView.offersSettings(for: .unavailable))
        #expect(!CameraBlockedView.offersSettings(for: .failed(.cannotAddInput)))
    }

    @Test("Each blocked state has its own title and message")
    func copyPerState() {
        let states: [CameraState] = [
            .unauthorized(.denied), .unauthorized(.restricted), .unavailable, .failed(.cannotAddOutput),
        ]
        let titles = Set(states.map { CameraBlockedView.title(for: $0) })
        let messages = Set(states.map { CameraBlockedView.message(for: $0) })
        #expect(titles.count == 3) // denied and restricted share a title
        #expect(messages.count == 4)
        for state in states {
            #expect(!CameraBlockedView.title(for: state).isEmpty)
            #expect(!CameraBlockedView.message(for: state).isEmpty)
        }
    }

    @Test("Restricted copy names Screen Time; denied copy points to Settings")
    func copyContent() {
        #expect(CameraBlockedView.message(for: .unauthorized(.restricted)).contains("Screen Time"))
        #expect(CameraBlockedView.message(for: .unauthorized(.denied)).contains("Settings"))
        #expect(CameraBlockedView.message(for: .unavailable).contains("back camera"))
    }

    @Test("Only a failed configuration offers Try Again")
    func retryOnlyWhenFailed() {
        #expect(CameraBlockedView.offersRetry(for: .failed(.cannotAddOutput)))
        #expect(!CameraBlockedView.offersRetry(for: .unauthorized(.denied)))
        #expect(!CameraBlockedView.offersRetry(for: .unavailable))
    }
}
