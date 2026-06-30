// lib/core/services/sound_service.dart
//
// UI + ambient sound service for PranaVerse.
// Provides:
//   • Button click / tap feedback sounds
//   • Success / achievement sounds
//   • Error / notification sounds
//   • Background garden ambient music (day / night)
//   • Simple enable/disable respecting AppSettingsProvider
//
// All assets are already present in assets/sounds/:
//   button_click.mp3, success.mp3, error.mp3, happy.mp3, sparkle.mp3
//   meditation_bell.mp3, harvest.mp3, plant.mp3, zen.mp3
//   garden_day.mp3, garden_night.mp3

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // Dedicated looping player for background ambience/music
  final AudioPlayer _bgPlayer = AudioPlayer();

  // Pool of SFX players for simultaneous sound effects
  final List<AudioPlayer> _sfxPlayers = [];
  int _currentSfxPlayer = 0;
  static const int _maxSfxPlayers = 5; // Allow up to 5 simultaneous SFX

  bool _enabled = true;
  bool _bgEnabled = true;
  bool _initialized = false;
  double _sfxVolume = 0.7;
  double _bgVolume = 0.35;
  String? _currentBg;

  bool get enabled => _enabled;
  bool get bgEnabled => _bgEnabled;

  // ─── Configuration ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _enabled = true;
    _bgEnabled = true;
    _initialized = true;

    // Initialize background music player
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(_bgVolume);

    // Initialize SFX player pool for simultaneous sounds
    for (int i = 0; i < _maxSfxPlayers; i++) {
      final player = AudioPlayer();
      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setVolume(_sfxVolume);
      _sfxPlayers.add(player);
    }

    if (kDebugMode)
      debugPrint(
          '🔊 SoundService initialized (BG: 1 player, SFX: $_maxSfxPlayers players)');
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await initialize();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await ensureInitialized();
    if (!value) {
      // Stop all SFX players
      for (final player in _sfxPlayers) {
        await player.stop();
      }
    }
  }

  Future<void> setBgEnabled(bool value) async {
    _bgEnabled = value;
    await ensureInitialized();
    if (!value) await stopBg();
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v.clamp(0.0, 1.0);
    await ensureInitialized();
    // Update volume for all SFX players
    for (final player in _sfxPlayers) {
      await player.setVolume(_sfxVolume);
    }
  }

  Future<void> setBgVolume(double v) async {
    _bgVolume = v.clamp(0.0, 1.0);
    await ensureInitialized();
    await _bgPlayer.setVolume(_bgVolume);
  }

  // ─── UI Sound Effects ──────────────────────────────────────────────────────

  /// Play on every button / tile tap.
  Future<void> playButtonClick() => _playSfx('sounds/UI.mp3');

  /// Play when an action succeeds (e.g. OTP verified, sign-in done).
  Future<void> playSuccess() => _playSfx('sounds/UI.mp3');

  /// Play on error / failed validation.
  Future<void> playError() => _playSfx('sounds/UI.mp3');

  /// Play when an achievement or reward is unlocked.
  Future<void> playAchievement() => _playSfx('sounds/Select.mp3');

  /// Meditation bell — session start / end.
  Future<void> playMeditationBell() => _playSfx('sounds/bowl.mp3');

  /// Play on garden plant action.
  Future<void> playPlant() => _playSfx('sounds/UI.mp3');

  /// Play the garden selection click sound.
  Future<void> playSelection() => _playSfx('sounds/Select.mp3');

  /// Play the garden placement sound.
  Future<void> playPlacement() => _playSfx('sounds/Select.mp3');

  /// Play on garden harvest action.
  Future<void> playHarvest() => _playSfx('sounds/Select.mp3');

  /// Play for happy / streak milestone.
  Future<void> playHappy() => _playSfx('sounds/UI.mp3');

  /// Play zen tone for teacher selection.
  Future<void> playZen() => _playSfx('sounds/zen.mp3');

  // ─── Background Ambience ───────────────────────────────────────────────────

  /// Start garden day ambience.
  Future<void> playGardenDay() => _startBg('sounds/birds.mp3');

  /// Start garden night ambience.
  Future<void> playGardenNight() => _startBg('sounds/crickets.mp3');

  /// Play a custom ambient track from the app assets.
  Future<void> playAmbientTrack(String assetPath) => _startBg(assetPath);

  /// Stop background music.
  Future<void> stopBg() async {
    try {
      await _bgPlayer.stop();
      _currentBg = null;
    } catch (_) {}
  }

  /// Pause background music.
  Future<void> pauseBg() async {
    try {
      await _bgPlayer.pause();
    } catch (_) {}
  }

  /// Resume background music.
  Future<void> resumeBg() async {
    try {
      if (_currentBg != null && _bgEnabled) await _bgPlayer.resume();
    } catch (_) {}
  }

  // ─── Internals ─────────────────────────────────────────────────────────────

  Future<void> _playSfx(String assetPath) async {
    await ensureInitialized();
    if (!_enabled) return;
    try {
      // CRITICAL FIX: Remove 'assets/' prefix if present before playing
      // AssetSource expects paths WITHOUT 'assets/' prefix
      final cleanPath = assetPath.replaceFirst('assets/', '');

      // Use round-robin to pick next available player
      // This allows multiple SFX to play simultaneously
      _currentSfxPlayer = (_currentSfxPlayer + 1) % _maxSfxPlayers;
      final player = _sfxPlayers[_currentSfxPlayer];

      // Don't stop - let it overlap if needed
      // Fire and forget for immediate feedback
      player.play(AssetSource(cleanPath));

      if (kDebugMode)
        debugPrint('🔊 Playing SFX[$_currentSfxPlayer]: $cleanPath');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ SFX error ($assetPath): $e');
    }
  }

  Future<void> _startBg(String assetPath) async {
    await ensureInitialized();
    if (!_bgEnabled) return;
    if (_currentBg == assetPath) return; // already playing
    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_bgVolume);

      // CRITICAL FIX: Remove 'assets/' prefix if present before playing
      // AssetSource expects paths WITHOUT 'assets/' prefix
      final cleanPath = assetPath.replaceFirst('assets/', '');

      if (kDebugMode) debugPrint('🎵 Playing BG: $cleanPath');
      await _bgPlayer.play(AssetSource(cleanPath));
      _currentBg = assetPath;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ BG audio error ($assetPath): $e');
    }
  }

  void dispose() {
    _bgPlayer.dispose();
    for (final player in _sfxPlayers) {
      player.dispose();
    }
    _sfxPlayers.clear();
  }
}
