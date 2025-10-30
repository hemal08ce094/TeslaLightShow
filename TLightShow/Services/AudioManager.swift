//
//  AudioManager.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class AudioManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var audioLevels: [Float] = []

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var audioFile: AVAudioFile?

    override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func loadAudio(from url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.delegate = self
        duration = audioPlayer?.duration ?? 0

        // Load audio file for waveform
        audioFile = try AVAudioFile(forReading: url)
        extractAudioLevels()
    }

    func play() {
        audioPlayer?.play()
        isPlaying = true
        startDisplayLink()
    }

    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopDisplayLink()
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopDisplayLink()
    }

    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateProgress() {
        currentTime = audioPlayer?.currentTime ?? 0
    }

    private func extractAudioLevels() {
        guard let audioFile = audioFile else { return }

        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }

        do {
            try audioFile.read(into: buffer)

            guard let floatChannelData = buffer.floatChannelData else { return }
            let channelData = floatChannelData[0]

            // Sample every 1000 frames for visualization
            let sampleInterval = 1000
            var levels: [Float] = []

            for i in stride(from: 0, to: Int(frameCount), by: sampleInterval) {
                let sample = channelData[i]
                levels.append(abs(sample))
            }

            DispatchQueue.main.async {
                self.audioLevels = levels
            }
        } catch {
            print("Failed to extract audio levels: \(error)")
        }
    }

    deinit {
        stopDisplayLink()
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopDisplayLink()
    }
}
