//
//  ProjectViewModel.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import Foundation
import SwiftUI
import Combine

class ProjectViewModel: ObservableObject {
    @Published var projects: [LightShowProject] = []
    @Published var currentProject: LightShowProject?
    @Published var isProcessing = false
    @Published var errorMessage: String?

    let audioManager = AudioManager()
    let beatDetector = BeatDetector()
    let fseqEncoder = FSEQEncoder()

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadProjects()
    }

    // MARK: - Project Management

    func createNewProject(name: String) {
        let project = LightShowProject(name: name)
        projects.append(project)
        currentProject = project
        saveProjects()
    }

    func deleteProject(_ project: LightShowProject) {
        projects.removeAll { $0.id == project.id }
        if currentProject?.id == project.id {
            currentProject = nil
        }
        saveProjects()
    }

    func selectProject(_ project: LightShowProject) {
        currentProject = project

        // Load audio if available
        if let audioURL = project.audioFileURL {
            do {
                try audioManager.loadAudio(from: audioURL)
            } catch {
                errorMessage = "Failed to load audio: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Audio Import

    func importAudio(from url: URL) {
        guard var project = currentProject else { return }

        // Start accessing security-scoped resource
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            // Copy audio to app documents directory
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioDirectory = documentsDirectory.appendingPathComponent("Audio", isDirectory: true)

            if !FileManager.default.fileExists(atPath: audioDirectory.path()) {
                try FileManager.default.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
            }

            let fileName = url.lastPathComponent
            let destinationURL = audioDirectory.appendingPathComponent(fileName)

            // Remove existing file if present
            if FileManager.default.fileExists(atPath: destinationURL.path()) {
                try FileManager.default.removeItem(at: destinationURL)
            }

            try FileManager.default.copyItem(at: url, to: destinationURL)

            // Update project
            project.audioFileName = fileName
            project.audioFileURL = destinationURL

            // Load audio
            try audioManager.loadAudio(from: destinationURL)
            project.duration = audioManager.duration

            updateProject(project)

        } catch {
            errorMessage = "Failed to import audio: \(error.localizedDescription)"
        }
    }

    // MARK: - Auto-Sync (Beat Detection)

    func autoGenerateLightShow(sensitivity: Float = 1.5, flashDuration: TimeInterval = 0.1) {
        guard var project = currentProject,
              let audioURL = project.audioFileURL else {
            errorMessage = "No audio file loaded"
            return
        }

        isProcessing = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // Detect beats
                let detection = try self.beatDetector.detectBeats(from: audioURL, sensitivity: sensitivity)

                // Generate frames from beats
                let frames = self.beatDetector.generateLightFrames(
                    from: detection.beats,
                    duration: project.duration,
                    lightCommand: .on,
                    flashDuration: flashDuration
                )

                DispatchQueue.main.async {
                    project.frames = frames
                    project.modifiedDate = Date()
                    self.updateProject(project)
                    self.isProcessing = false
                }

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Beat detection failed: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }

    // MARK: - Frame Management

    func addFrame(at timestamp: TimeInterval, lightCommand: LightCommand, closureCommand: ClosureCommand) {
        guard var project = currentProject else { return }

        let frame = LightFrame(timestamp: timestamp, lightCommand: lightCommand, closureCommand: closureCommand)
        project.frames.append(frame)
        project.frames.sort { $0.timestamp < $1.timestamp }
        project.modifiedDate = Date()

        updateProject(project)
    }

    func deleteFrame(_ frame: LightFrame) {
        guard var project = currentProject else { return }

        project.frames.removeAll { $0.id == frame.id }
        project.modifiedDate = Date()

        updateProject(project)
    }

    func updateFrame(_ frame: LightFrame, lightCommand: LightCommand, closureCommand: ClosureCommand) {
        guard var project = currentProject else { return }

        if let index = project.frames.firstIndex(where: { $0.id == frame.id }) {
            project.frames[index] = LightFrame(
                id: frame.id,
                timestamp: frame.timestamp,
                lightCommand: lightCommand,
                closureCommand: closureCommand
            )
            project.modifiedDate = Date()
            updateProject(project)
        }
    }

    func clearAllFrames() {
        guard var project = currentProject else { return }

        project.frames.removeAll()
        project.modifiedDate = Date()

        updateProject(project)
    }

    // MARK: - Export

    func exportProject(completion: @escaping (Result<(fseq: URL, audio: URL), Error>) -> Void) {
        guard let project = currentProject else {
            completion(.failure(NSError(domain: "ProjectViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No project selected"])))
            return
        }

        isProcessing = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            do {
                // Create export directory
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let exportDirectory = documentsDirectory.appendingPathComponent("Exports/\(project.name)", isDirectory: true)

                if !FileManager.default.fileExists(atPath: exportDirectory.path()) {
                    try FileManager.default.createDirectory(at: exportDirectory, withIntermediateDirectories: true)
                }

                // Export files
                let urls = try self.fseqEncoder.exportLightShowPackage(project: project, outputDirectory: exportDirectory)

                DispatchQueue.main.async {
                    self.isProcessing = false
                    completion(.success(urls))
                }

            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.errorMessage = "Export failed: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Persistence

    private func updateProject(_ project: LightShowProject) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
        }
        currentProject = project
        saveProjects()
    }

    private func saveProjects() {
        do {
            let data = try JSONEncoder().encode(projects)
            UserDefaults.standard.set(data, forKey: "SavedProjects")
        } catch {
            print("Failed to save projects: \(error)")
        }
    }

    private func loadProjects() {
        guard let data = UserDefaults.standard.data(forKey: "SavedProjects") else { return }

        do {
            projects = try JSONDecoder().decode([LightShowProject].self, from: data)
        } catch {
            print("Failed to load projects: \(error)")
        }
    }
}
