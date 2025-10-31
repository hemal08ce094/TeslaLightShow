# Tesla Light Show Creator for iOS

A comprehensive iOS application for creating custom light shows for Tesla vehicles. This app allows you to import music, automatically sync lights to beats, manually edit sequences, and export files ready for your Tesla.

## 🎵 Quick Start - Test Audio Included!

A **test audio file** is included in the `TestAssets/` directory for immediate testing:
- **TestAudio.wav** - 30-second audio with clear 120 BPM beats
- Perfect for testing beat detection and light show generation
- See `TestAssets/README.md` for details

## Features

### Core Functionality
- **Music Import**: Import MP3 or WAV audio files from your device
- **Auto-Sync**: Automatically detect beats and generate light sequences synced to music
- **Manual Editing**: Fine-tune light sequences with frame-by-frame control
- **Real-time Preview**: Visualize your light show with an animated Tesla car preview
- **Timeline Editor**: Visual timeline with drag-and-drop frame editing
- **Waveform Visualization**: See audio waveform while editing
- **Export to .fseq**: Generate Tesla-compatible light show files

### Light Commands
- **Instant On/Off**: Quick light flashes
- **Ramping**: Gradual light transitions (500ms, 1s, 2s)
- **Closure Commands**: Control doors, trunk, and frunk (Open, Dance, Close, Stop)

### Export & Transfer
- Export to .fseq V2 Uncompressed format
- Automatic audio file packaging
- Step-by-step USB transfer instructions
- Share files via AirDrop or Files app

## Technical Specifications

### Audio Requirements
- **Formats**: MP3 or WAV
- **Sample Rate**: 44.1 kHz (recommended)
- **Duration**: Up to 4 hours

### Light Show Format
- **File Format**: .fseq V2 Uncompressed
- **Frame Interval**: 20ms (recommended, supports 15-100ms)
- **Channel Count**: 96 channels for light and closure commands

### Supported Tesla Models
- Model Y
- Model 3
- Model 3 Highland
- Model S (2021+)
- Model X (2021+)

## Project Structure

```
TLightShow/
├── Models/
│   └── LightShowModels.swift       # Data models for projects and frames
├── Services/
│   ├── AudioManager.swift          # Audio playback and waveform extraction
│   ├── BeatDetector.swift          # Beat detection algorithm
│   └── FSEQEncoder.swift           # .fseq file format encoder
├── ViewModels/
│   └── ProjectViewModel.swift      # Main app logic and state management
├── Views/
│   ├── ContentView.swift           # Main app entry
│   ├── ProjectListView.swift      # Project list and management
│   ├── ProjectEditorView.swift    # Main editor interface
│   ├── TimelineView.swift         # Timeline visualization
│   ├── WaveformView.swift         # Audio waveform display
│   ├── TeslaCarPreview.swift      # Live preview of light show
│   └── ExportSheet.swift          # Export and transfer guide
└── TLightShowApp.swift            # App entry point
```

## How to Use

### 1. Create a New Project
- Tap the "+" button on the main screen
- Enter a name for your light show project

### 2. Import Audio
- Tap "Import Audio" in the editor
- Select an MP3 or WAV file from your device
- The audio will be copied to the app and waveform will be displayed

### 3. Generate Light Show (Auto-Sync)
- Tap "Generate" in the Auto-Sync section
- Adjust sensitivity (0.5-3.0) to control beat detection
- Adjust flash duration (0.05-0.5s) for light timing
- Tap "Generate Light Show" to create automatic sequences

### 4. Manual Editing (Optional)
- Tap anywhere on the timeline to seek to that time
- Tap on any frame marker to edit its light/closure commands
- Use the preview to see your changes in real-time

### 5. Export to USB
- Tap the export button (top-right)
- Follow the step-by-step instructions
- Share files to your computer or iCloud Drive
- Copy both .fseq and audio files to USB drive in "LightShow" folder

### 6. Play in Tesla
- Insert USB drive into your Tesla
- Navigate to Toybox > Light Show
- Select your custom show and enjoy!

## Beat Detection Algorithm

The app uses an energy-based beat detection algorithm:
1. Audio is analyzed in overlapping windows (1024 samples, 512 hop)
2. Energy is calculated for each window using RMS
3. Dynamic threshold is computed based on mean + (standard deviation × sensitivity)
4. Peaks above threshold are detected as beats
5. Light frames are generated at beat timestamps

## FSEQ File Format

The app generates .fseq V2 Uncompressed files compatible with Tesla vehicles:

- **Magic**: "PSEQ" (4 bytes)
- **Version**: 2.0
- **Channels**: 96 (mapped to light and closure commands)
- **Frame Data**: Uncompressed channel values for each time step
- **Command Mapping**:
  - Channels 0-15: Light commands (F, E, D, C, W, S, X)
  - Channels 16-31: Closure commands (Q, A, Z, F)

## USB Drive Requirements

### Format
- exFAT (recommended)
- FAT32
- MS-DOS FAT
- ext3 or ext4
- **NOT NTFS**

### Structure
```
USB Drive/
└── LightShow/
    ├── myshow.fseq
    └── myshow.mp3 (or .wav)
```

**Important**: File names must match exactly (excluding extension)

## Development Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Dependencies
- SwiftUI
- AVFoundation
- Accelerate (for DSP operations)
- UniformTypeIdentifiers

## Building the App

1. Open `TLightShow.xcodeproj` in Xcode
2. Select your development team in Signing & Capabilities
3. Connect your iOS device or select a simulator
4. Build and run (Cmd+R)

## Known Limitations

- Beat detection works best with music that has clear, strong beats
- Very complex rhythms may require manual adjustment
- Audio files must be 44.1 kHz for proper sync in Tesla
- Maximum project duration is 4 hours

## Tips for Best Results

1. **Audio Quality**: Use high-quality audio files (at least 256kbps MP3 or WAV)
2. **Beat Detection**: Adjust sensitivity based on your music type
   - Lower (0.5-1.0) for bass-heavy music
   - Medium (1.0-2.0) for balanced music
   - Higher (2.0-3.0) for subtle beats
3. **Flash Duration**: Keep between 0.1-0.2s for visible but not overwhelming flashes
4. **Frame Timing**: Use 20ms frame interval for smooth animations
5. **Testing**: Preview your show in the app before exporting

## Troubleshooting

### Light show doesn't play in Tesla
- Ensure USB is formatted as exFAT or FAT32
- Verify file names match exactly
- Check that files are in "LightShow" folder
- Confirm your Tesla model supports light shows

### Beat detection not accurate
- Try adjusting sensitivity slider
- Consider manual editing for complex sections
- Use music with clear, strong beats for best results

### Audio doesn't sync in Tesla
- Ensure audio is 44.1 kHz sample rate
- Re-export with correct audio format
- Verify .fseq and audio files have matching names

## Credits

Created for Tesla vehicle owners who want to create custom light shows.

Based on Tesla's official light show format and xLights compatibility.

## License

This is an educational project demonstrating iOS app development with SwiftUI, AVFoundation, and custom file format encoding.

---

**Disclaimer**: This app is not affiliated with or endorsed by Tesla, Inc. Tesla and the Tesla logo are trademarks of Tesla, Inc.
