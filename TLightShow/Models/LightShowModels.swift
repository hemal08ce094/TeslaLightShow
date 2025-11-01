//
//  LightShowModels.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Light Command Types
enum LightCommand: String, CaseIterable, Identifiable {
    case off = "Off"
    case on = "On"
    case rampOn500 = "Ramp On 500ms"
    case rampOn1000 = "Ramp On 1s"
    case rampOn2000 = "Ramp On 2s"
    case rampOff500 = "Ramp Off 500ms"
    case rampOff1000 = "Ramp Off 1s"
    case rampOff2000 = "Ramp Off 2s"

    var id: String { rawValue }

    var keyCode: String {
        switch self {
        case .off: return ""
        case .on: return "F"
        case .rampOn500: return "E"
        case .rampOn1000: return "D"
        case .rampOn2000: return "C"
        case .rampOff500: return "W"
        case .rampOff1000: return "S"
        case .rampOff2000: return "X"
        }
    }

    var color: Color {
        switch self {
        case .off: return .gray
        case .on: return .yellow
        case .rampOn500, .rampOn1000, .rampOn2000: return .orange
        case .rampOff500, .rampOff1000, .rampOff2000: return .blue
        }
    }
}

// MARK: - Closure Command Types
enum ClosureCommand: String, CaseIterable, Identifiable {
    case none = "None"
    case open = "Open"
    case dance = "Dance"
    case close = "Close"
    case stop = "Stop"

    var id: String { rawValue }

    var keyCode: String {
        switch self {
        case .none: return ""
        case .open: return "Q"
        case .dance: return "A"
        case .close: return "Z"
        case .stop: return "F"
        }
    }
}

// MARK: - Light Show Frame
struct LightFrame: Identifiable, Codable {
    let id: UUID
    var timestamp: TimeInterval // in seconds
    var lightCommand: String
    var closureCommand: String

    init(id: UUID = UUID(), timestamp: TimeInterval, lightCommand: LightCommand, closureCommand: ClosureCommand) {
        self.id = id
        self.timestamp = timestamp
        self.lightCommand = lightCommand.keyCode
        self.closureCommand = closureCommand.keyCode
    }
}

// MARK: - Light Show Project
struct LightShowProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var audioFileName: String
    var audioFileURL: URL?
    var frames: [LightFrame]
    var duration: TimeInterval
    var frameInterval: TimeInterval // in seconds (0.02 = 20ms recommended)
    var createdDate: Date
    var modifiedDate: Date

    init(id: UUID = UUID(),
         name: String,
         audioFileName: String = "",
         audioFileURL: URL? = nil,
         frames: [LightFrame] = [],
         duration: TimeInterval = 0,
         frameInterval: TimeInterval = 0.02) {
        self.id = id
        self.name = name
        self.audioFileName = audioFileName
        self.audioFileURL = audioFileURL
        self.frames = frames
        self.duration = duration
        self.frameInterval = frameInterval
        self.createdDate = Date()
        self.modifiedDate = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id, name, audioFileName, audioFileURLPath, frames, duration, frameInterval, createdDate, modifiedDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        audioFileName = try container.decode(String.self, forKey: .audioFileName)
        frames = try container.decode([LightFrame].self, forKey: .frames)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        frameInterval = try container.decode(TimeInterval.self, forKey: .frameInterval)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)

        if let urlPath = try container.decodeIfPresent(String.self, forKey: .audioFileURLPath) {
            audioFileURL = URL(fileURLWithPath: urlPath)
        } else {
            audioFileURL = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(audioFileName, forKey: .audioFileName)
        try container.encode(frames, forKey: .frames)
        try container.encode(duration, forKey: .duration)
        try container.encode(frameInterval, forKey: .frameInterval)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
        try container.encodeIfPresent(audioFileURL?.path(), forKey: .audioFileURLPath)
    }
}

// MARK: - Beat Detection Result
struct BeatDetection {
    var beats: [TimeInterval] // timestamps of detected beats
    var tempo: Double // BPM
    var confidence: Double // 0-1
}
