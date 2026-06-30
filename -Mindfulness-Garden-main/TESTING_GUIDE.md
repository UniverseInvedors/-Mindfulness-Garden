# Audio & UI Testing Guide

## Quick Test Checklist

### 1. Garden Background Music 🎵
**How to Test:**
1. Open the Garden screen
2. **Expected:** Background music should start playing automatically
3. Click the ☀️ (weather) icon in top-right
4. Select different weather (Sunny, Rainy, Snowy, etc.)
5. **Expected:** Background music changes to match weather theme
6. **Expected:** Hear button click sound when selecting weather

**Weather → Music Mapping:**
- Sunny → Spring/Summer theme
- Rainy → Rain theme with ambient sounds
- Snowy → Winter theme
- Cloudy → Autumn/calm theme
- Stormy → Rain + wind sounds

---

### 2. UI Click Sounds 🔊
**Where to Test Click Sounds:**

#### Settings Screen
- Open Settings from main menu
- Toggle any switch (Auto Weather, Auto Day/Night, etc.)
  - **Expected:** Click sound + haptic vibration
- Change any dropdown (Garden Weather)
  - **Expected:** Click sound when opening and selecting
- Adjust volume slider
  - **Expected:** Haptic feedback when releasing slider
- Click teacher avatars to select
  - **Expected:** Click sound + haptic feedback
- Click any button (Export Data, Clear Data, etc.)
  - **Expected:** Click sound + haptic feedback

#### Garden Screen
- Click any plant card to select
  - **Expected:** Click sound + plant placed sound
- Click any decoration card
  - **Expected:** Click sound + selection sound
- Click any NPC card
  - **Expected:** Click sound + success sound
- Click "Tend Garden" button
  - **Expected:** Heal sound + sparkle effect sound
- Click weather/time buttons
  - **Expected:** Click sound before dialog opens
- Click close (X) on dialogs
  - **Expected:** Click sound + dialog closes

#### Navigation
- Back buttons
  - **Expected:** Click sound on press
- Menu items
  - **Expected:** Click sound on selection

---

### 3. Weather Changes Music (Critical Test) 🌦️

**Test A: From Garden**
1. Open Garden
2. Note current background music
3. Click ☀️ weather icon
4. Select "Rainy"
5. **Expected:** 
   - Hear button click immediately
   - Background music fades/changes to rain theme
   - UI sounds still work independently

**Test B: From Settings**
1. Open Settings
2. Scroll to "Garden & Weather" section
3. Toggle OFF "Auto Weather"
4. In "Garden Weather" dropdown, select different weather
5. **Expected:**
   - Click sound when selecting
   - Background music changes to match
   - Return to garden and verify music matches

---

### 4. No Overflow Issues 🎯

**Plant Card Test:**
1. Open Garden
2. Click "🌱" (plant) button in bottom toolbar
3. Select any plant (Tree, Flower, Bush, etc.)
4. **Expected:**
   - No red overflow warnings in console
   - Plant emoji visible
   - Plant name visible when selected
   - Cost (🪙) visible
   - All text fits within card

---

### 5. Multi-Sound Independence 🎼

**Simultaneous Sounds Test:**
1. Open Garden (background music playing)
2. Click plant button (click sound plays)
3. Select a plant (plant sound plays)
4. Quickly tend garden (heal + sparkle sounds play)
5. **Expected:**
   - All sounds play without cutting each other off
   - Background music continues uninterrupted
   - No audio glitches or stuttering

---

## Troubleshooting

### ❌ Problem: No background music
**Check:**
- Is music volume > 0 in settings?
- Did app crash on startup? (check logs)
- Try changing weather manually

### ❌ Problem: No click sounds
**Check:**
- Is SFX volume > 0 in settings?
- Are sound effects enabled?
- Check device volume

### ❌ Problem: Music doesn't change with weather
**Check:**
- Look for error logs about asset loading
- Verify `assets/music/` files exist
- Check AudioManagerService initialization

### ❌ Problem: Plant cards still overflow
**Check:**
- Which screen? (garden_screen.dart or garden_gameplay_screen.dart?)
- Look for line number in error
- Check if text is too long

---

## Console Output to Expect

### ✅ Good Output:
```
AudioManagerService initialized successfully
Playing background music: assets/music/spring.mp3
Playing SFX: assets/sounds/button_click.mp3
```

### ❌ Bad Output (needs fixing):
```
Error playing background music: Unable to load asset: assets/sounds/music/rainny.mp3
```
*Note: This should not happen - paths are now correct*

```
RenderFlex overflowed by 7.0 pixels on the bottom
```
*Note: This should not happen - overflow is fixed*

---

## Audio Files Verification

All these files should be present and working:

### Music (8 files) - Located in `assets/music/`
- ✅ spring.mp3
- ✅ summer.mp3
- ✅ winter.mp3
- ✅ rainny.mp3
- ✅ morning_meditation.mp3
- ✅ stress_relief.mp3
- ✅ deep_sleep.mp3
- ✅ energy_boost.mp3

### UI Sounds (8 files) - Located in `assets/sounds/`
- ✅ button_click.mp3
- ✅ Select (1).mp3
- ✅ Select (2).mp3
- ✅ success.mp3
- ✅ error.mp3
- ✅ bonus.mp3
- ✅ sparkle.mp3
- ✅ happy.mp3

### Garden Sounds (4 files) - Located in `assets/sounds/`
- ✅ plant.mp3
- ✅ harvest.mp3
- ✅ collect_water.mp3
- ✅ heal.mp3

---

## Success Criteria ✅

All tests pass when:
1. ✅ Background music plays on garden open
2. ✅ Weather changes update background music
3. ✅ Every button click produces sound
4. ✅ Every interaction has haptic feedback
5. ✅ No UI overflow errors
6. ✅ Multiple sounds play simultaneously without issues
7. ✅ Settings weather dropdown works and changes music
8. ✅ Garden weather dialog works and changes music

---

## Performance Notes

- **Audio Latency:** Click sounds should be instant (<50ms)
- **Music Transitions:** Should be smooth, no pops/clicks
- **Memory Usage:** 4 audio players use minimal memory
- **Battery Impact:** Audio optimized for mobile devices

---

**Last Updated:** Fix implementation completed
**Files Modified:** 6 core files
**Issues Resolved:** 3 major issues (overflow, click sounds, weather music)
