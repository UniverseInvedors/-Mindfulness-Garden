import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:flutter/foundation.dart';
import 'audio_constants.dart';

/// Comprehensive audio management service for the Mindfulness Garden app
/// Handles background music, ambient sounds, UI effects, and theme-based audio
class AudioManagerService {
  // Singleton pattern
  static final AudioManagerService _instance = AudioManagerService._internal();
  factory AudioManagerService() => _instance;
  AudioManagerService._internal();

  // Audio players for different categories
  final just_audio.AudioPlayer _backgroundMusicPlayer =
      just_audio.AudioPlayer();
  final just_audio.AudioPlayer _ambiencePlayer = just_audio.AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer(); // For short sound effects
  final AudioPlayer _uiPlayer = AudioPlayer(); // For UI interactions

  // Audio state management
  bool _isMusicEnabled = true;
  bool _areSfxEnabled = true;
  bool _isAmbienceEnabled = true;

  double _musicVolume = 0.8;
  double _sfxVolume = 1.0;
  double _ambienceVolume = 0.6;

  String? _currentTheme;
  String? _currentBackgroundMusic;
  String? _currentAmbience;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get areSfxEnabled => _areSfxEnabled;
  bool get isAmbienceEnabled => _isAmbienceEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get ambienceVolume => _ambienceVolume;
  String? get currentTheme => _currentTheme;

