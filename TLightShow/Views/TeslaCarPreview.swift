//
//  TeslaCarPreview.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI

struct TeslaCarPreview: View {
    let frames: [LightFrame]
    let currentTime: TimeInterval

    @State private var currentLightState: String = ""
    @State private var currentClosureState: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.9))

                VStack(spacing: 20) {
                    // Car representation
                    carView

                    // Status indicators
                    HStack(spacing: 30) {
                        statusIndicator(
                            title: "Lights",
                            command: currentLightState,
                            icon: "lightbulb.fill",
                            color: getLightColor(currentLightState)
                        )

                        statusIndicator(
                            title: "Closures",
                            command: currentClosureState,
                            icon: "car.fill",
                            color: .purple
                        )
                    }
                }
                .padding()
            }
        }
        .onChange(of: currentTime) { _ in
            updateCurrentState()
        }
        .onAppear {
            updateCurrentState()
        }
    }

    private var carView: some View {
        ZStack {
            // Car body
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 100)

            // Car outline
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 200, height: 100)

            HStack(spacing: 60) {
                // Front lights
                VStack(spacing: 10) {
                    Circle()
                        .fill(getLightColor(currentLightState))
                        .frame(width: 12, height: 12)
                        .shadow(color: getLightColor(currentLightState), radius: currentLightState.isEmpty ? 0 : 10)

                    Circle()
                        .fill(getLightColor(currentLightState))
                        .frame(width: 12, height: 12)
                        .shadow(color: getLightColor(currentLightState), radius: currentLightState.isEmpty ? 0 : 10)
                }
                .offset(x: -50)

                // Rear lights
                VStack(spacing: 10) {
                    Circle()
                        .fill(getLightColor(currentLightState).opacity(0.8))
                        .frame(width: 12, height: 12)
                        .shadow(color: getLightColor(currentLightState), radius: currentLightState.isEmpty ? 0 : 8)

                    Circle()
                        .fill(getLightColor(currentLightState).opacity(0.8))
                        .frame(width: 12, height: 12)
                        .shadow(color: getLightColor(currentLightState), radius: currentLightState.isEmpty ? 0 : 8)
                }
                .offset(x: 50)
            }

            // Doors (closures) indicator
            if !currentClosureState.isEmpty {
                VStack {
                    Text(getClosureText(currentClosureState))
                        .font(.caption)
                        .foregroundColor(.purple)
                        .fontWeight(.bold)
                }
                .offset(y: 50)
            }
        }
    }

    private func statusIndicator(title: String, command: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(command.isEmpty ? .gray : color)

            Text(title)
                .font(.caption)
                .foregroundColor(.white)

            Text(command.isEmpty ? "Off" : getLightCommandName(command))
                .font(.caption2)
                .foregroundColor(.gray)
                .frame(width: 80)
        }
    }

    private func updateCurrentState() {
        // Find the most recent frame before or at current time
        let relevantFrames = frames.filter { $0.timestamp <= currentTime }

        if let lastLightFrame = relevantFrames.last(where: { !$0.lightCommand.isEmpty }) {
            currentLightState = lastLightFrame.lightCommand
        } else {
            currentLightState = ""
        }

        if let lastClosureFrame = relevantFrames.last(where: { !$0.closureCommand.isEmpty }) {
            currentClosureState = lastClosureFrame.closureCommand
        } else {
            currentClosureState = ""
        }

        // Check if light should be off based on time since last command
        if let lastFrame = relevantFrames.last(where: { !$0.lightCommand.isEmpty }) {
            let timeSinceFrame = currentTime - lastFrame.timestamp
            if timeSinceFrame > 0.2 && lastFrame.lightCommand == "F" {
                // Auto-off for quick flashes
                currentLightState = ""
            }
        }
    }

    private func getLightColor(_ command: String) -> Color {
        switch command {
        case "F": return .yellow
        case "E", "D", "C": return .orange
        case "W", "S", "X": return .blue
        default: return .gray.opacity(0.3)
        }
    }

    private func getLightCommandName(_ command: String) -> String {
        switch command {
        case "F": return "On"
        case "E": return "Ramp 500ms"
        case "D": return "Ramp 1s"
        case "C": return "Ramp 2s"
        case "W": return "Off 500ms"
        case "S": return "Off 1s"
        case "X": return "Off 2s"
        default: return "Off"
        }
    }

    private func getClosureText(_ command: String) -> String {
        switch command {
        case "Q": return "OPEN"
        case "A": return "DANCE"
        case "Z": return "CLOSE"
        case "F": return "STOP"
        default: return ""
        }
    }
}
