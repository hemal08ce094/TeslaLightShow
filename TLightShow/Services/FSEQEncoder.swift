//
//  FSEQEncoder.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import Foundation

class FSEQEncoder {

    /// Export light show project to .fseq file format (V2 Uncompressed)
    func exportToFSEQ(project: LightShowProject) throws -> Data {
        // FSEQ V2 Format Specification
        // Header: 32 bytes minimum
        // Magic: "PSEQ" (4 bytes)
        // Channel data offset: 2 bytes
        // Minor version: 1 byte
        // Major version: 1 byte
        // Variable header length: 2 bytes
        // Channel count: 4 bytes
        // Frame count: 4 bytes
        // Frame step time (ms): 1 byte
        // Flags: 1 byte (bit 1 = uncompressed)
        // Compression type: 1 byte
        // Number of compression blocks: 1 byte
        // Number of sparse ranges: 1 byte
        // Reserved: 1 byte
        // Unique ID: 8 bytes

        var data = Data()

        // Calculate frame count and step time
        let frameCount = UInt32(project.duration / project.frameInterval)
        let stepTimeMs = UInt8(project.frameInterval * 1000) // Convert to milliseconds

        // Number of channels (we'll use 96 channels to represent different light/closure commands)
        let channelCount: UInt32 = 96

        // Magic number "PSEQ"
        data.append(contentsOf: [0x50, 0x53, 0x45, 0x51]) // "PSEQ"

        // Channel data offset (after header)
        let headerSize: UInt16 = 32
        data.append(contentsOf: withUnsafeBytes(of: headerSize.littleEndian) { Array($0) })

        // Version (2.0)
        data.append(0) // Minor
        data.append(2) // Major

        // Variable header length
        let variableHeaderLength: UInt16 = 0
        data.append(contentsOf: withUnsafeBytes(of: variableHeaderLength.littleEndian) { Array($0) })

        // Channel count
        data.append(contentsOf: withUnsafeBytes(of: channelCount.littleEndian) { Array($0) })

        // Frame count
        data.append(contentsOf: withUnsafeBytes(of: frameCount.littleEndian) { Array($0) })

        // Frame step time
        data.append(stepTimeMs)

        // Flags (bit 1 set for uncompressed)
        data.append(0x02)

        // Compression type (0 = none)
        data.append(0)

        // Number of compression blocks
        data.append(0)

        // Number of sparse ranges
        data.append(0)

        // Reserved
        data.append(0)

        // Unique ID (8 bytes) - use project ID
        let uuid = project.id.uuid
        data.append(contentsOf: [
            uuid.0, uuid.1, uuid.2, uuid.3,
            uuid.4, uuid.5, uuid.6, uuid.7
        ])

        // Generate frame data
        let frameData = generateFrameData(project: project, channelCount: Int(channelCount), frameCount: Int(frameCount))
        data.append(frameData)

        return data
    }

    private func generateFrameData(project: LightShowProject, channelCount: Int, frameCount: Int) -> Data {
        var data = Data()

        // Create a map of timestamp to frame
        var frameMap: [Int: LightFrame] = [:]
        for frame in project.frames {
            let frameIndex = Int(frame.timestamp / project.frameInterval)
            if frameIndex < frameCount {
                frameMap[frameIndex] = frame
            }
        }

        // Generate data for each frame
        for frameIndex in 0..<frameCount {
            var channelData = [UInt8](repeating: 0, count: channelCount)

            if let frame = frameMap[frameIndex] {
                // Map commands to channel values
                // Channels 0-15: Light commands (mapped from key codes)
                if let lightValue = mapLightCommandToChannel(frame.lightCommand) {
                    channelData[lightValue.channel] = lightValue.value
                }

                // Channels 16-31: Closure commands
                if let closureValue = mapClosureCommandToChannel(frame.closureCommand) {
                    channelData[closureValue.channel] = closureValue.value
                }
            }

            data.append(contentsOf: channelData)
        }

        return data
    }

    private func mapLightCommandToChannel(_ command: String) -> (channel: Int, value: UInt8)? {
        switch command {
        case "F": return (0, 255)  // On
        case "E": return (1, 255)  // Ramp On 500ms
        case "D": return (2, 255)  // Ramp On 1000ms
        case "C": return (3, 255)  // Ramp On 2000ms
        case "W": return (4, 255)  // Ramp Off 500ms
        case "S": return (5, 255)  // Ramp Off 1000ms
        case "X": return (6, 255)  // Ramp Off 2000ms
        default: return nil
        }
    }

    private func mapClosureCommandToChannel(_ command: String) -> (channel: Int, value: UInt8)? {
        switch command {
        case "Q": return (16, 255) // Open
        case "A": return (17, 255) // Dance
        case "Z": return (18, 255) // Close
        case "F": return (19, 255) // Stop
        default: return nil
        }
    }

    /// Export complete light show package (fseq + audio)
    func exportLightShowPackage(project: LightShowProject, outputDirectory: URL) throws -> (fseqURL: URL, audioURL: URL) {
        // Export FSEQ file
        let fseqData = try exportToFSEQ(project: project)
        let fseqURL = outputDirectory.appendingPathComponent("\(project.name).fseq")
        try fseqData.write(to: fseqURL)

        // Copy audio file
        guard let sourceAudioURL = project.audioFileURL else {
            throw NSError(domain: "FSEQEncoder", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio file found"])
        }

        let audioExtension = sourceAudioURL.pathExtension
        let audioURL = outputDirectory.appendingPathComponent("\(project.name).\(audioExtension)")

        if FileManager.default.fileExists(atPath: audioURL.path) {
            try FileManager.default.removeItem(at: audioURL)
        }

        try FileManager.default.copyItem(at: sourceAudioURL, to: audioURL)

        return (fseqURL, audioURL)
    }
}
