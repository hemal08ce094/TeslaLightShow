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
    @State private var lightIntensity: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Preview label
            HStack {
                Image(systemName: "eye.fill")
                    .foregroundColor(.white)
                Text("Live Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()

                // Current time indicator
                Text(formatTime(currentTime))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(Color.black.opacity(0.9))

            // Car visualization
            ZStack {
                // Dark background
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Ground effect
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 2)
                    .blur(radius: 5)
                    .offset(y: 140)

                // Main car view
                carView
                    .scaleEffect(1.2)

                // Status panel at bottom
                statusPanel
                    .offset(y: 170)
            }
            .frame(height: 400)
        }
        .background(Color.black.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.5), radius: 10)
        .onChange(of: currentTime) { oldValue, newValue in
            updateCurrentState()
        }
        .onAppear {
            updateCurrentState()
        }
    }

    private var carView: some View {
        ZStack {
            // Tesla Model 3 Body
            teslaBody

            // Front lights (headlights)
            frontLights

            // Rear lights (taillights + light bar)
            rearLights

            // Side marker lights
            sideMarkers

            // Closure indicators (doors, trunk, frunk)
            closureIndicators
        }
    }

    private var teslaBody: some View {
        ZStack {
            // Main body
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.2, blue: 0.25),
                            Color(red: 0.15, green: 0.15, blue: 0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 280, height: 120)

            // Body highlight
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .frame(width: 280, height: 120)

            // Windshield
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 50)
                .offset(y: -10)

            // Wheels
            HStack(spacing: 180) {
                wheel
                wheel
            }
            .offset(y: 45)

            // Body outline
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 280, height: 120)
        }
    }

    private var wheel: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                .frame(width: 35, height: 35)

            Circle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 35, height: 35)

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 15, height: 15)
        }
    }

    private var frontLights: some View {
        HStack(spacing: 45) {
            // Left headlight
            headlight
            // Right headlight
            headlight
        }
        .offset(x: -105, y: 0)
    }

    private var headlight: some View {
        ZStack {
            // Outer glow
            if !currentLightState.isEmpty {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                getLightColor(currentLightState).opacity(0.6 * lightIntensity),
                                getLightColor(currentLightState).opacity(0.3 * lightIntensity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 10)
            }

            // Headlight housing
            Capsule()
                .fill(Color.black)
                .frame(width: 25, height: 15)

            // Light beam
            Capsule()
                .fill(getLightColor(currentLightState))
                .opacity(currentLightState.isEmpty ? 0.1 : lightIntensity)
                .frame(width: 23, height: 13)
                .shadow(
                    color: getLightColor(currentLightState),
                    radius: currentLightState.isEmpty ? 0 : 15 * lightIntensity
                )
        }
    }

    private var rearLights: some View {
        ZStack {
            // Light bar (signature Tesla feature)
            lightBar

            // Individual taillights
            HStack(spacing: 45) {
                taillight
                taillight
            }
            .offset(x: 105, y: 0)
        }
    }

    private var lightBar: some View {
        ZStack {
            // Glow effect
            if !currentLightState.isEmpty {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                getLightColor(currentLightState).opacity(0.4 * lightIntensity),
                                getLightColor(currentLightState).opacity(0.4 * lightIntensity),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 280, height: 20)
                    .blur(radius: 10)
                    .offset(x: 0, y: -50)
            }

            // Light bar itself
            RoundedRectangle(cornerRadius: 2)
                .fill(getLightColor(currentLightState))
                .opacity(currentLightState.isEmpty ? 0.1 : lightIntensity * 0.9)
                .frame(width: 260, height: 4)
                .shadow(
                    color: getLightColor(currentLightState),
                    radius: currentLightState.isEmpty ? 0 : 10 * lightIntensity
                )
                .offset(x: 0, y: -50)
        }
    }

    private var taillight: some View {
        ZStack {
            // Outer glow
            if !currentLightState.isEmpty {
                Capsule()
                    .fill(
                        RadialGradient(
                            colors: [
                                getLightColor(currentLightState).opacity(0.5 * lightIntensity),
                                getLightColor(currentLightState).opacity(0.2 * lightIntensity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 25
                        )
                    )
                    .frame(width: 50, height: 50)
                    .blur(radius: 8)
            }

            // Taillight housing
            Capsule()
                .fill(Color.black)
                .frame(width: 12, height: 30)

            // Light
            Capsule()
                .fill(getLightColor(currentLightState))
                .opacity(currentLightState.isEmpty ? 0.1 : lightIntensity * 0.8)
                .frame(width: 10, height: 28)
                .shadow(
                    color: getLightColor(currentLightState),
                    radius: currentLightState.isEmpty ? 0 : 12 * lightIntensity
                )
        }
    }

    private var sideMarkers: some View {
        HStack(spacing: 200) {
            // Left side markers
            VStack(spacing: 40) {
                sideMarker
                sideMarker
            }

            // Right side markers
            VStack(spacing: 40) {
                sideMarker
                sideMarker
            }
        }
    }

    private var sideMarker: some View {
        Circle()
            .fill(getLightColor(currentLightState))
            .opacity(currentLightState.isEmpty ? 0.05 : lightIntensity * 0.5)
            .frame(width: 6, height: 6)
            .shadow(
                color: getLightColor(currentLightState),
                radius: currentLightState.isEmpty ? 0 : 5 * lightIntensity
            )
    }

    private var closureIndicators: some View {
        VStack(spacing: 8) {
            if !currentClosureState.isEmpty {
                // Animated closure indicator
                ZStack {
                    Capsule()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 100, height: 30)

                    HStack(spacing: 8) {
                        Image(systemName: getClosureIcon(currentClosureState))
                            .font(.title3)
                            .foregroundColor(.purple)

                        Text(getClosureText(currentClosureState))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
                .shadow(color: .purple.opacity(0.5), radius: 10)
            }
        }
        .offset(y: 80)
    }

    private var statusPanel: some View {
        HStack(spacing: 40) {
            // Light status
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(getLightColor(currentLightState).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "lightbulb.fill")
                        .font(.title2)
                        .foregroundColor(currentLightState.isEmpty ? .gray : getLightColor(currentLightState))
                }

                Text(getLightCommandName(currentLightState))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 90)
                    .lineLimit(1)
            }

            // Intensity indicator
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Text("\(Int(lightIntensity * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                Text("Intensity")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }

            // Closure status
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: currentClosureState.isEmpty ? "car.fill" : "car.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentClosureState.isEmpty ? .gray : .purple)
                }

                Text(currentClosureState.isEmpty ? "Closed" : getClosureText(currentClosureState))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 90)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(Color.black.opacity(0.7))
        .cornerRadius(25)
    }

    private func updateCurrentState() {
        // Find the most recent frame before or at current time
        let relevantFrames = frames.filter { $0.timestamp <= currentTime }

        // Update light state
        if let lastLightFrame = relevantFrames.last(where: { !$0.lightCommand.isEmpty }) {
            let timeSinceFrame = currentTime - lastLightFrame.timestamp

            // Calculate intensity based on command type
            switch lastLightFrame.lightCommand {
            case "F": // Instant on
                if timeSinceFrame < 0.1 {
                    withAnimation(.easeOut(duration: 0.05)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = 1.0
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        currentLightState = ""
                        lightIntensity = 0.0
                    }
                }

            case "E": // Ramp 500ms
                if timeSinceFrame < 0.5 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(timeSinceFrame / 0.5)
                    }
                } else {
                    currentLightState = lastLightFrame.lightCommand
                    lightIntensity = 1.0
                }

            case "D": // Ramp 1000ms
                if timeSinceFrame < 1.0 {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(timeSinceFrame / 1.0)
                    }
                } else {
                    currentLightState = lastLightFrame.lightCommand
                    lightIntensity = 1.0
                }

            case "C": // Ramp 2000ms
                if timeSinceFrame < 2.0 {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(timeSinceFrame / 2.0)
                    }
                } else {
                    currentLightState = lastLightFrame.lightCommand
                    lightIntensity = 1.0
                }

            case "W": // Ramp off 500ms
                if timeSinceFrame < 0.5 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(1.0 - (timeSinceFrame / 0.5))
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        currentLightState = ""
                        lightIntensity = 0.0
                    }
                }

            case "S": // Ramp off 1000ms
                if timeSinceFrame < 1.0 {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(1.0 - (timeSinceFrame / 1.0))
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        currentLightState = ""
                        lightIntensity = 0.0
                    }
                }

            case "X": // Ramp off 2000ms
                if timeSinceFrame < 2.0 {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        currentLightState = lastLightFrame.lightCommand
                        lightIntensity = CGFloat(1.0 - (timeSinceFrame / 2.0))
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        currentLightState = ""
                        lightIntensity = 0.0
                    }
                }

            default:
                currentLightState = ""
                lightIntensity = 0.0
            }
        } else {
            currentLightState = ""
            lightIntensity = 0.0
        }

        // Update closure state
        if let lastClosureFrame = relevantFrames.last(where: { !$0.closureCommand.isEmpty }) {
            currentClosureState = lastClosureFrame.closureCommand
        } else {
            currentClosureState = ""
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
        default: return "CLOSED"
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

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, milliseconds)
    }
}
