//
//  WaveformView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI

struct WaveformView: View {
    let audioLevels: [Float]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 1) {
                ForEach(0..<min(audioLevels.count, 200), id: \.self) { index in
                    let normalizedLevel = CGFloat(audioLevels[index])
                    let barHeight = max(normalizedLevel * geometry.size.height, 2)

                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .frame(width: geometry.size.width / 200, height: barHeight)
                        .frame(height: geometry.size.height, alignment: .center)
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
