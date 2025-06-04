//
//  CameraFrame.swift
//  PhotoAI
//
//  Created by Edward Goh on 04/06/2025.
//

import SwiftUI

import SwiftUI

struct CameraFrame<Content: View>: View {
    let aspectRatio: CGFloat
    let showGrid: Bool
    let content: () -> Content
    
    init(
        aspectRatio: CGFloat = 3/4,
        showGrid: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.aspectRatio = aspectRatio
        self.showGrid = showGrid
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer().frame(height: 60) // adds space above camera
                
                ZStack {
                    content()
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .clipped()
                    
                    if showGrid {
                        GridOverlayView()
                            .aspectRatio(aspectRatio, contentMode: .fit)
                            .frame(width: geometry.size.width)
                        
                    }
                }
            }
        }
    }
}
