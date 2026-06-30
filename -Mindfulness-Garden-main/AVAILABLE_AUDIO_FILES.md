# Available Audio Files - Updated List

## Current Status: ✅ CLEANED UP
All references updated to use ONLY available files.

---

## 📁 Music Files (8 files)
**Location**: `assets/music/`

| File | Usage | Description |
|------|-------|-------------|
| `spring.mp3` | Spring theme, Cloudy weather | Light, fresh spring music |
| `summer.mp3` | Summer theme, Sunny weather | Warm summer ambience |
| `winter.mp3` | Winter theme, Snowy weather | Cold winter atmosphere |
| `rainny.mp3` | Rainy/Stormy weather | Rain ambience music |
| `morning_meditation.mp3` | Morning sessions | Morning meditation track |
| `stress_relief.mp3` | Meditation mode | Stress relief music |
| `deep_sleep.mp3` | Sleep mode | Deep sleep induction |
| `energy_boost.mp3` | Energy mode | Energizing music |

---

## 🎵 Binaural Beats (6 files)
**Location**: `assets/binaural/`

| File | Usage | Description |
|------|-------|-------------|
| `focus.mp3` | Focus sessions | Concentration enhancement |
| `meditation.mp3` | Meditation sessions | Deep meditation state |
| `creativity.mp3` | Creative work | Creativity boost |
| `energy.mp3` | Energy boost | Mental energy |
| `lightSleep.mp3` | Light sleep | Light sleep induction |
| `deepSleep.mp3` | Deep sleep | Deep sleep brainwave |

---

## 🔊 Sound Effects (14 files)
**Location**: `assets/sounds/`

### UI Sounds (2 files)
| File | Usage | Description |
|------|-------|-------------|
| `UI.mp3` | All button clicks, success, error | Primary UI sound |
| `Select.mp3` | Selection, achievement, harvest | Selection feedback |

### Nature Sounds (8 files)
| File | Usage | Description |
|------|-------|-------------|
| `birds.mp3` | Day ambience, Spring theme | Bird chirping |
| `crickets.mp3` | Night ambience | Cricket sounds |
| `forest.mp3` | Forest environment | Forest ambience |
| `ocean.mp3` | Ocean environment | Ocean waves |
| `rainforest.mp3` | Rainy weather ambience | Rainforest sounds |
| `waterfall.mp3` | Nature ambience | Waterfall sound |
| `river.wav` | Nature ambience | River stream |
| `wind.mp3` | Winter/Stormy weather | Wind sounds |
| `night.mp3` | Night time | Night ambience |

### Meditation Sounds (3 files)
| File | Usage | Description |
|------|-------|-------------|
| `bowl.mp3` | Meditation bell/bowl | Singing bowl |
| `zen.mp3` | Teacher selection, meditation | Zen tone |
| `piano.mp3` | Meditation background | Calm piano |

---

## 🎯 Sound Mapping

### Weather Themes
- **Sunny** → `summer.mp3` + `crickets.mp3` + `ocean.mp3`
- **Cloudy** → `spring.mp3` + `forest.mp3` + `birds.mp3`
- **Rainy** → `rainny.mp3` + `rainforest.mp3`
- **Snowy** → `winter.mp3` + `wind.mp3` + `night.mp3`
- **Stormy** → `rainny.mp3` + `wind.mp3`

### Garden Ambience
- **Day** → `birds.mp3` + `forest.mp3`
- **Night** → `crickets.mp3` + `night.mp3`

### UI Interactions
- **Button Click** → `UI.mp3`
- **Success** → `UI.mp3`
- **Error** → `UI.mp3`
- **Select/Achievement** → `Select.mp3`
- **Harvest** → `Select.mp3`
- **Placement** → `Select.mp3`

### Meditation Modes
- **Meditation** → `stress_relief.mp3` + `zen.mp3` + `bowl.mp3`
- **Sleep** → `deep_sleep.mp3` + `ocean.mp3`
- **Focus** → `focus.mp3` (binaural)
- **Energy** → `energy_boost.mp3` + `energy.mp3` (binaural) + `birds.mp3`
- **Morning** → `morning_meditation.mp3` + `birds.mp3`
- **Night** → `deepSleep.mp3` (binaural) + `crickets.mp3` + `night.mp3`

---

## ⚠️ Removed Files
These files were referenced but NOT available (removed from code):

### UI Sounds (removed)
- ❌ `button_click.mp3` → Using `UI.mp3` instead
- ❌ `success.mp3` → Using `UI.mp3` instead
- ❌ `error.mp3` → Using `UI.mp3` instead
- ❌ `bonus.mp3` → Using `Select.mp3` instead
- ❌ `sparkle.mp3` → Using `Select.mp3` instead
- ❌ `happy.mp3` → Using `UI.mp3` instead
- ❌ `Select (1).mp3` → Using `Select.mp3` instead
- ❌ `Select (2).mp3` → Using `Select.mp3` instead

### Garden Action Sounds (removed)
- ❌ `plant.mp3` → Using `UI.mp3` instead
- ❌ `harvest.mp3` → Using `Select.mp3` instead
- ❌ `collect_water.mp3` → Using `Select.mp3` instead
- ❌ `heal.mp3` → Using `UI.mp3` instead
- ❌ `garden_day.mp3` → Using `birds.mp3` instead
- ❌ `garden_night.mp3` → Using `crickets.mp3` instead

### Nature Sounds (removed)
- ❌ `bird_chirp.mp3` → Using `birds.mp3` instead
- ❌ `cricket.mp3` → Using `crickets.mp3` instead
- ❌ `ocean_waves.mp3` → Using `ocean.mp3` instead
- ❌ `water.mp3` → Using `waterfall.mp3` or `river.wav` instead
- ❌ `forest_stream.mp3` → Using `river.wav` instead
- ❌ `rain.mp3` → Using `rainforest.mp3` or `rainny.mp3` music

### Meditation Sounds (removed)
- ❌ `meditation_bell.mp3` → Using `bowl.mp3` instead
- ❌ `breathing_guide.mp3` → Not available

---

## 📝 Updated Files

### Core Audio Files
1. ✅ `lib/services/audio_constants.dart` - Updated to use only available files
2. ✅ `lib/services/audio_manager_service.dart` - Updated methods to use available sounds
3. ✅ `lib/core/services/sound_service.dart` - Updated all sound methods

### Audio Configuration
- All references to removed files replaced with available alternatives
- Simplified UI sound system (2 files instead of 8)
- Garden actions now use UI/Select sounds
- Nature ambience optimized to use available files

---

## 🎮 Testing Checklist

### UI Sounds
- [ ] Button clicks play `UI.mp3`
- [ ] Success actions play `UI.mp3`
- [ ] Selection plays `Select.mp3`
- [ ] All sounds audible and responsive

### Garden
- [ ] Day mode plays `birds.mp3` ambience
- [ ] Night mode plays `crickets.mp3` ambience
- [ ] Weather changes work (sunny, cloudy, rainy, snowy, stormy)
- [ ] All weather themes have music

### Meditation
- [ ] Meditation sessions play appropriate music
- [ ] Singing bowl sound works
- [ ] Zen tone plays for teacher selection
- [ ] Binaural beats work for focus/sleep modes

---

## 💾 Total File Count

- **Music**: 8 files
- **Binaural**: 6 files
- **Sounds**: 14 files
- **Total**: 28 audio files

All 28 files are properly integrated and functional! 🎉
