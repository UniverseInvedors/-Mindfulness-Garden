# Audio Troubleshooting Guide

## Issue 1: No Sounds Playing in Garden

### Symptoms
- Click buttons but hear nothing
- No background music
- Garden is silent

### Diagnosis Steps

1. **Check Console Logs**
```bash
flutter logs | grep -i "audio"
```

Look for:
- ✅ `AudioManagerService initialized successfully`
- ✅ `Successfully played UI sound: sounds/button_click.mp3`
- ❌ `Error playing UI sound: ...`
- ❌ `SFX disabled, skipping sound`

2. **Check Audio Manager Initialization**
Open `lib/main.dart` and verify:
```dart
Future<void> _initializeAudioManager() async {
  try {
    await AudioManagerService().initialize();
    _log('AudioManagerService initialized successfully');
  } catch (e) {
    _log('Error initializing AudioManagerService: $e');
  }
}

// In main():
unawaited(_initializeAudioManager());
```

3. **Check Volume Levels**
Open Settings and verify:
- Volume Level slider is > 0%
- Not set to 0%

4. **Test Individual Sound**
Add this test button to garden screen:
```dart
ElevatedButton(
  onPressed: () async {
    debugPrint('🔊 Testing button click...');
    await AudioManagerService().playButtonClick();
    debugPrint('✅ Button click played');
  },
  child: Text('TEST SOUND'),
)
```

### Solutions

#### Solution A: Increase Volumes
Edit `lib/services/audio_manager_service.dart`:
```dart
double _musicVolume = 0.8;  // Was 0.7
double _sfxVolume = 1.0;    // Was 0.8
double _ambienceVolume = 0.6; // Was 0.5
```

#### Solution B: Enable Debug Logging
Already added debug logs:
```dart
debugPrint('Attempting to play UI sound: $path');
debugPrint('Successfully played UI sound: $path');
```

#### Solution C: Check Asset Paths
Verify files exist:
```bash
ls assets/sounds/button_click.mp3
ls assets/music/spring.mp3
```

---

## Issue 2: Weather Section Not Visible in Settings

### Symptoms
- Can't find weather dropdown in settings
- "Garden & Weather" section missing

### Solution
**The settings screen is SCROLLABLE!**

1. Open Settings
2. **SCROLL DOWN** past these sections:
   - Profile Section
   - UI Theme
   - Personality (Teacher selection)
   - AI Tutor Voice
   - General (Auto Theme, Auto Background, Language, Notifications)
3. **Keep scrolling!**
4. You'll find: **"Garden & Weather"** section with park icon 🏞️

The section includes:
- ☀️ Auto Weather (toggle)
- ☁️ Garden Weather (dropdown) - only visible when Auto Weather is OFF
- 🌓 Auto Day/Night Cycle (toggle)

---

## Issue 3: Changing Weather Doesn't Change Music

### Symptoms
- Select weather in dropdown
- Music doesn't change
- Or music stops completely

### Diagnosis

1. **Check Console**
```bash
flutter logs | grep -i "theme\|weather\|music"
```

Look for:
- ✅ `Playing background music: assets/music/rainny.mp3`
- ❌ `Error playing background music: ...`

2. **Verify Weather Mapping**
Check `lib/services/audio_constants.dart`:
```dart
case 'sunny': return [musicSummer, ...]
case 'rainy': return [musicRainy, ...]
case 'snowy': return [musicWinter, ...]
case 'cloudy': return [musicSpring, ...]
case 'stormy': return [musicRainy, ...]
```

### Solutions

#### Solution A: Test Direct Music Play
```dart
// Test button
ElevatedButton(
  onPressed: () async {
    debugPrint('🎵 Testing music...');
    await AudioManagerService().playBackgroundMusic(
      'assets/music/spring.mp3'
    );
    debugPrint('✅ Music should be playing');
  },
  child: Text('TEST MUSIC'),
)
```

#### Solution B: Verify Settings Integration
Check `lib/core/services/auto_theme_service.dart`:
```dart
Future<void> setManualWeather(String weather) async {
  _manualWeather = weather;
  await LocalStorageService.saveSetting('manual_weather', weather);
  
  // THIS LINE IS CRITICAL:
  final AudioManagerService audioManager = AudioManagerService();
  await audioManager.changeTheme(weather.toLowerCase());
  
  notifyListeners();
}
```

#### Solution C: Check Music Enabled
```dart
// In AudioManagerService
bool _isMusicEnabled = true;  // Should be true, not false
```

---

## Issue 4: Sounds Play Once Then Stop

### Symptoms
- First click works
- Subsequent clicks silent
- Or: Only one sound works

### Cause
Audio player might be stopping previous sound before playing new one, causing conflicts.

### Solution
Already fixed in `lib/services/audio_manager_service.dart`:
```dart
Future<void> playUISound(String audioPath) async {
  // DON'T stop previous sound:
  // await _uiPlayer.stop();  // ❌ This was removed
  
  // Just play the new sound:
  await _uiPlayer.play(AssetSource(path));  // ✅ Allows overlapping
}
```

