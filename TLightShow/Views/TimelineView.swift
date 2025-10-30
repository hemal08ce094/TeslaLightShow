//
//  TimelineView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI

struct TimelineView: View {
    let frames: [LightFrame]
    let duration: TimeInterval
    let currentTime: TimeInterval
    let onFrameTapped: (LightFrame) -> Void
    let onTimelineTapped: (TimeInterval) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                // Time markers
                if duration > 0 {
                    ForEach(0..<Int(duration) + 1, id: \.self) { second in
                        let xPosition = CGFloat(second) / CGFloat(duration) * geometry.size.width

                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 1, height: 10)

                        Text("\(second)s")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                    .offset(x: xPosition)
                    }

                    // Frames
                    ForEach(frames) { frame in
                        let xPosition = CGFloat(frame.timestamp) / CGFloat(duration) * geometry.size.width

                    Button(action: {
                        onFrameTapped(frame)
                    }) {
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(getLightColor(frame.lightCommand))
                                .frame(width: 3, height: geometry.size.height * 0.6)
                                .cornerRadius(1.5)

                            if !frame.closureCommand.isEmpty {
                                Circle()
                                    .fill(Color.purple)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    .offset(x: xPosition - 1.5)
                    }

                    // Current time indicator
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .offset(x: CGFloat(currentTime) / CGFloat(duration) * geometry.size.width - 1)
                }
            }
            .onTapGesture { location in
                guard duration > 0 else { return }
                let tappedTime = Double(location.x / geometry.size.width) * duration
                onTimelineTapped(tappedTime)
            }
        }
    }

    private func getLightColor(_ command: String) -> Color {
        switch command {
        case "F": return .yellow
        case "E", "D", "C": return .orange
        case "W", "S", "X": return .blue
        default: return .gray
        }
    }
}
