#!/usr/bin/env python3
"""
Generate a test audio file for Tesla Light Show app testing.
Creates a simple WAV file with clear beat patterns for testing beat detection.
"""

import wave
import struct
import math

def generate_test_audio(filename="TestAudio.wav", duration=30, sample_rate=44100):
    """
    Generate a test audio file with clear beats.

    Args:
        filename: Output filename
        duration: Duration in seconds
        sample_rate: Sample rate (44.1 kHz for Tesla compatibility)
    """

    # Audio parameters
    num_channels = 1  # Mono
    sample_width = 2  # 16-bit

    # Calculate total samples
    num_samples = duration * sample_rate

    # Open WAV file for writing
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(num_channels)
        wav_file.setsampwidth(sample_width)
        wav_file.setframerate(sample_rate)

        print(f"Generating {duration}s test audio at {sample_rate}Hz...")

        for i in range(num_samples):
            time = i / sample_rate

            # Create a beat pattern: strong beat every 0.5 seconds (120 BPM)
            beat_frequency = 2.0  # 2 Hz = 120 BPM
            beat_phase = (time * beat_frequency) % 1.0

            # Bass drum sound: Low frequency with exponential decay
            if beat_phase < 0.1:
                # Attack phase
                bass_freq = 60  # Hz
                decay = math.exp(-beat_phase * 50)  # Fast decay
                bass = math.sin(2 * math.pi * bass_freq * time) * decay * 0.8
            else:
                bass = 0

            # Add some melody: Simple tone pattern
            melody_freq = 440 * (1 + 0.5 * math.sin(2 * math.pi * 0.25 * time))  # Varying frequency
            melody = math.sin(2 * math.pi * melody_freq * time) * 0.2

            # Add hi-hat: High frequency on off-beats
            hihat_beat_phase = (time * beat_frequency * 2) % 1.0  # Double frequency
            if hihat_beat_phase < 0.05:
                # White noise approximation with high frequency
                hihat = math.sin(2 * math.pi * 8000 * time * (1 + 0.5 * math.sin(time * 100))) * 0.15
            else:
                hihat = 0

            # Mix all components
            sample = bass + melody + hihat

            # Clip to prevent distortion
            sample = max(-1.0, min(1.0, sample))

            # Convert to 16-bit integer
            sample_int = int(sample * 32767)

            # Write sample
            wav_file.writeframes(struct.pack('<h', sample_int))

        print(f"✅ Successfully created {filename}")
        print(f"   Duration: {duration}s")
        print(f"   Sample Rate: {sample_rate}Hz")
        print(f"   Format: 16-bit Mono WAV")
        print(f"   BPM: 120 (clear beats every 0.5s)")
        print(f"   Size: {num_samples * sample_width / 1024:.1f} KB")

if __name__ == "__main__":
    # Generate test audio file
    generate_test_audio(
        filename="TestAudio.wav",
        duration=30,  # 30 seconds
        sample_rate=44100  # Tesla-compatible sample rate
    )

    print("\n📁 Test audio file created: TestAudio.wav")
    print("📱 You can now import this file into the Tesla Light Show app!")
    print("🎵 The file has clear beats at 120 BPM for easy beat detection testing.")
