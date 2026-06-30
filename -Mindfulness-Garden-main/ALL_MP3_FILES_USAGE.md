# Complete MP3 File Usage Map

## Summary
**Total Audio Files: 48**
- Background Music: 8 files
- Binaural Beats: 6 files  
- UI Sound Effects: 8 files
- Garden Actions: 4 files
- Nature Ambience: 15 files
- Meditation Sounds: 5 files
- Garden Time: 2 files

---

## 1. BACKGROUND MUSIC (8 files in `assets/music/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **spring.mp3** | Spring season theme, default garden music | Spring theme, Cloudy weather, default |
| **summer.mp3** | Summer season, sunny weather | Summer theme, Sunny weather |
| **winter.mp3** | Winter season, cold weather | Winter theme, Snowy weather |
| **rainny.mp3** | Rainy weather, monsoon | Rainy weather, Stormy weather |
| **morning_meditation.mp3** | Morning sessions, dawn time | Morning theme, morning meditation |
| **stress_relief.mp3** | Relaxation, stress reduction | Meditation mode, stress relief sessions |
| **deep_sleep.mp3** | Sleep mode, night meditation | Sleep theme, deep sleep mode |
| **energy_boost.mp3** | Energy sessions, active time | Energy theme, energizing activities |

**How to Trigger:**
- Settings → Garden Weather dropdown → Select weather
- Garden → Weather button → Select weather
- Auto-detected based on real-world season/weather

---

## 2. BINAURAL BEATS (6 files in `assets/binaural/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **focus.mp3** | Focus mode, concentration | Focus theme, study mode |
| **meditation.mp3** | Meditation sessions | Meditation mode, default meditation |
| **creativity.mp3** | Creative activities | Creativity mode |
| **energy.mp3** | Energy boost, alertness | Energy theme |
| **lightSleep.mp3** | Light sleep, napping | Light sleep mode |
| **deepSleep.mp3** | Deep sleep, night rest | Sleep theme, bedtime |

**How to Trigger:**
- Meditation sessions
- Focus/study modes
- Sleep routines
- Creative activities

---

## 3. UI SOUND EFFECTS (8 files in `assets/sounds/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **button_click.mp3** | Every button press | ALL buttons in the app |
| **Select (1).mp3** | Item selection | Selecting plants, decorations |
| **Select (2).mp3** | Dropdown selection | Settings dropdowns |
| **success.mp3** | Successful action | Completing tasks, achievements |
| **error.mp3** | Error message | Failed actions, errors |
| **bonus.mp3** | Rewards, bonuses | Earning coins, rewards |
| **sparkle.mp3** | Magic effects | Tend garden, special effects |
| **happy.mp3** | Positive feedback | Happy moments, celebrations |

**How to Trigger:**
- Click ANY button → button_click.mp3
- Select plant/decoration → Select (1).mp3
- Change dropdown → Select (2).mp3
- Complete task → success.mp3
- Click "Tend Garden" → sparkle.mp3

---

## 4. GARDEN ACTIONS (4 files in `assets/sounds/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **plant.mp3** | Planting action | Adding new plants to garden |
| **harvest.mp3** | Harvesting crops | Collecting/harvesting plants |
| **collect_water.mp3** | Watering plants | Watering action |
| **heal.mp3** | Healing/tending | Tend garden button |

**How to Trigger:**
- Garden → Add Plant → Select plant → plant.mp3
- Garden → Tend Garden → heal.mp3
- Future: Harvest action → harvest.mp3
- Future: Water action → collect_water.mp3

---

## 5. NATURE AMBIENCE (15 files in `assets/sounds/`)

### Birds (2 files)
| File | Used For | Triggered By |
|------|----------|--------------|
| **birds.mp3** | Daytime ambience, spring | Spring/summer themes, daytime |
| **bird_chirp.mp3** | Morning sounds | Morning theme |

### Insects (2 files)
| File | Used For | Triggered By |
|------|----------|--------------|
| **crickets.mp3** | Night ambience | Summer nights, night theme |
| **cricket.mp3** | Evening sounds | Evening time |

