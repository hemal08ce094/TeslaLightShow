//
//  BeatDetector.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import Foundation
import AVFoundation
import Accelerate

class BeatDetector {

    /// Detect beats in an audio file using energy-based algorithm
    func detectBeats(from url: URL, sensitivity: Float = 1.5) throws -> BeatDetection {
        let audioFile = try AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw NSError(domain: "BeatDetector", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create buffer"])
        }

        try audioFile.read(into: buffer)

        guard let floatChannelData = buffer.floatChannelData else {
            throw NSError(domain: "BeatDetector", code: -2, userInfo: [NSLocalizedDescriptionKey: "No audio data"])
        }

        let channelData = floatChannelData[0]
        let sampleRate = format.sampleRate

        // Calculate energy in windows
        let windowSize = 1024
        let hopSize = 512
        var energies: [Float] = []
        var timestamps: [TimeInterval] = []

        for i in stride(from: 0, to: Int(frameCount) - windowSize, by: hopSize) {
            var energy: Float = 0
            vDSP_svesq(channelData.advanced(by: i), 1, &energy, vDSP_Length(windowSize))
            energies.append(energy / Float(windowSize))
            timestamps.append(TimeInterval(i) / sampleRate)
        }

        // Find peaks in energy (potential beats)
        var beats: [TimeInterval] = []
        let threshold = calculateDynamicThreshold(energies: energies, sensitivity: sensitivity)

        for i in 1..<energies.count - 1 {
            let current = energies[i]
            let prev = energies[i - 1]
            let next = energies[i + 1]

            // Peak detection: current is higher than neighbors and above threshold
            if current > prev && current > next && current > threshold {
                beats.append(timestamps[i])
            }
        }

        // Calculate tempo (BPM)
        let tempo = calculateTempo(beats: beats)

        return BeatDetection(beats: beats, tempo: tempo, confidence: 0.8)
    }

    private func calculateDynamicThreshold(energies: [Float], sensitivity: Float) -> Float {
        guard !energies.isEmpty else { return 0 }

        // Calculate mean
        var mean: Float = 0
        vDSP_meanv(energies, 1, &mean, vDSP_Length(energies.count))

        // Calculate standard deviation
        var differences = [Float](repeating: 0, count: energies.count)
        var negativeMean = -mean
        vDSP_vsadd(energies, 1, &negativeMean, &differences, 1, vDSP_Length(energies.count))

        var squaredDifferences = [Float](repeating: 0, count: energies.count)
        vDSP_vsq(differences, 1, &squaredDifferences, 1, vDSP_Length(energies.count))

        var variance: Float = 0
        vDSP_meanv(squaredDifferences, 1, &variance, vDSP_Length(energies.count))

        let stdDev = sqrt(variance)

        return mean + (stdDev * sensitivity)
    }

    private func calculateTempo(beats: [TimeInterval]) -> Double {
        guard beats.count > 1 else { return 120.0 }

        var intervals: [TimeInterval] = []
        for i in 1..<beats.count {
            intervals.append(beats[i] - beats[i - 1])
        }

        // Calculate average interval
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)

        // Convert to BPM (beats per minute)
        let bpm = 60.0 / avgInterval

        // Clamp to reasonable range
        return min(max(bpm, 60), 180)
    }

    enum PatternStrategy: String, CaseIterable, Identifiable {
        case balanced = "Balanced"
        case chill = "Chill"
        case party = "Party"
        
        var id: String { rawValue }
    }

    /// Generate light frames from detected beats with intelligent variation
    func generateLightFrames(
        from beats: [TimeInterval],
        duration: TimeInterval,
        strategy: PatternStrategy = .balanced,
        flashDuration: TimeInterval = 0.1
    ) -> [LightFrame] {
        var frames: [LightFrame] = []

        for (index, beat) in beats.enumerated() {
            // Vary light commands based on beat intensity, position, and strategy
            let currentLightCommand = selectLightCommand(for: index, total: beats.count, strategy: strategy)
            let currentClosureCommand = selectClosureCommand(for: index, beat: beat, duration: duration, strategy: strategy)

            // Add main frame at beat
            frames.append(LightFrame(
                timestamp: beat,
                lightCommand: currentLightCommand,
                closureCommand: currentClosureCommand
            ))

            // Add "off" frame for flash effects only
            if shouldFlash(command: currentLightCommand, strategy: strategy) && beat + flashDuration < duration {
                frames.append(LightFrame(
                    timestamp: beat + flashDuration,
                    lightCommand: .off,
                    closureCommand: .none
                ))
            }
        }

        return frames.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func shouldFlash(command: LightCommand, strategy: PatternStrategy) -> Bool {
        if command != .on { return false }
        
        switch strategy {
        case .chill: return false // Chill mode rarely flashes hard
        case .party: return true  // Party mode always flashes
        case .balanced: return true
        }
    }

    private func selectLightCommand(for index: Int, total: Int, strategy: PatternStrategy) -> LightCommand {
        let position = Double(index) / Double(max(total - 1, 1))

        switch strategy {
        case .chill:
            // Chill: Mostly ramps, very few hard on/offs
            return [.rampOn500, .rampOn1000, .rampOn2000, .rampOff1000, .rampOff2000].randomElement() ?? .rampOn1000
            
        case .party:
            // Party: Mostly hard flashes, fast ramps
            if index % 2 == 0 { return .on }
            return [.on, .rampOn500, .rampOff500].randomElement() ?? .on
            
        case .balanced:
            // Balanced: The original logic
            switch position {
            case 0..<0.2:
                return [.rampOn500, .rampOn1000].randomElement() ?? .rampOn500
            case 0.2..<0.4:
                return [.on, .rampOn500, .rampOn1000].randomElement() ?? .on
            case 0.4..<0.6:
                return [.on, .on, .on, .rampOn500].randomElement() ?? .on
            case 0.6..<0.8:
                return [.on, .rampOff500, .rampOff1000].randomElement() ?? .on
            default:
                return [.rampOff500, .rampOff1000, .rampOff2000].randomElement() ?? .rampOff500
            }
        }
    }

    private func selectClosureCommand(for index: Int, beat: TimeInterval, duration: TimeInterval, strategy: PatternStrategy) -> ClosureCommand {
        // Only add closure commands if explicitly requested or in specific patterns
        // For safety, we'll be conservative with closure commands
        
        if strategy == .chill { return .none } // No moving parts in chill mode
        
        let position = beat / duration

        // Add closure commands sparingly for dramatic effect
        if index % 16 == 0 { // Every 16th beat (less frequent)
            switch position {
            case 0..<0.25:
                return .open
            case 0.25..<0.5:
                return .dance
            case 0.5..<0.75:
                return .dance
            default:
                return .close
            }
        }

        return .none
    }
}