  // ==================== INITIALIZATION ====================

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      // Set audio mode for mobile - BOTH players need configuration
      final androidConfig = const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      );

      final iosConfig = AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {},
      );

      final audioContext = AudioContext(
        android: androidConfig,
        iOS: iosConfig,
      );

      // Configure SFX player
      await _sfxPlayer.setAudioContext(audioContext);
      await _sfxPlayer.setVolume(_sfxVolume);

      // Configure UI player
      await _uiPlayer.setAudioContext(audioContext);
      await _uiPlayer.setVolume(_sfxVolume);

      // Configure background music player for looping
      await _backgroundMusicPlayer.setLoopMode(just_audio.LoopMode.one);
      await _backgroundMusicPlayer.setVolume(_musicVolume);

      // Configure ambience player for looping
      await _ambiencePlayer.setLoopMode(just_audio.LoopMode.one);
      await _ambiencePlayer.setVolume(_ambienceVolume);

      debugPrint('✅ AudioManagerService initialized successfully');
      debugPrint('   Music Enabled: $_isMusicEnabled');
      debugPrint('   SFX Enabled: $_areSfxEnabled');
      debugPrint('   Ambience Enabled: $_isAmbienceEnabled');
      debugPrint('   Music Volume: $_musicVolume');
      debugPrint('   SFX Volume: $_sfxVolume');
      debugPrint('   Ambience Volume: $_ambienceVolume');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing AudioManagerService: $e');
      debugPrint('   Stack trace: $stackTrace');
    }
  }

  // ==================== BACKGROUND MUSIC ====================

  /// Change theme and update background music accordingly
  Future<void> changeTheme(String theme) async {
    if (!_isMusicEnabled) return;

    _currentTheme = theme;
    final themeMusic = AudioConstants.getThemeMusic(theme);

    if (themeMusic.isNotEmpty) {
      await playBackgroundMusic(themeMusic.first);
    }

    // Optionally add ambient sounds for the theme
    if (themeMusic.length > 1 && _isAmbienceEnabled) {
      await playAmbience(themeMusic[1]);
    }
  }

  /// Play background music
  Future<void> playBackgroundMusic(String audioPath) async {
    if (!_isMusicEnabled) return;

    try {
      _currentBackgroundMusic = audioPath;

      // Remove 'assets/' prefix for just_audio
      final path = audioPath.replaceFirst('assets/', '');

      debugPrint('🎵 Attempting to play background music: $path');

      await _backgroundMusicPlayer.stop();

      // Try to set the audio source with better error handling
      try {
        await _backgroundMusicPlayer.setAsset(path);
        await _backgroundMusicPlayer.play();
        debugPrint('✅ Background music playing: $path');
      } catch (assetError) {
        debugPrint('❌ Asset load failed: $assetError');
        debugPrint('   Will retry with simpler initialization');
        // Don't rethrow - just log and continue
        _currentBackgroundMusic = null;
      }
    } catch (e) {
      debugPrint('❌ Error playing background music: $e');
      debugPrint('   Full path was: $audioPath');
      _currentBackgroundMusic = null;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
    _currentBackgroundMusic = null;
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isMusicEnabled && _currentBackgroundMusic != null) {
      await _backgroundMusicPlayer.play();
    }
  }

  // ==================== AMBIENT SOUNDS ====================

  /// Play ambient nature sounds
  Future<void> playAmbience(String audioPath) async {
    if (!_isAmbienceEnabled) return;

    try {
      _currentAmbience = audioPath;

      // Remove 'assets/' prefix for just_audio
      final path = audioPath.replaceFirst('assets/', '');

      debugPrint('🌿 Attempting to play ambience: $path');

      await _ambiencePlayer.stop();

      // Try to set the audio source with better error handling
      try {
        await _ambiencePlayer.setAsset(path);
        await _ambiencePlayer.play();
        debugPrint('✅ Ambience playing: $path');
      } catch (assetError) {
        debugPrint('❌ Asset load failed: $assetError');
        debugPrint('   Will skip ambience for now');
        // Don't rethrow - just log and continue
        _currentAmbience = null;
      }
    } catch (e) {
      debugPrint('❌ Error playing ambience: $e');
      debugPrint('   Full path was: $audioPath');
      _currentAmbience = null;
    }
  }

  /// Set day/night ambience for the garden
  Future<void> setGardenAmbience(bool isDay) async {
    if (!_isAmbienceEnabled) return;

    final ambience = AudioConstants.getGardenAmbience(isDay);
    if (ambience.isNotEmpty) {
      await playAmbience(ambience.first);
    }
  }

  /// Stop ambient sounds
  Future<void> stopAmbience() async {
    await _ambiencePlayer.stop();
    _currentAmbience = null;
  }

  // ==================== SOUND EFFECTS ====================

  /// Play a sound effect (general purpose)
  Future<void> playSfx(String audioPath) async {
    if (!_areSfxEnabled) {
      debugPrint('⚠️ SFX disabled, skipping: $audioPath');
      return;
    }

    try {
      final path = audioPath.replaceFirst('assets/', '');
      debugPrint('🔊 Playing SFX: $path');

      // Create new player instance for each sound to allow overlapping
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.play(AssetSource(path));

      debugPrint('✅ SFX played: $path');

      // Dispose after playing
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('❌ Error playing SFX: $e');
      debugPrint('   Path: $audioPath');
    }
  }

  /// Play UI interaction sound
  Future<void> playUISound(String audioPath) async {
    if (!_areSfxEnabled) {
      debugPrint('⚠️ UI Sound disabled, skipping: $audioPath');
      return;
    }

    try {
      final path = audioPath.replaceFirst('assets/', '');
      debugPrint('🔊 Playing UI Sound: $path');

      // Create new player for each UI sound for instant feedback
      final player = AudioPlayer();
      await player.setVolume(_sfxVolume);
      await player.play(AssetSource(path));

      debugPrint('✅ UI Sound played: $path');

      // Dispose after playing
      player.onPlayerComplete.listen((event) {
        player.dispose();
      });
    } catch (e) {
      debugPrint('❌ Error playing UI sound: $e');
      debugPrint('   Path: $audioPath');
    }
  }

  // ==================== SPECIFIC INTERACTIONS ====================

  /// Play button click sound
  Future<void> playButtonClick() async {
    await playUISound(AudioConstants.uiButtonClick);
  }

  /// Play success sound
  Future<void> playSuccess() async {
    await playSfx(AudioConstants.uiSuccess);
  }

  /// Play error sound
  Future<void> playError() async {
    await playSfx(AudioConstants.uiError);
  }

  /// Play select sound
  Future<void> playSelectSound() async {
    await playUISound(AudioConstants.uiSelect);
  }

  /// Play meditation bell
  Future<void> playMeditationBell() async {
    await playSfx(AudioConstants.meditationBowl);
  }

  /// Play singing bowl
  Future<void> playSingingBowl() async {
    await playSfx(AudioConstants.meditationBowl);
  }

  // ==================== MEDITATION & BINAURAL ====================

  /// Start meditation session with specific type
  Future<void> startMeditationSession(String meditationType) async {
    switch (meditationType.toLowerCase()) {
      case 'focus':
        await playBackgroundMusic(AudioConstants.binauralFocus);
        break;
      case 'sleep':
        await playBackgroundMusic(AudioConstants.binauralDeepSleep);
        await playAmbience(AudioConstants.natureOcean);
        break;
      case 'stress':
        await playBackgroundMusic(AudioConstants.musicStressRelief);
        await playAmbience(AudioConstants.meditationZen);
        break;
      case 'energy':
        await playBackgroundMusic(AudioConstants.binauralEnergy);
        break;
      case 'creativity':
        await playBackgroundMusic(AudioConstants.binauralCreativity);
        break;
      default:
        await playBackgroundMusic(AudioConstants.binauralMeditation);
        await playAmbience(AudioConstants.meditationBowl);
    }
  }

  /// Play breathing guide audio
  Future<void> playBreathingGuide() async {
    await playSfx(AudioConstants.meditationBowl);
  }

  // ==================== VOLUME CONTROL ====================

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _backgroundMusicPlayer.setVolume(_musicVolume);
  }

  /// Set SFX volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _uiPlayer.setVolume(_sfxVolume);
  }

  /// Set ambience volume (0.0 to 1.0)
  Future<void> setAmbienceVolume(double volume) async {
    _ambienceVolume = volume.clamp(0.0, 1.0);
    await _ambiencePlayer.setVolume(_ambienceVolume);
  }

  // ==================== ENABLE/DISABLE ====================

  /// Toggle music on/off
  Future<void> toggleMusic(bool enabled) async {
    _isMusicEnabled = enabled;
    if (!enabled) {
      await pauseBackgroundMusic();
    } else if (_currentBackgroundMusic != null) {
      await resumeBackgroundMusic();
    }
  }

  /// Toggle sound effects on/off
  void toggleSfx(bool enabled) {
    _areSfxEnabled = enabled;
  }

  /// Toggle ambience on/off
  Future<void> toggleAmbience(bool enabled) async {
    _isAmbienceEnabled = enabled;
    if (!enabled) {
      await stopAmbience();
    } else if (_currentAmbience != null) {
      await playAmbience(_currentAmbience!);
    }
  }

  // ==================== FADE EFFECTS ====================

  /// Fade out background music
  Future<void> fadeOutMusic(
      {Duration duration = const Duration(seconds: 2)}) async {
    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final volumeStep = _musicVolume / steps;

    for (int i = 0; i < steps; i++) {
      await _backgroundMusicPlayer.setVolume(_musicVolume - (volumeStep * i));
      await Future.delayed(Duration(milliseconds: stepDuration));
    }

    await stopBackgroundMusic();
    await _backgroundMusicPlayer.setVolume(_musicVolume);
  }

  /// Fade in background music
  Future<void> fadeInMusic(
      {Duration duration = const Duration(seconds: 2)}) async {
    final steps = 20;
    final stepDuration = duration.inMilliseconds ~/ steps;
    final volumeStep = _musicVolume / steps;

    await _backgroundMusicPlayer.setVolume(0);
    await _backgroundMusicPlayer.play();

    for (int i = 0; i < steps; i++) {
      await _backgroundMusicPlayer.setVolume(volumeStep * i);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }

    await _backgroundMusicPlayer.setVolume(_musicVolume);
  }

  // ==================== CLEANUP ====================

  /// Dispose all audio resources
  Future<void> dispose() async {
    await _backgroundMusicPlayer.dispose();
    await _ambiencePlayer.dispose();
    await _sfxPlayer.dispose();
    await _uiPlayer.dispose();
  }
}
