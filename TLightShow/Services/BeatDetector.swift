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

        var mean: Float = 0
        var stdDev: Float = 0

        vDSP_normalize(energies, 1, nil, 1, &mean, &stdDev, vDSP_Length(energies.count))

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

    /// Generate light frames from detected beats
    func generateLightFrames(
        from beats: [TimeInterval],
        duration: TimeInterval,
        lightCommand: LightCommand = .on,
        flashDuration: TimeInterval = 0.1
    ) -> [LightFrame] {
        var frames: [LightFrame] = []

        for beat in beats {
            // Add "on" frame at beat
            frames.append(LightFrame(
                timestamp: beat,
                lightCommand: lightCommand,
                closureCommand: .none
            ))

            // Add "off" frame shortly after
            if beat + flashDuration < duration {
                frames.append(LightFrame(
                    timestamp: beat + flashDuration,
                    lightCommand: .off,
                    closureCommand: .none
                ))
            }
        }

        return frames.sorted { $0.timestamp < $1.timestamp }
    }
}
