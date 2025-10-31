//
//  ProjectEditorView.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ProjectEditorView: View {
    @ObservedObject var viewModel: ProjectViewModel
    let project: LightShowProject

    @State private var showingAudioPicker = false
    @State private var showingExportSheet = false
    @State private var showingAutoSyncSheet = false
    @State private var selectedFrame: LightFrame?
    @State private var showingFrameEditor = false
    @State private var showingErrorAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Top controls
            controlBar

            Divider()

            // Main content area
            ScrollView {
                VStack(spacing: 20) {
                    // Audio section
                    audioSection

                    // Auto-sync section
                    autoSyncSection

                    // Timeline
                    if viewModel.currentProject?.audioFileURL != nil {
                        timelineSection
                    }

                    // Preview section
                    previewSection
                }
                .padding()
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingExportSheet = true
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.currentProject?.audioFileURL == nil || viewModel.currentProject?.frames.isEmpty == true)
            }
        }
        .onAppear {
            viewModel.selectProject(project)
        }
        .sheet(isPresented: $showingAudioPicker) {
            AudioPickerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAutoSyncSheet) {
            AutoSyncSheet(viewModel: viewModel, isPresented: $showingAutoSyncSheet)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportSheet(viewModel: viewModel, isPresented: $showingExportSheet)
        }
        .sheet(item: $selectedFrame) { frame in
            FrameEditorSheet(viewModel: viewModel, frame: frame)
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") {
                viewModel.errorMessage = nil
                showingErrorAlert = false
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onChange(of: viewModel.errorMessage) { oldValue, newValue in
            showingErrorAlert = newValue != nil
        }
    }

    // MARK: - Control Bar
    private var controlBar: some View {
        HStack(spacing: 15) {
            Button(action: {
                viewModel.audioManager.isPlaying ? viewModel.audioManager.pause() : viewModel.audioManager.play()
            }) {
                Image(systemName: viewModel.audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
            }
            .disabled(viewModel.currentProject?.audioFileURL == nil)

            Button(action: {
                viewModel.audioManager.stop()
            }) {
                Image(systemName: "stop.circle.fill")
                    .font(.title)
            }
            .disabled(viewModel.currentProject?.audioFileURL == nil)

            Divider()
                .frame(height: 30)

            Text(formatTime(viewModel.audioManager.currentTime))
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 60)

            Text("/")
                .foregroundColor(.secondary)

            Text(formatTime(viewModel.audioManager.duration))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(minWidth: 60)

            Spacer()
        }
        .padding()
    }

    // MARK: - Audio Section
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Audio File", systemImage: "music.note")
                    .font(.headline)
                Spacer()
                Button("Import Audio") {
                    showingAudioPicker = true
                }
                .buttonStyle(.borderedProminent)
            }

            if let fileName = viewModel.currentProject?.audioFileName, !fileName.isEmpty {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.blue)
                    Text(fileName)
                        .font(.subheadline)
                    Spacer()
                    Text(formatDuration(viewModel.audioManager.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

                // Waveform visualization
                WaveformView(audioLevels: viewModel.audioManager.audioLevels)
                    .frame(height: 80)
            } else {
                Text("No audio file imported")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }

    // MARK: - Auto Sync Section
    private var autoSyncSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Auto-Sync", systemImage: "wand.and.stars")
                    .font(.headline)
                Spacer()
                Button("Generate") {
                    showingAutoSyncSheet = true
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.currentProject?.audioFileURL == nil)
            }

            Text("Automatically generate light sequences synced to music beats")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Timeline", systemImage: "timeline.selection")
                    .font(.headline)

                Spacer()

                Text("\(viewModel.currentProject?.frames.count ?? 0) frames")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    viewModel.clearAllFrames()
                }) {
                    Label("Clear", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.currentProject?.frames.isEmpty == true)
            }

            TimelineView(
                frames: viewModel.currentProject?.frames ?? [],
                duration: viewModel.audioManager.duration,
                currentTime: viewModel.audioManager.currentTime,
                onFrameTapped: { frame in
                    selectedFrame = frame
                },
                onTimelineTapped: { time in
                    viewModel.audioManager.seek(to: time)
                }
            )
            .frame(height: 120)
        }
    }

    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Preview", systemImage: "eye")
                .font(.headline)

            TeslaCarPreview(
                frames: viewModel.currentProject?.frames ?? [],
                currentTime: viewModel.audioManager.currentTime
            )
            .frame(height: 200)
        }
    }

    // MARK: - Helper Functions
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Picker
struct AudioPickerView: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        DocumentPicker(allowedContentTypes: [.audio, .mp3, .wav]) { urls in
            if let url = urls.first {
                viewModel.importAudio(from: url)
                dismiss()
            }
        }
    }
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onDocumentsPicked: ([URL]) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentsPicked: onDocumentsPicked)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentsPicked: ([URL]) -> Void

        init(onDocumentsPicked: @escaping ([URL]) -> Void) {
            self.onDocumentsPicked = onDocumentsPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onDocumentsPicked(urls)
        }
    }
}

// MARK: - Auto Sync Sheet
struct AutoSyncSheet: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Binding var isPresented: Bool
    @State private var sensitivity: Float = 1.5
    @State private var flashDuration: Double = 0.1

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Beat Detection Settings")) {
                    VStack(alignment: .leading) {
                        Text("Sensitivity: \(sensitivity, specifier: "%.1f")")
                        Slider(value: $sensitivity, in: 0.5...3.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        Text("Flash Duration: \(flashDuration, specifier: "%.2f")s")
                        Slider(value: $flashDuration, in: 0.05...0.5, step: 0.05)
                    }
                }

                Section {
                    Button(action: {
                        viewModel.autoGenerateLightShow(sensitivity: sensitivity, flashDuration: flashDuration)
                        isPresented = false
                    }) {
                        HStack {
                            if viewModel.isProcessing {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("Generate Light Show")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isProcessing)
                }
            }
            .navigationTitle("Auto-Sync")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Frame Editor Sheet
struct FrameEditorSheet: View {
    @ObservedObject var viewModel: ProjectViewModel
    let frame: LightFrame
    @Environment(\.dismiss) var dismiss

    @State private var selectedLightCommand: LightCommand = .on
    @State private var selectedClosureCommand: ClosureCommand = .none

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Frame at \(formatTime(frame.timestamp))")) {
                    Picker("Light Command", selection: $selectedLightCommand) {
                        ForEach(LightCommand.allCases) { command in
                            Text(command.rawValue).tag(command)
                        }
                    }

                    Picker("Closure Command", selection: $selectedClosureCommand) {
                        ForEach(ClosureCommand.allCases) { command in
                            Text(command.rawValue).tag(command)
                        }
                    }
                }

                Section {
                    Button("Save Changes") {
                        viewModel.updateFrame(frame, lightCommand: selectedLightCommand, closureCommand: selectedClosureCommand)
                        dismiss()
                    }

                    Button("Delete Frame", role: .destructive) {
                        viewModel.deleteFrame(frame)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Frame")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
