# 🎮 Complete Usage Examples - Garden Audio & Visual Effects

## Quick Start Integration

### 1. Simple Button with Sound
```dart
import 'package:pranaverse/services/audio_ui_wrapper.dart';

// Automatic button click sound
SoundElevatedButton(
  onPressed: () {
    // Your action here
  },
  child: Text('Plant Seed'),
)
```

### 2. Custom Sound for Special Actions
```dart
import 'package:pranaverse/services/audio_ui_wrapper.dart';
import 'package:pranaverse/services/audio_constants.dart';

// Use sparkle sound for magical actions
SoundElevatedButton(
  soundPath: AudioConstants.uiSparkle,
  onPressed: () {
    // Magical action
  },
  child: Text('✨ Magic Grow'),
)
```

### 3. Garden Action with Full Effects
```dart
import 'package:pranaverse/features/garden/utils/garden_effects_helper.dart';

// Plant a seed with audio + visual effects
Future<void> plantSeed(BuildContext context) async {
  await GardenEffectsHelper.showPlantEffect(
    context,
    position: Offset(200, 300), // Position on screen
  );
  
  // Your planting logic here
  addPlantToGarden();
}
```

---

## Complete Garden Screen Integration

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pranaverse/services/audio_manager_service.dart';
import 'package:pranaverse/services/audio_constants.dart';
import 'package:pranaverse/services/audio_ui_wrapper.dart';
import 'package:pranaverse/features/garden/utils/garden_effects_helper.dart';
import 'package:pranaverse/features/garden/widgets/celebration_effects.dart';

