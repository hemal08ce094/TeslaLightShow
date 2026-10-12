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
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                // Time markers
                if duration > 0 {
                    ForEach(0..<Int(duration) + 1, id: \.self) { second in
                        let xPosition = CGFloat(second) / CGFloat(duration) * geometry.size.width
                        
                        // Only show every 5th second if duration is long, or every second if short
                        if duration <= 30 || second % 5 == 0 {
                            VStack(spacing: 2) {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 1, height: geometry.size.height)
                                
                                Text("\(second)s")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .offset(y: -geometry.size.height - 15)
                            }
                            .offset(x: xPosition)
                        }
                    }

                    // Frames
                    ForEach(frames) { frame in
                        let xPosition = CGFloat(frame.timestamp) / CGFloat(duration) * geometry.size.width

                        Button(action: {
                            onFrameTapped(frame)
                        }) {
                            VStack(spacing: 1) {
                                // Light command bar
                                Rectangle()
                                    .fill(getLightColor(frame.lightCommand))
                                    .frame(
                                        width: getFrameWidth(frame.lightCommand),
                                        height: getFrameHeight(frame.lightCommand, maxHeight: geometry.size.height * 0.6)
                                    )
                                    .cornerRadius(2)
                                    .shadow(
                                        color: getLightColor(frame.lightCommand),
                                        radius: 4
                                    )

                                // Closure command indicator
                                if !frame.closureCommand.isEmpty {
                                    Image(systemName: getClosureIcon(frame.closureCommand))
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.purple)
                                }
                            }
                        }
                        .offset(x: xPosition - getFrameWidth(frame.lightCommand) / 2)
                    }

                    // Current time indicator (Playhead)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 2)
                        .shadow(color: .red.opacity(0.5), radius: 4)
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

    private func getFrameHeight(_ command: String, maxHeight: CGFloat) -> CGFloat {
        switch command {
        case "F": return maxHeight // Instant on - tallest
        case "E": return maxHeight * 0.8 // Ramp 500ms
        case "D": return maxHeight * 0.9 // Ramp 1000ms
        case "C": return maxHeight // Ramp 2000ms - tallest
        case "W": return maxHeight * 0.6 // Ramp off 500ms
        case "S": return maxHeight * 0.7 // Ramp off 1000ms
        case "X": return maxHeight * 0.8 // Ramp off 2000ms
        default: return maxHeight * 0.3
        }
    }

    private func getFrameWidth(_ command: String) -> CGFloat {
        switch command {
        case "F": return 4 // Instant on - thicker
        case "E", "D", "C": return 3 // Ramps
        case "W", "S", "X": return 3 // Ramp offs
        default: return 2
        }
    }

    private func getClosureIcon(_ command: String) -> String {
        switch command {
        case "Q": return "door.left.hand.open"
        case "A": return "figure.dance"
        case "Z": return "door.left.hand.closed"
        case "F": return "hand.raised.fill"
        default: return "car.fill"
        }
    }
}
