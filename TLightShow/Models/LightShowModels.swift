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
        case id, name, audioFileName, frames, duration, frameInterval, createdDate, modifiedDate
    }
}

// MARK: - Beat Detection Result
struct BeatDetection {
    var beats: [TimeInterval] // timestamps of detected beats
    var tempo: Double // BPM
    var confidence: Double // 0-1
}
