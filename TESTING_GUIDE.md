# Testing Guide - Tesla Light Show iOS App

This guide will walk you through testing the Tesla Light Show app using the included test audio file.

## 🚀 Quick Test (5 Minutes)

### Step 1: Build and Run the App
```bash
cd TeslaLightShow
open TLightShow.xcodeproj
```
- Select a simulator (iPhone 15 recommended) or your device
- Press **⌘+R** to build and run

### Step 2: Create a New Project
1. Tap the **"+"** button in the top right
2. Enter a project name (e.g., "Test Show")
3. Tap **"Create"**

### Step 3: Import Test Audio
1. Tap **"Import Audio"** button
2. Navigate to the project folder on your Mac
3. Select **`TestAssets/TestAudio.wav`**
4. The app will copy and load the audio file

**Note:** If using simulator, you may need to:
- Drag and drop the WAV file into the simulator
- Or use AirDrop to send it to a real device
- Or use the Files app to access the TestAssets folder

### Step 4: Generate Light Show Automatically
1. You should now see the waveform visualization
2. Scroll down to **"Auto-Sync"** section
3. Tap **"Generate"** button
4. Adjust settings (optional):
   - Sensitivity: **1.5** (default, recommended)
   - Flash Duration: **0.1s** (default)
5. Tap **"Generate Light Show"**
6. Wait for processing to complete (~2-5 seconds)

### Step 5: Preview Your Light Show
1. The timeline will now show colored bars representing light frames
2. Tap the **Play** button (▶️) at the top
3. Watch the Tesla car preview light up in sync with the music
4. The red playhead shows current position

**Expected Result:**
- You should see ~60 light frames (2 per second)
- Yellow bars indicate light "On" commands
- Lights flash every 0.5 seconds (120 BPM)

### Step 6: Manual Editing (Optional)
1. Tap any frame on the timeline to edit it
2. Change the light command (On, Ramp, Off)
3. Add closure commands (Open, Dance, Close)
4. Tap **"Save Changes"**

### Step 7: Export Your Light Show
1. Tap the **Export** button (↑) in the top right
2. Read the instructions
3. Tap **"Export Light Show"**
4. Wait for export to complete
5. Tap **"Share Files"** to save to Files app
6. You now have:
   - `TestShow.fseq` (light show data)
   - `TestShow.wav` (audio file)

### Step 8: Transfer to USB (For Real Tesla Testing)
1. Copy both files to a USB drive
2. Create a folder named **"LightShow"** on the USB
3. Paste both files inside (names must match!)
4. Format: exFAT or FAT32
5. Eject USB safely
6. Insert into your Tesla
7. Navigate to: **Toybox → Light Show**
8. Select your show and enjoy! 🎉

---

## 📊 Test Audio Specifications

The included `TestAudio.wav` file has these properties:

| Property | Value | Why This Matters |
|----------|-------|------------------|
| Duration | 30 seconds | Long enough for full test, short for quick iteration |
| Sample Rate | 44,100 Hz | Required by Tesla for proper sync |
| Format | 16-bit WAV | Lossless quality, Tesla-compatible |
| BPM | 120 | Clear, even beats every 0.5 seconds |
| Channels | Mono | Smaller file size, works perfectly |
| File Size | ~2.6 MB | Quick to import and process |

### Audio Content Breakdown
- **00:00-30:00** - Continuous beat pattern
  - Bass drum on every beat (0.0s, 0.5s, 1.0s, 1.5s...)
  - Hi-hat on off-beats for rhythmic variation
  - Simple melody line for musical interest

---

## 🧪 What to Test

### ✅ Core Functionality
- [ ] Audio file import works
- [ ] Waveform displays correctly
- [ ] Beat detection finds ~60 beats
- [ ] Timeline shows light frames
- [ ] Playback works smoothly
- [ ] Preview animation syncs with audio
- [ ] Export generates .fseq file
- [ ] Files can be shared/saved

### ✅ Beat Detection Accuracy
With default sensitivity (1.5), you should see beats at:
```
0.0s, 0.5s, 1.0s, 1.5s, 2.0s, 2.5s, 3.0s...
```

If not detecting enough beats:
- Increase sensitivity to 2.0-2.5
- Lower flash duration to 0.05s

If detecting too many beats:
- Decrease sensitivity to 1.0-1.2
- Check that spurious frames aren't added

### ✅ Manual Editing
- [ ] Tap frame to edit
- [ ] Change light command
- [ ] Change closure command
- [ ] Delete frame
- [ ] Changes save correctly

### ✅ Export Quality
- [ ] .fseq file created
- [ ] Audio file copied correctly
- [ ] File names match
- [ ] Files can be opened/played

---

## 🐛 Troubleshooting

### Audio Import Issues

**Problem:** Can't find TestAudio.wav
- **Solution:** Use Files app or drag into simulator
- **Alternative:** Generate new test audio with `python3 generate_test_audio.py`

