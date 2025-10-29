//
//  ExportSheet.swift
//  TLightShow
//
//  Created by hemal on 14/06/2025.
//

import SwiftUI
import UIKit

struct ExportSheet: View {
    @ObservedObject var viewModel: ProjectViewModel
    @Binding var isPresented: Bool

    @State private var exportedURLs: (fseq: URL, audio: URL)?
    @State private var showingShareSheet = false
    @State private var isExporting = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let urls = exportedURLs {
                        // Export successful
                        successView(urls: urls)
                    } else {
                        // Export instructions
                        instructionsView
                    }
                }
                .padding()
            }
            .navigationTitle("Export Light Show")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let urls = exportedURLs {
                ShareSheet(items: [urls.fseq, urls.audio])
            }
        }
    }

    private var instructionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bolt.car.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Export your light show to USB drive")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                instructionStep(number: 1, title: "Prepare USB Drive", description: "Format your USB drive as exFAT or FAT32")

                instructionStep(number: 2, title: "Create Folder", description: "Create a folder named 'LightShow' on the USB drive")

                instructionStep(number: 3, title: "Export Files", description: "Tap the export button below to generate the light show files")

                instructionStep(number: 4, title: "Transfer Files", description: "Copy both .fseq and audio files to the LightShow folder")

                instructionStep(number: 5, title: "Play in Tesla", description: "Insert USB into your Tesla and navigate to Toybox > Light Show")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Button(action: performExport) {
                HStack {
                    if isExporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Text(isExporting ? "Exporting..." : "Export Light Show")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isExporting)

            // Supported models
            VStack(alignment: .leading, spacing: 8) {
                Text("Supported Models")
                    .font(.headline)

                Text("• Model Y\n• Model 3\n• Model 3 Highland\n• Model S (2021+)\n• Model X (2021+)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private func successView(urls: (fseq: URL, audio: URL)) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Export Successful!")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                exportedFileRow(title: "Light Show File", fileName: urls.fseq.lastPathComponent, icon: "doc.fill")
                exportedFileRow(title: "Audio File", fileName: urls.audio.lastPathComponent, icon: "music.note")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            Button(action: {
                showingShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Files")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            // Transfer instructions
            VStack(alignment: .leading, spacing: 12) {
                Text("Next Steps:")
                    .font(.headline)

                Text("1. Share or AirDrop files to your computer\n2. Copy both files to USB drive > LightShow folder\n3. Files must have matching names (e.g., show1.fseq + show1.mp3)\n4. Safely eject USB and insert into Tesla\n5. Navigate to Toybox > Light Show in your Tesla")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)

            // Important notes
            VStack(alignment: .leading, spacing: 8) {
                Label("Important Notes", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundColor(.orange)

                Text("• USB must be formatted as exFAT or FAT32 (not NTFS)\n• Audio must be 44.1 kHz sample rate\n• File names must match exactly\n• Maximum show duration: 4 hours")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
    }

    private func instructionStep(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private func exportedFileRow(title: String, fileName: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }

    private func performExport() {
        isExporting = true

        viewModel.exportProject { result in
            isExporting = false

            switch result {
            case .success(let urls):
                exportedURLs = urls
            case .failure(let error):
                viewModel.errorMessage = "Export failed: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
