// Test screen to verify all audio files work
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/audio_manager_service.dart';
import 'services/audio_constants.dart';

class TestAudioScreen extends StatefulWidget {
  const TestAudioScreen({super.key});

  @override
  State<TestAudioScreen> createState() => _TestAudioScreenState();
}

class _TestAudioScreenState extends State<TestAudioScreen> {
  String _lastPlayed = 'None';
  final _audioManager = AudioManagerService();

  @override
  void initState() {
    super.initState();
    _audioManager.initialize();
  }

  Future<void> _playSound(String label, String path) async {
    setState(() => _lastPlayed = label);
    try {
      await _audioManager.playUISound(path);
      debugPrint('✅ Played: $label - $path');
    } catch (e) {
      debugPrint('❌ Error playing $label: $e');
    }
  }

  Future<void> _playMusic(String label, String path) async {
    setState(() => _lastPlayed = label);
    try {
      await _audioManager.playBackgroundMusic(path);
      debugPrint('✅ Played: $label - $path');
    } catch (e) {
      debugPrint('❌ Error playing $label: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Test Screen'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[900]!, Colors.black87],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Last Played:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastPlayed,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BACKGROUND MUSIC
            _buildSection('🎵 Background Music (8 files)'),
            _buildMusicButton('Spring', AudioConstants.musicSpring),
            _buildMusicButton('Summer', AudioConstants.musicSummer),
            _buildMusicButton('Winter', AudioConstants.musicWinter),
            _buildMusicButton('Rainy', AudioConstants.musicRainy),
            _buildMusicButton(
                'Morning Meditation', AudioConstants.musicMorningMeditation),
            _buildMusicButton(
                'Stress Relief', AudioConstants.musicStressRelief),
            _buildMusicButton('Deep Sleep', AudioConstants.musicDeepSleep),
            _buildMusicButton('Energy Boost', AudioConstants.musicEnergyBoost),

            const SizedBox(height: 20),

            // BINAURAL BEATS
            _buildSection('🧠 Binaural Beats (6 files)'),
            _buildMusicButton('Focus', AudioConstants.binauralFocus),
            _buildMusicButton('Meditation', AudioConstants.binauralMeditation),
            _buildMusicButton('Creativity', AudioConstants.binauralCreativity),
            _buildMusicButton('Energy', AudioConstants.binauralEnergy),
            _buildMusicButton('Light Sleep', AudioConstants.binauralLightSleep),
            _buildMusicButton('Deep Sleep', AudioConstants.binauralDeepSleep),

            const SizedBox(height: 20),

            // UI SOUNDS
            _buildSection('🔊 UI Sounds (8 files)'),
            _buildSoundButton('Button Click', AudioConstants.uiButtonClick),
            _buildSoundButton('Select 1', AudioConstants.uiSelect1),
            _buildSoundButton('Select 2', AudioConstants.uiSelect2),
            _buildSoundButton('Success', AudioConstants.uiSuccess),
            _buildSoundButton('Error', AudioConstants.uiError),
            _buildSoundButton('Bonus', AudioConstants.uiBonus),
            _buildSoundButton('Sparkle', AudioConstants.uiSparkle),
            _buildSoundButton('Happy', AudioConstants.uiHappy),

            const SizedBox(height: 20),

            // GARDEN SOUNDS
            _buildSection('🌱 Garden Actions (4 files)'),
            _buildSoundButton('Plant', AudioConstants.gardenPlant),
            _buildSoundButton('Harvest', AudioConstants.gardenHarvest),
            _buildSoundButton('Water', AudioConstants.gardenWater),
            _buildSoundButton('Heal', AudioConstants.gardenHeal),

            const SizedBox(height: 20),

            // NATURE AMBIENCE
            _buildSection('🌿 Nature Ambience (15 files)'),
            _buildSoundButton('Birds', AudioConstants.natureBirds),
            _buildSoundButton('Bird Chirp', AudioConstants.natureBirdChirp),
            _buildSoundButton('Crickets', AudioConstants.natureCrickets),
            _buildSoundButton('Cricket', AudioConstants.natureCricket),
            _buildSoundButton('Ocean', AudioConstants.natureOcean),
            _buildSoundButton('Ocean Waves', AudioConstants.natureOceanWaves),
            _buildSoundButton('Water', AudioConstants.natureWater),
            _buildSoundButton('Waterfall', AudioConstants.natureWaterfall),
            _buildSoundButton('River', AudioConstants.natureRiver),
            _buildSoundButton(
                'Forest Stream', AudioConstants.natureForestStream),
            _buildSoundButton('Rain', AudioConstants.natureRain),
            _buildSoundButton('Wind', AudioConstants.natureWind),
            _buildSoundButton('Forest', AudioConstants.natureForest),
            _buildSoundButton('Rainforest', AudioConstants.natureRainforest),
            _buildSoundButton('Night', AudioConstants.natureNight),

            const SizedBox(height: 20),

            // MEDITATION SOUNDS
            _buildSection('🧘 Meditation Sounds (5 files)'),
            _buildSoundButton('Bell', AudioConstants.meditationBell),
            _buildSoundButton('Bowl', AudioConstants.meditationBowl),
            _buildSoundButton('Zen', AudioConstants.meditationZen),
            _buildSoundButton('Piano', AudioConstants.meditationPiano),
            _buildSoundButton(
                'Breathing Guide', AudioConstants.meditationBreathingGuide),

            const SizedBox(height: 20),

            // GARDEN TIME
            _buildSection('⏰ Garden Time (2 files)'),
            _buildSoundButton('Garden Day', AudioConstants.gardenDay),
            _buildSoundButton('Garden Night', AudioConstants.gardenNight),

            const SizedBox(height: 40),

            // TOTAL COUNT
            Card(
              color: Colors.green[800],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '✅ Total: 48 Audio Files\n8 Music + 6 Binaural + 34 Sound Effects',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSoundButton(String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          _playSound(label, path);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Text(
              path.split('/').last,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicButton(String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          _playMusic(label, path);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            Text(
              path.split('/').last,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
