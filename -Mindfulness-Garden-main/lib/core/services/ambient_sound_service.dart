import 'package:audioplayers/audioplayers.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:flutter/foundation.dart';

/// Service to play ambient background sounds based on meditation scene environment
/// Supports layering: background music + nature ambience sounds
class AmbientSoundService {
  static final AmbientSoundService _instance = AmbientSoundService._internal();
  factory AmbientSoundService() => _instance;
  AmbientSoundService._internal();

  final AudioPlayer _ambientPlayer = AudioPlayer();
  String? _currentSoundPath;
  bool _isPlaying = false;

  // Separate player for layered nature sounds (birds, wind, etc.)
  final AudioPlayer _naturePlayer = AudioPlayer();
  bool _isNaturePlaying = false;

  /// Start ambient sound for the given environment
  Future<void> startAmbientSound(SceneEnvironment environment) async {
    final soundPath = _getSoundPath(environment);
    if (soundPath == null) {
      await stopAmbientSound();
      return;
    }

    await _playSoundAsset(soundPath);

    // Also play layered nature sounds for enhanced ambience
    final naturePath = _getNatureSoundPath(environment);
    if (naturePath != null) {
      await _playNatureSound(naturePath);
    }
  }

  /// Start an ambient sound based on the selected garden weather.
  Future<void> playWeatherAmbientSound(String weatherName) async {
    final soundPath = getWeatherSoundPath(weatherName);
    if (soundPath == null) {
      await stopAmbientSound();
      return;
    }

    await _playSoundAsset(soundPath);
  }

  /// Get the ambient sound asset path for a weather selection.
  String? getWeatherSoundPath(String weatherName) {
    final normalizedWeather = weatherName.toLowerCase().trim();
    switch (normalizedWeather) {
      case 'sunny':
        return 'music/summer.mp3';
      case 'cloudy':
        return 'music/spring.mp3';
      case 'rainy':
        return 'music/rainny.mp3';
      case 'snowy':
        return 'music/winter.mp3';
      case 'stormy':
        return 'music/rainny.mp3';
      default:
        return null;
    }
  }

  Future<void> _playSoundAsset(String soundPath) async {
    if (_isPlaying && _currentSoundPath == soundPath) return;

    try {
      await SoundService().playAmbientTrack(soundPath);
      _isPlaying = true;
      _currentSoundPath = soundPath;
      if (kDebugMode) debugPrint('🎵 Ambient music: $soundPath');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error playing ambient sound: $e');
    }
  }

  /// Play layered nature sounds (birds, wind, ocean, etc.) at lower volume
  Future<void> _playNatureSound(String soundPath) async {
    try {
      await _naturePlayer.stop();
      await _naturePlayer.setReleaseMode(ReleaseMode.loop);
      await _naturePlayer.setVolume(0.25); // Lower volume for nature layer

      final cleanPath = soundPath.replaceFirst('assets/', '');
      await _naturePlayer.play(AssetSource(cleanPath));
      _isNaturePlaying = true;

      if (kDebugMode) debugPrint('🌿 Nature layer: $cleanPath');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error playing nature sound: $e');
    }
  }

  /// Stop ambient sound
  Future<void> stopAmbientSound() async {
    try {
      await SoundService().stopBg();
      await _naturePlayer.stop();
      _isPlaying = false;
      _isNaturePlaying = false;
      _currentSoundPath = null;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error stopping ambient sound: $e');
    }
  }

  /// Pause ambient sound (can resume later)
  Future<void> pauseAmbientSound() async {
    try {
      await SoundService().pauseBg();
      await _naturePlayer.pause();
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error pausing ambient sound: $e');
    }
  }

  /// Resume ambient sound
  Future<void> resumeAmbientSound() async {
    try {
      if (!_isPlaying) return;
      await SoundService().resumeBg();
      if (_isNaturePlaying) {
        await _naturePlayer.resume();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Error resuming ambient sound: $e');
    }
  }

  /// Get background music path for environment
  String? _getSoundPath(SceneEnvironment environment) {
    switch (environment) {
      case SceneEnvironment.forest:
        return 'music/spring.mp3'; // Spring vibes
      case SceneEnvironment.ocean:
        return 'music/summer.mp3'; // Summer vibes
      case SceneEnvironment.mountain:
        return 'music/winter.mp3'; // Winter vibes
      case SceneEnvironment.garden:
        return 'music/rainny.mp3'; // Rainy/monsoon vibes
      case SceneEnvironment.zenTemple:
        return 'music/morning_meditation.mp3'; // Meditation music
      case SceneEnvironment.desert:
        return 'music/energy_boost.mp3'; // Energetic vibes
      case SceneEnvironment.cosmic:
        return 'music/deep_sleep.mp3'; // Cosmic/space vibes
    }
  }

  /// Get layered nature sounds for environment (birds, wind, ocean, etc.)
  String? _getNatureSoundPath(SceneEnvironment environment) {
    switch (environment) {
      case SceneEnvironment.forest:
        return 'sounds/birds.mp3'; // Forest birds
      case SceneEnvironment.ocean:
        return 'sounds/ocean.mp3'; // Ocean waves
      case SceneEnvironment.mountain:
        return 'sounds/wind.mp3'; // Mountain wind
      case SceneEnvironment.garden:
        return 'sounds/rainforest.mp3'; // Garden rain sounds
      case SceneEnvironment.zenTemple:
        return 'sounds/zen.mp3'; // Zen bowl/chime
      case SceneEnvironment.desert:
        return 'sounds/wind.mp3'; // Desert wind
      case SceneEnvironment.cosmic:
        return null; // Cosmic is silent/mystical
    }
  }

  /// Dispose of resources
  void dispose() {
    _ambientPlayer.dispose();
    _naturePlayer.dispose();
  }
}