---

## Issue 5: Asset Loading Errors

### Symptoms
Console shows:
```
Error: Unable to load asset: assets/sounds/music/rainny.mp3
```

### Cause
Wrong path in AudioConstants

### Solution
Already fixed! Paths are:
```dart
// ✅ CORRECT:
static const String musicRainy = 'assets/music/rainny.mp3';
static const String uiButtonClick = 'assets/sounds/button_click.mp3';

// ❌ WRONG (old):
static const String musicRainy = 'assets/sounds/music/rainny.mp3';
```

### Verify pubspec.yaml
```yaml
flutter:
  assets:
    - assets/sounds/
    - assets/music/
    - assets/binaural/
```

---

## Quick Test Script

### Add Test Audio Screen to Router

1. Open your router file (likely `lib/core/routing/app_router.dart`)

2. Add route:
```dart
GoRoute(
  path: '/test-audio',
  builder: (context, state) => const TestAudioScreen(),
),
```

3. Add import:
```dart
import 'package:pranaverse/test_audio_screen.dart';
```

4. Navigate to test screen:
```dart
// From anywhere in app:
context.push('/test-audio');
```

5. Or add temporary button to settings:
```dart
ElevatedButton(
  onPressed: () => context.push('/test-audio'),
  child: Text('🔊 TEST ALL AUDIO'),
)
```

### Test Procedure
1. Open Test Audio Screen
2. Click each button systematically
3. Check console for messages:
   - ✅ means sound played successfully
   - ❌ means error occurred
4. Listen for actual sound
5. Note which files work vs. which fail

---

## Console Output Examples

### ✅ Good Output
```
I/flutter (12345): AudioManagerService initialized successfully
I/flutter (12345): Attempting to play UI sound: sounds/button_click.mp3
I/flutter (12345): Successfully played UI sound: sounds/button_click.mp3
I/flutter (12345): Playing background music: assets/music/spring.mp3
```

### ❌ Bad Output (with solutions)
```
E/flutter (12345): Error playing UI sound: Unable to load asset
```
**Fix:** Check file exists, verify path

```
I/flutter (12345): SFX disabled, skipping sound
```
**Fix:** Enable SFX in settings or set `_areSfxEnabled = true`

```
E/flutter (12345): Error initializing AudioManagerService: ...
```
**Fix:** Check dependencies, verify audioplayers package installed

---

## Dependencies Check

Verify `pubspec.yaml` has:
```yaml
dependencies:
  audioplayers: ^6.1.0
  just_audio: ^0.9.46
```

Run:
```bash
flutter pub get
flutter clean
flutter pub get
```

---

## Platform-Specific Issues

### Android
- Check AndroidManifest.xml for audio permissions
- Verify app has storage permissions if needed
- Test on physical device (emulator audio can be unreliable)

### iOS
- Check Info.plist for audio permissions
- Test on physical device
- Verify background audio modes if needed

### Web
- Browser might block autoplay
- User must interact first (click button)
- Check browser console for errors

---

## Final Verification Checklist

- [ ] AudioManagerService initializes on app start
- [ ] Console shows initialization success
- [ ] All 48 audio files present in assets/
- [ ] pubspec.yaml includes asset directories
- [ ] Volume levels > 0
- [ ] SFX enabled (_areSfxEnabled = true)
- [ ] Music enabled (_isMusicEnabled = true)
- [ ] Test button plays sound
- [ ] Settings scroll reveals weather section
- [ ] Weather dropdown visible (when auto off)
- [ ] Selecting weather changes music
- [ ] Garden buttons play clicks
- [ ] No asset loading errors in console

---

## Emergency Reset

If nothing works, try this sequence:

1. **Clean Build**
```bash
flutter clean
flutter pub get
flutter run
```

2. **Verify Audio Files**
```bash
ls -la assets/sounds/*.mp3 | wc -l  # Should show 34
ls -la assets/music/*.mp3 | wc -l   # Should show 8
ls -la assets/binaural/*.mp3 | wc -l # Should show 6
```

3. **Test Single File**
Create minimal test:
```dart
import 'package:audioplayers/audioplayers.dart';

final player = AudioPlayer();
await player.play(AssetSource('sounds/button_click.mp3'));
```

4. **Check Device Volume**
- Not muted
- Volume > 50%
- Media volume (not ringer)

---

## Getting Help

When reporting audio issues, provide:
1. Console output (flutter logs)
2. Which sounds work vs. don't work
3. Device type (Android/iOS/Web)
4. Steps to reproduce
5. Screenshot of settings (showing weather section)
6. Result of test audio screen

**Most common issue:** Settings weather section not found because user didn't scroll down far enough!

**Second most common:** Volume set to 0% or SFX disabled in settings
