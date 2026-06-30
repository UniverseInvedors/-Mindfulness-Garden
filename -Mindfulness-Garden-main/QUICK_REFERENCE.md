# 🚀 Quick Reference Card - Garden Audio & VFX

## 📖 Essential Files to Read First

1. **README_GARDEN_ENHANCEMENTS.md** ← Start here!
2. **COMPLETE_USAGE_EXAMPLES.md** ← Copy-paste code
3. **AUDIO_INTEGRATION_GUIDE.md** ← Audio mapping

## ⚡ Quick Imports

```dart
// Audio
import 'package:pranaverse/services/audio_manager_service.dart';
import 'package:pranaverse/services/audio_constants.dart';

// UI Widgets with Sound
import 'package:pranaverse/services/audio_ui_wrapper.dart';

// Garden Effects
import 'package:pranaverse/features/garden/utils/garden_effects_helper.dart';
import 'package:pranaverse/features/garden/widgets/celebration_effects.dart';
```

## 🎵 Play Sounds (One-Liners)

```dart
final audio = AudioManagerService();

// UI Sounds
await audio.playButtonClick();          // Button presses
await audio.playSuccess();              // Success actions
await audio.playError();                // Errors
await audio.playBonusSound();           // Rewards
await audio.playSparkleSound();         // Magic effects

// Garden Actions
await audio.playPlantSound();           // Planting
await audio.playWaterSound();           // Watering
await audio.playHarvestSound();         // Harvesting
await audio.playHealSound();            // Healing/caring

// Meditation
await audio.playMeditationBell();       // Session start
await audio.playSingingBowl();          // Session end
```

## 🎨 Show Effects (One-Liners)

```dart
// Plant effect (green sparkles + sound)
await GardenEffectsHelper.showPlantEffect(context);

// Water effect (blue sparkles + sound)
await GardenEffectsHelper.showWaterEffect(context);

// Harvest (confetti + coins + XP + sounds)
await GardenEffectsHelper.showHarvestEffect(context, coins: 50, xp: 20);

// Growth sparkle (yellow particles)
await GardenEffectsHelper.showGrowthEffect(context);

// Achievement (confetti + dialog + sounds)
await GardenEffectsHelper.showAchievementEffect(
  context, 'Title', 'Description', 100,
);

// Level up (confetti + dialog + sounds)
await GardenEffectsHelper.showLevelUpEffect(context, 5);

// Success message (snackbar + sound)
await GardenEffectsHelper.showSuccessMessage(context, 'Success!');

// Error message (snackbar + sound)
await GardenEffectsHelper.showErrorEffect(context, 'Error message');
```

## 🎼 Change Themes

```dart
// Spring: spring.mp3 + birds.mp3
await audio.changeTheme('spring');

// Summer: summer.mp3 + crickets.mp3
await audio.changeTheme('summer');

// Rainy: rainny.mp3 + rain.mp3
await audio.changeTheme('rainy');

// Winter: winter.mp3 + wind.mp3
await audio.changeTheme('winter');

// Night: garden_night.mp3 + crickets.mp3
await audio.changeTheme('night');

// Morning: morning_meditation.mp3
await audio.changeTheme('morning');

// Meditation: stress_relief.mp3
await audio.changeTheme('meditation');
```

## 🔘 Buttons with Sound

```dart
// Auto button click sound
SoundElevatedButton(
  onPressed: () { /* action */ },
  child: Text('Click Me'),
)

// Custom sound
SoundElevatedButton(
  soundPath: AudioConstants.uiSparkle,
  onPressed: () { /* action */ },
  child: Text('Magic Action'),
)

// Icon button
SoundIconButton(
  icon: Icon(Icons.add),
  onPressed: () { /* action */ },
)

// Card with tap sound
SoundCard(
  onTap: () { /* action */ },
  child: /* your content */,
)

// List tile with sound
SoundListTile(
  title: Text('Item'),
  onTap: () { /* action */ },
)
```

## 🎛️ Audio Controls