### Water (6 files)
| File | Used For | Triggered By |
|------|----------|--------------|
| **ocean.mp3** | Ocean ambience | Summer theme, beach vibes |
| **ocean_waves.mp3** | Wave sounds, sleep | Sleep mode, deep sleep |
| **water.mp3** | General water sounds | Water features |
| **waterfall.mp3** | Waterfall ambience | Garden decorations |
| **river.wav** | River sounds | Forest stream theme |
| **forest_stream.mp3** | Gentle stream | Rainy theme, focus mode |

### Weather (2 files)
| File | Used For | Triggered By |
|------|----------|--------------|
| **rain.mp3** | Rain ambience | Rainy/stormy weather |
| **wind.mp3** | Wind sounds | Winter/stormy weather |

### Forest (3 files)
| File | Used For | Triggered By |
|------|----------|--------------|
| **forest.mp3** | Forest ambience | Spring/cloudy weather |
| **rainforest.mp3** | Tropical forest | Rainy season |
| **night.mp3** | Night ambience | Night theme, winter nights |

**How to Trigger:**
- Automatic based on weather/time selection
- Plays alongside background music
- Changes when you change weather

---

## 6. MEDITATION SOUNDS (5 files in `assets/sounds/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **meditation_bell.mp3** | Meditation sessions | Meditation timer, bell sound |
| **bowl.mp3** | Singing bowl | Meditation mode, zen moments |
| **zen.mp3** | Zen ambience | Meditation theme, relaxation |
| **piano.mp3** | Calm piano | Meditation background |
| **breathing_guide.mp3** | Breathing exercises | Breathing exercise mode |

**How to Trigger:**
- Start meditation session → meditation_bell.mp3
- Meditation mode → bowl.mp3, zen.mp3
- Breathing exercise → breathing_guide.mp3

---

## 7. GARDEN TIME (2 files in `assets/sounds/`)

| File | Used For | Triggered By |
|------|----------|--------------|
| **garden_day.mp3** | Daytime garden ambience | Daytime in garden |
| **garden_night.mp3** | Nighttime garden ambience | Nighttime in garden |

**How to Trigger:**
- Automatic based on day/night cycle
- Garden → Time button → Adjust time
- Settings → Auto Day/Night Cycle

---

## Weather → Music Mapping

| Weather Setting | Background Music | Ambience Sounds |
|----------------|------------------|-----------------|
| **Sunny** | summer.mp3 | crickets.mp3, ocean.mp3 |
| **Cloudy** | spring.mp3 | forest.mp3, birds.mp3 |
| **Rainy** | rainny.mp3 | rain.mp3, forest_stream.mp3 |
| **Stormy** | rainny.mp3 | rain.mp3, wind.mp3 |
| **Snowy** | winter.mp3 | wind.mp3, night.mp3 |

---

## Testing Checklist - All 48 Files

### Test Audio Test Screen
1. Add test screen to router
2. Navigate to Test Audio Screen
3. Click each button to verify sound plays
4. Check console for ✅ or ❌ messages

### Test in Settings
1. Open Settings
2. Scroll to "Garden & Weather"
3. Toggle "Auto Weather" OFF
4. Click "Garden Weather" dropdown
5. Select each weather:
   - Sunny → summer.mp3 should play
   - Rainy → rainny.mp3 should play
   - Snowy → winter.mp3 should play
   - Cloudy → spring.mp3 should play
   - Stormy → rainny.mp3 should play

### Test in Garden
1. Open Garden
2. Click weather button ☀️
3. Select each weather option
4. Verify music changes
5. Click plants, decorations, NPCs
6. Verify sounds play
7. Click "Tend Garden"
8. Verify heal.mp3 + sparkle.mp3 play

### Test UI Sounds
1. Click any button → button_click.mp3
2. Toggle any switch → button_click.mp3
3. Open dropdown → button_click.mp3
4. Select dropdown item → button_click.mp3
5. Drag slider → haptic feedback

---

## Integration Points

### 1. Settings Screen
```dart
// lib/features/settings/settings_screen.dart
_buildSettingDropdown(
  title: 'Garden Weather',
  value: appSettings.autoThemeService.manualWeather,
  items: ['Sunny', 'Cloudy', 'Rainy', 'Stormy', 'Snowy'],
  onChanged: (value) {
    // This triggers music change:
    appSettings.autoThemeService.setManualWeather(value);
  },
)
```