class MyGardenScreen extends StatefulWidget {
  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen> {
  final AudioManagerService _audio = AudioManagerService();
  int _coins = 100;
  int _xp = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await _audio.initialize();
    // Start with spring theme
    await _audio.changeTheme('spring');
    // Set day ambience
    await _audio.setGardenAmbience(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Garden'),
        actions: [
          // Theme selector with sound
          SoundIconButton(
            icon: Icon(Icons.wb_sunny),
            onPressed: () => _showThemeSelector(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          _buildStatusBar(),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                _buildGardenTile('Empty', isPlanted: false),
                _buildGardenTile('Growing 🌱', isPlanted: true),
                _buildGardenTile('Mature 🌸', isPlanted: true, canHarvest: true),
                // ... more tiles
              ],
            ),
          ),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.green.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip(Icons.monetization_on, '$_coins', Colors.amber),
          _buildStatChip(Icons.stars, '$_xp XP', Colors.purple),
          _buildStatChip(Icons.emoji_events, 'Lvl $_level', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenTile(String status, {
    bool isPlanted = false,
    bool canHarvest = false,
  }) {
    return SoundCard(
      margin: EdgeInsets.all(4),
      soundPath: isPlanted 
        ? AudioConstants.uiSelect1 
        : AudioConstants.uiButtonClick,
      onTap: () {
        if (!isPlanted) {
          _plantSeed();
        } else if (canHarvest) {
          _harvestPlant();
        } else {
          _waterPlant();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown.shade300,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPlanted ? Colors.green : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Plant button with custom sound
          SoundElevatedButton(
            soundPath: AudioConstants.gardenPlant,
            onPressed: () => _plantSeed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              children: [
                Icon(Icons.eco),
                SizedBox(width: 8),
                Text('Plant'),
              ],
            ),
          ),
          
          // Water button
          SoundElevatedButton(
            soundPath: AudioConstants.gardenWater,
            onPressed: () => _waterPlant(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              children: [
                Icon(Icons.water_drop),
                SizedBox(width: 8),
                Text('Water'),
              ],
            ),
          ),
          
          // Harvest button
          SoundElevatedButton(
            soundPath: AudioConstants.gardenHarvest,
            onPressed: () => _harvestPlant(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Row(
              children: [
                Icon(Icons.grass),
                SizedBox(width: 8),
                Text('Harvest'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ ACTION HANDLERS ============

  Future<void> _plantSeed() async {
    if (_coins < 10) {
      await GardenEffectsHelper.showErrorEffect(
        context,
        'Not enough coins! Need 10 coins to plant.',
      );
      return;
    }

    // Show planting effect
    await GardenEffectsHelper.showPlantEffect(context);
    
    setState(() {
      _coins -= 10;
    });
    
    await GardenEffectsHelper.showSuccessMessage(
      context,
      '🌱 Seed planted successfully!',
    );
  }

  Future<void> _waterPlant() async {
    await GardenEffectsHelper.showWaterEffect(context);
    
    // Random chance to grow
    if (DateTime.now().millisecond % 3 == 0) {
      await Future.delayed(Duration(milliseconds: 500));
      await GardenEffectsHelper.showGrowthEffect(context);
      
      setState(() {
        _xp += 5;
      });
    }
  }

  Future<void> _harvestPlant() async {
    final coinsEarned = 25;
    final xpEarned = 15;
    
    await GardenEffectsHelper.showHarvestEffect(
      context,
      coins: coinsEarned,
      xp: xpEarned,
    );
    
    setState(() {
      _coins += coinsEarned;
      _xp += xpEarned;
      
      // Check for level up
      if (_xp >= _level * 100) {
        _levelUp();
      }
    });
  }

  Future<void> _levelUp() async {
    setState(() {
      _level++;
      _xp = 0;
    });
    
    await GardenEffectsHelper.showLevelUpEffect(context, _level);
    
    // Check for achievement at level 5
    if (_level == 5) {
      await Future.delayed(Duration(milliseconds: 500));
      await GardenEffectsHelper.showAchievementEffect(
        context,
        'Garden Apprentice',
        'Reached Level 5!',
        100,
      );
    }
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Garden Theme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildThemeOption('Spring', '🌸', 'spring'),
              _buildThemeOption('Summer', '☀️', 'summer'),
              _buildThemeOption('Rainy', '🌧️', 'rainy'),
              _buildThemeOption('Winter', '❄️', 'winter'),
              _buildThemeOption('Night', '🌙', 'night'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String name, String emoji, String theme) {
    return SoundListTile(
      leading: Text(emoji, style: TextStyle(fontSize: 32)),
      title: Text(name),
      onTap: () async {
        await _audio.changeTheme(theme);
        Navigator.pop(context);
        
        await GardenEffectsHelper.showSuccessMessage(
          context,
          '$emoji Theme changed to $name!',
        );
      },
    );
  }

  @override
  void dispose() {
    // Audio manager is singleton, no need to dispose
    super.dispose();
  }
}
```

---

## Settings Screen with Audio Controls

```dart
import 'package:flutter/material.dart';
import 'package:pranaverse/services/audio_manager_service.dart';
import 'package:pranaverse/services/audio_ui_wrapper.dart';

class AudioSettingsScreen extends StatefulWidget {
  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  final AudioManagerService _audio = AudioManagerService();
  
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late bool _ambienceEnabled;
  late double _musicVolume;
  late double _sfxVolume;
  late double _ambienceVolume;

  @override
  void initState() {
    super.initState();
    _musicEnabled = _audio.isMusicEnabled;
    _sfxEnabled = _audio.areSfxEnabled;
    _ambienceEnabled = _audio.isAmbienceEnabled;
    _musicVolume = _audio.musicVolume;
    _sfxVolume = _audio.sfxVolume;
    _ambienceVolume = _audio.ambienceVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Music Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Background Music',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SoundSwitch(
                        value: _musicEnabled,
                        onChanged: (value) async {
                          await _audio.toggleMusic(value);
                          setState(() => _musicEnabled = value);
                        },
                      ),
                    ],
                  ),
                  if (_musicEnabled) ...[
                    SizedBox(height: 16),
                    Text('Volume'),
                    SoundSlider(
                      value: _musicVolume,
                      onChanged: (value) {
                        setState(() => _musicVolume = value);
                      },
                      onChangeEnd: (value) async {
                        await _audio.setMusicVolume(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sound Effects Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volume_up, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Sound Effects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SoundSwitch(
                        value: _sfxEnabled,
                        onChanged: (value) {
                          _audio.toggleSfx(value);
                          setState(() => _sfxEnabled = value);
                        },
                      ),
                    ],
                  ),
                  if (_sfxEnabled) ...[
                    SizedBox(height: 16),
                    Text('Volume'),
                    SoundSlider(
                      value: _sfxVolume,
                      onChanged: (value) {
                        setState(() => _sfxVolume = value);
                      },
                      onChangeEnd: (value) async {
                        await _audio.setSfxVolume(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Ambience Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.nature, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Nature Ambience',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SoundSwitch(
                        value: _ambienceEnabled,
                        onChanged: (value) async {
                          await _audio.toggleAmbience(value);
                          setState(() => _ambienceEnabled = value);
                        },
                      ),
                    ],
                  ),
                  if (_ambienceEnabled) ...[
                    SizedBox(height: 16),
                    Text('Volume'),
                    SoundSlider(
                      value: _ambienceVolume,
                      onChanged: (value) {
                        setState(() => _ambienceVolume = value);
                      },
                      onChangeEnd: (value) async {
                        await _audio.setAmbienceVolume(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Meditation Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:pranaverse/services/audio_manager_service.dart';
import 'package:pranaverse/features/garden/utils/garden_effects_helper.dart';

class MeditationScreen extends StatefulWidget {
  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final AudioManagerService _audio = AudioManagerService();
  bool _isActive = false;
  int _duration = 5; // minutes

  Future<void> _startMeditation(String type) async {
    // Play bell to begin
    await GardenEffectsHelper.playMeditationBell();
    
    setState(() => _isActive = true);
    
    // Start meditation music
    await _audio.startMeditationSession(type);
    
    // Timer for duration
    await Future.delayed(Duration(minutes: _duration));
    
    // Play bowl to end
    await GardenEffectsHelper.playSingingBowl();
    
    setState(() => _isActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meditation')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose Meditation Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            
            _buildMeditationType(
              '🎯 Focus',
              'Enhance concentration',
              'focus',
            ),
            _buildMeditationType(
              '😌 Stress Relief',
              'Release tension',
              'stress',
            ),
            _buildMeditationType(
              '💤 Sleep',
              'Deep relaxation',
              'sleep',
            ),
            _buildMeditationType(
              '⚡ Energy',
              'Boost vitality',
              'energy',
            ),
            _buildMeditationType(
              '🎨 Creativity',
              'Inspire innovation',
              'creativity',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationType(String title, String subtitle, String type) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Text(
          title.split(' ')[0],
          style: TextStyle(fontSize: 32),
        ),
        title: Text(
          title.split(' ').skip(1).join(' '),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.play_arrow),
        onTap: _isActive ? null : () => _startMeditation(type),
      ),
    );
  }
}
```

---

## Quick Reference Cheat Sheet

### Play Sounds Directly
```dart
final audio = AudioManagerService();

// UI Sounds
await audio.playButtonClick();
await audio.playSuccess();
await audio.playError();
await audio.playBonusSound();
await audio.playSparkleSound();

// Garden Actions
await audio.playPlantSound();
await audio.playWaterSound();
await audio.playHarvestSound();
await audio.playHealSound();

// Meditation
await audio.playMeditationBell();
await audio.playSingingBowl();
```

### Show Effects
```dart
// Plant effect
await GardenEffectsHelper.showPlantEffect(context);

// Water effect
await GardenEffectsHelper.showWaterEffect(context);

// Harvest with rewards
await GardenEffectsHelper.showHarvestEffect(
  context,
  coins: 50,
  xp: 20,
);

// Achievement
await GardenEffectsHelper.showAchievementEffect(
  context,
  'First Plant',
  'You planted your first seed!',
  25,
);

// Level up
await GardenEffectsHelper.showLevelUpEffect(context, 5);

// Messages
await GardenEffectsHelper.showSuccessMessage(context, 'Success!');
await GardenEffectsHelper.showErrorEffect(context, 'Error!');
```

### Theme Changes
```dart
await audio.changeTheme('spring');  // Plays spring music + birds
await audio.changeTheme('summer');  // Plays summer music + crickets
await audio.changeTheme('rainy');   // Plays rain music + rain sounds
await audio.changeTheme('winter');  // Plays winter music + wind
await audio.changeTheme('night');   // Plays night ambience + crickets
```

---

**Everything you need for an amazing, immersive garden experience! 🌈✨🎵**