**Problem:** Audio doesn't load
- **Solution:** Check file isn't corrupted (should be ~2.6 MB)
- **Solution:** Try re-generating the test file

### Beat Detection Issues

**Problem:** No beats detected
- **Solution:** Increase sensitivity to 2.5
- **Solution:** Check audio is actually playing (duration > 0)

**Problem:** Too many beats detected
- **Solution:** Decrease sensitivity to 1.0
- **Solution:** Increase flash duration to reduce clutter

**Problem:** Beats not aligned with audio
- **Solution:** This shouldn't happen with test audio (exact timing)
- **Solution:** If it does, there's a bug in beat detection - please report

### Timeline Issues

**Problem:** Timeline is empty
- **Solution:** Generate light show first with Auto-Sync
- **Solution:** Check that frames array isn't empty

**Problem:** Can't see timeline
- **Solution:** Audio must be imported first
- **Solution:** Scroll down to Timeline section

### Preview Issues

**Problem:** Car doesn't light up
- **Solution:** Check that frames exist on timeline
- **Solution:** Ensure playback is working (time is advancing)

**Problem:** Lights don't sync with audio
- **Solution:** Seek to different time to refresh
- **Solution:** Stop and restart playback

### Export Issues

**Problem:** Export fails
- **Solution:** Ensure audio file is loaded
- **Solution:** Check that at least one frame exists
- **Solution:** Verify app has write permissions

**Problem:** Can't find exported files
- **Solution:** Check Documents/Exports/[ProjectName] folder
- **Solution:** Use Share sheet to save to Files app

---

## 📈 Performance Benchmarks

Expected performance on iPhone 15 / iOS 17:

| Operation | Expected Time | Notes |
|-----------|--------------|-------|
| Audio Import | 1-2 seconds | For 30s test file |
| Waveform Generation | 1-2 seconds | Background processing |
| Beat Detection | 2-5 seconds | ~60 beats detected |
| Frame Generation | < 1 second | Creating light frames |
| Export | 2-4 seconds | Writing .fseq + audio |
| Preview Rendering | 60 FPS | Real-time animation |

If performance is significantly slower:
- Check device isn't in Low Power Mode
- Close other apps
- Restart the app
- Try on a real device (simulator is slower)

---

## 🎨 Advanced Testing

### Test Different Beat Patterns

Modify `generate_test_audio.py` to test different scenarios:

**Faster BPM (140):**
```python
beat_frequency = 2.33  # 140 BPM
```

**Slower BPM (90):**
```python
beat_frequency = 1.5  # 90 BPM
```

**Longer Duration (60s):**
```python
generate_test_audio(duration=60)
```

**Different Sample Rate (test compatibility):**
```python
generate_test_audio(sample_rate=48000)  # Should work but not Tesla-optimal
```

### Test Manual Editing Workflow

1. Generate auto light show
2. Delete half the frames
3. Manually add closure commands
4. Test different light command types
5. Export and verify

### Test Edge Cases

- **Empty project export** (should fail gracefully)
- **Very short audio** (< 1 second)
- **Very long audio** (> 1 hour)
- **No beats detected** (silence)
- **Maximum beats** (very high sensitivity)

---

## ✅ Success Criteria

Your app is working correctly if:

1. ✅ Test audio imports without errors
2. ✅ Waveform displays with visible amplitude variations
3. ✅ Beat detection finds 55-65 beats (±10% tolerance)
4. ✅ Timeline shows yellow bars at regular intervals
5. ✅ Playback works smoothly at 60 FPS
6. ✅ Preview lights flash in sync with beats
7. ✅ Manual editing saves changes correctly
8. ✅ Export generates valid .fseq file (~840 KB expected)
9. ✅ Exported audio matches original (~2.6 MB)
10. ✅ Files can be shared to Files app or AirDrop

---

## 📞 Need Help?

If you encounter issues:

1. **Check COMPILATION_FIXES.md** - Common compilation issues
2. **Review TestAssets/README.md** - Test audio documentation
3. **Verify iOS version** - Requires iOS 17.0+
4. **Check Xcode version** - Requires Xcode 15.0+
5. **Clean build** - Product → Clean Build Folder (⇧⌘K)
6. **Reset simulator** - Device → Erase All Content and Settings

---

## 🎉 Next Steps

Once basic testing works:

1. **Try your own music** - Import MP3/WAV files
2. **Experiment with sensitivity** - Find optimal settings
3. **Create complex shows** - Mix auto + manual editing
4. **Test on real Tesla** - Transfer to USB and enjoy!
5. **Share your shows** - Create amazing light displays

---

**Happy Testing! 🚗💡✨**

For technical details, see:
- `README.md` - Full app documentation
- `COMPILATION_FIXES.md` - All bugs fixed
- `TestAssets/README.md` - Test audio details