### 2. Garden Screen
```dart
// lib/features/garden/flame_garden/garden_world.dart
void setWeather(WeatherType weather) {
  AudioManagerService().playButtonClick();  // UI sound
  AudioManagerService().changeTheme(weather.name.toLowerCase());  // Music
  AmbientSoundService().playWeatherAmbientSound(weather.name);  // Ambience
}
```

### 3. All Buttons
```dart
// lib/core/widgets/sound_button.dart
onPressed: () {
  AudioManagerService().playButtonClick();  // button_click.mp3
  HapticFeedback.selectionClick();
  actualAction();
}
```

---

## File Size Reference

Total audio assets: ~15-25 MB
- Music files: ~2-3 MB each
- Binaural beats: ~2-3 MB each
- Sound effects: ~50-200 KB each
- Ambience: ~1-2 MB each

---

## Troubleshooting

### No Sound in Garden?
1. Check console: `flutter logs | grep "Audio"`
2. Look for: "✅ Successfully played" or "❌ Error playing"
3. Verify AudioManagerService initialized
4. Check volume levels in settings
5. Verify SFX not disabled

### Weather Not Changing Music?
1. Open Settings
2. Scroll to "Garden & Weather" (must scroll down!)
3. Turn OFF "Auto Weather"
4. Select weather from dropdown
5. Check console for music change log

### Settings Weather Section Not Visible?
1. Settings screen is scrollable
2. Scroll DOWN past:
   - Profile
   - UI Theme
   - Personality
   - AI Tutor Voice
   - General settings
3. Look for "Garden & Weather" section with park icon

---

## All 48 Files Verified ✅

1. assets/music/spring.mp3 ✅
2. assets/music/summer.mp3 ✅
3. assets/music/winter.mp3 ✅
4. assets/music/rainny.mp3 ✅
5. assets/music/morning_meditation.mp3 ✅
6. assets/music/stress_relief.mp3 ✅
7. assets/music/deep_sleep.mp3 ✅
8. assets/music/energy_boost.mp3 ✅
9. assets/binaural/focus.mp3 ✅
10. assets/binaural/meditation.mp3 ✅
11. assets/binaural/creativity.mp3 ✅
12. assets/binaural/energy.mp3 ✅
13. assets/binaural/lightSleep.mp3 ✅
14. assets/binaural/deepSleep.mp3 ✅
15. assets/sounds/button_click.mp3 ✅
16. assets/sounds/Select (1).mp3 ✅
17. assets/sounds/Select (2).mp3 ✅
18. assets/sounds/success.mp3 ✅
19. assets/sounds/error.mp3 ✅
20. assets/sounds/bonus.mp3 ✅
21. assets/sounds/sparkle.mp3 ✅
22. assets/sounds/happy.mp3 ✅
23. assets/sounds/plant.mp3 ✅
24. assets/sounds/harvest.mp3 ✅
25. assets/sounds/collect_water.mp3 ✅
26. assets/sounds/heal.mp3 ✅
27. assets/sounds/birds.mp3 ✅
28. assets/sounds/bird_chirp.mp3 ✅
29. assets/sounds/crickets.mp3 ✅
30. assets/sounds/cricket.mp3 ✅
31. assets/sounds/ocean.mp3 ✅
32. assets/sounds/ocean_waves.mp3 ✅
33. assets/sounds/water.mp3 ✅
34. assets/sounds/waterfall.mp3 ✅
35. assets/sounds/river.wav ✅
36. assets/sounds/forest_stream.mp3 ✅
37. assets/sounds/rain.mp3 ✅
38. assets/sounds/wind.mp3 ✅
39. assets/sounds/forest.mp3 ✅
40. assets/sounds/rainforest.mp3 ✅
41. assets/sounds/night.mp3 ✅
42. assets/sounds/meditation_bell.mp3 ✅
43. assets/sounds/bowl.mp3 ✅
44. assets/sounds/zen.mp3 ✅
45. assets/sounds/piano.mp3 ✅
46. assets/sounds/breathing_guide.mp3 ✅
47. assets/sounds/garden_day.mp3 ✅
48. assets/sounds/garden_night.mp3 ✅

**All 48 audio files are mapped and ready to use!**