```dart
final audio = AudioManagerService();

// Toggle on/off
await audio.toggleMusic(true);          // Background music
audio.toggleSfx(true);                  // Sound effects
await audio.toggleAmbience(true);       // Nature sounds

// Volume (0.0 to 1.0)
await audio.setMusicVolume(0.7);        // 70% music
await audio.setSfxVolume(0.8);          // 80% effects
await audio.setAmbienceVolume(0.5);     // 50% ambience

// Fade effects
await audio.fadeOutMusic();             // Fade out over 2s
await audio.fadeInMusic();              // Fade in over 2s
```

## 📁 All Audio Files (48 Total)

### Background Music (8)
```dart
AudioConstants.musicSpring              // spring.mp3
AudioConstants.musicSummer              // summer.mp3
AudioConstants.musicWinter              // winter.mp3
AudioConstants.musicRainy               // rainny.mp3
AudioConstants.musicMorningMeditation   // morning_meditation.mp3
AudioConstants.musicStressRelief        // stress_relief.mp3
AudioConstants.musicDeepSleep           // deep_sleep.mp3
AudioConstants.musicEnergyBoost         // energy_boost.mp3
```

### Binaural Beats (6)
```dart
AudioConstants.binauralFocus            // focus.mp3
AudioConstants.binauralMeditation       // meditation.mp3
AudioConstants.binauralCreativity       // creativity.mp3
AudioConstants.binauralEnergy           // energy.mp3
AudioConstants.binauralLightSleep       // lightSleep.mp3
AudioConstants.binauralDeepSleep        // deepSleep.mp3
```

### UI Sounds (8)
```dart
AudioConstants.uiButtonClick            // button_click.mp3
AudioConstants.uiSelect1                // Select (1).mp3
AudioConstants.uiSelect2                // Select (2).mp3
AudioConstants.uiSuccess                // success.mp3
AudioConstants.uiError                  // error.mp3
AudioConstants.uiBonus                  // bonus.mp3
AudioConstants.uiSparkle                // sparkle.mp3
AudioConstants.uiHappy                  // happy.mp3
```

### Garden Actions (4)
```dart
AudioConstants.gardenPlant              // plant.mp3
AudioConstants.gardenHarvest            // harvest.mp3
AudioConstants.gardenWater              // collect_water.mp3
AudioConstants.gardenHeal               // heal.mp3
```

### Nature (15)
```dart
AudioConstants.natureBirds              // birds.mp3
AudioConstants.natureBirdChirp          // bird_chirp.mp3
AudioConstants.natureCrickets           // crickets.mp3
AudioConstants.natureCricket            // cricket.mp3
AudioConstants.natureOcean              // ocean.mp3
AudioConstants.natureOceanWaves         // ocean_waves.mp3
AudioConstants.natureWater              // water.mp3
AudioConstants.natureWaterfall          // waterfall.mp3
AudioConstants.natureRiver              // river.wav
AudioConstants.natureForestStream       // forest_stream.mp3
AudioConstants.natureRain               // rain.mp3
AudioConstants.natureWind               // wind.mp3
AudioConstants.natureForest             // forest.mp3
AudioConstants.natureRainforest         // rainforest.mp3
AudioConstants.natureNight              // night.mp3
```

### Meditation (5)
```dart
AudioConstants.meditationBell           // meditation_bell.mp3
AudioConstants.meditationBowl           // bowl.mp3
AudioConstants.meditationZen            // zen.mp3
AudioConstants.meditationPiano          // piano.mp3
AudioConstants.meditationBreathingGuide // breathing_guide.mp3
```

### Day/Night (2)
```dart
AudioConstants.gardenDay                // garden_day.mp3
AudioConstants.gardenNight              // garden_night.mp3
```

## 📱 Haptic Feedback

```dart
import 'package:flutter/services.dart';

HapticFeedback.lightImpact();       // Subtle (water, NPCs)
HapticFeedback.mediumImpact();      // Moderate (plant, decor)
HapticFeedback.heavyImpact();       // Strong (achievements)
HapticFeedback.vibrate();           // Error feedback
```

