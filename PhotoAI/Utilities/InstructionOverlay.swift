//
//  InstructionOverlay.swift
//  PhotoAI
//
//  Created by Edward Goh on 05/06/2025.
//

import SwiftUI

struct InstructionOverlay: View {
    let message: String
    @Binding var isVisible: Bool

    var body: some View {
        Text(message)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
            .shadow(radius: 5)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}