## 🎯 Common Patterns

### Plant Action Pattern
```dart
Future<void> plantSeed(BuildContext context) async {
  // Show effect
  await GardenEffectsHelper.showPlantEffect(context);
  
  // Update game state
  setState(() {
    coins -= 10;
    plantsGrown++;
  });
  
  // Show feedback
  await GardenEffectsHelper.showSuccessMessage(
    context, 
    '🌱 Seed planted!',
  );
}
```

### Harvest Pattern
```dart
Future<void> harvestPlant(BuildContext context) async {
  final coinsEarned = 25;
  final xpEarned = 15;
  
  // Show effect with rewards
  await GardenEffectsHelper.showHarvestEffect(
    context,
    coins: coinsEarned,
    xp: xpEarned,
  );
  
  // Update state
  setState(() {
    coins += coinsEarned;
    xp += xpEarned;
  });
}
```

### Theme Change Pattern
```dart
Future<void> changeSeasonTheme(String season) async {
  await AudioManagerService().changeTheme(season);
  await GardenEffectsHelper.showSuccessMessage(
    context,
    '🌈 Theme changed to $season!',
  );
}
```

## 🔧 Initialization

### In main.dart
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initialization
  
  await AudioManagerService().initialize();
  
  runApp(MyApp());
}
```

### In Screen's initState
```dart
@override
void initState() {
  super.initState();
  _initAudio();
}

Future<void> _initAudio() async {
  final audio = AudioManagerService();
  await audio.initialize();
  await audio.changeTheme('spring');
  await audio.setGardenAmbience(true);
}
```

## 🎨 Custom Dialog Template

```dart
showDialog(
  context: context,
  builder: (context) => Dialog(
    backgroundColor: Colors.transparent,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          // Flexible with SingleChildScrollView
          // Content in GridView
        ],
      ),
    ),
  ),
);
```

## 📊 Performance Tips

1. **Limit particle counts** - 20-30 max for mobile
2. **Reuse audio players** - Don't create new ones
3. **Dispose properly** - Clean up controllers
4. **Use const constructors** - Where possible
5. **Cache assets** - Preload frequently used files
6. **Monitor memory** - Check for leaks
7. **Test on device** - Not just simulator

## 🐛 Quick Debugging

```dart
// Check if audio is playing
print('Music: ${AudioManagerService().isMusicEnabled}');
print('SFX: ${AudioManagerService().areSfxEnabled}');
print('Current theme: ${AudioManagerService().currentTheme}');

// Test individual sounds
await AudioManagerService().playSuccess();  // Should hear sound

// Check volumes
print('Music volume: ${AudioManagerService().musicVolume}');
print('SFX volume: ${AudioManagerService().sfxVolume}');
```

## 📚 Documentation Links

- [Main README](README_GARDEN_ENHANCEMENTS.md)
- [Complete Examples](lib/features/garden/COMPLETE_USAGE_EXAMPLES.md)
- [Audio Guide](lib/features/garden/AUDIO_INTEGRATION_GUIDE.md)
- [Testing Checklist](TESTING_CHECKLIST.md)
- [Implementation Complete](IMPLEMENTATION_COMPLETE.md)

---

## ⚡ Ultra-Quick Start (3 Steps)

### Step 1: Add Sound to Button
```dart
import 'package:pranaverse/services/audio_ui_wrapper.dart';

SoundElevatedButton(
  onPressed: () => print('Clicked!'),
  child: Text('Click Me'),
)
```

### Step 2: Show Effect
```dart
import 'package:pranaverse/features/garden/utils/garden_effects_helper.dart';

await GardenEffectsHelper.showPlantEffect(context);
```

### Step 3: Change Theme
```dart
import 'package:pranaverse/services/audio_manager_service.dart';

await AudioManagerService().changeTheme('spring');
```

**That's it! You're using the full audio/VFX system! 🎉**

---

**Keep this card handy for quick reference! 📌**
