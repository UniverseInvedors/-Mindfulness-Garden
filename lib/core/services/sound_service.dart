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

  // One-shot player for UI sounds (short clips, no overlap needed)
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Dedicated looping player for background ambience
  final AudioPlayer _bgPlayer = AudioPlayer();

  bool _enabled = true;
  bool _bgEnabled = true;
  double _sfxVolume = 0.7;
  double _bgVolume = 0.35;
  String? _currentBg;

  bool get enabled => _enabled;
  bool get bgEnabled => _bgEnabled;

  // ─── Configuration ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _sfxPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _sfxPlayer.setVolume(_sfxVolume);
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(_bgVolume);
    if (kDebugMode) debugPrint('🔊 SoundService initialized');
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!value) _sfxPlayer.stop();
  }

  void setBgEnabled(bool value) {
    _bgEnabled = value;
    if (!value) stopBg();
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  Future<void> setBgVolume(double v) async {
    _bgVolume = v.clamp(0.0, 1.0);
    await _bgPlayer.setVolume(_bgVolume);
  }

  // ─── UI Sound Effects ──────────────────────────────────────────────────────

  /// Play on every button / tile tap.
  Future<void> playButtonClick() => _playSfx('sounds/button_click.mp3');

  /// Play when an action succeeds (e.g. OTP verified, sign-in done).
  Future<void> playSuccess() => _playSfx('sounds/success.mp3');

  /// Play on error / failed validation.
  Future<void> playError() => _playSfx('sounds/error.mp3');

  /// Play when an achievement or reward is unlocked.
  Future<void> playAchievement() => _playSfx('sounds/sparkle.mp3');

  /// Meditation bell — session start / end.
  Future<void> playMeditationBell() => _playSfx('sounds/meditation_bell.mp3');

  /// Play on garden plant action.
  Future<void> playPlant() => _playSfx('sounds/plant.mp3');

  /// Play on garden harvest action.
  Future<void> playHarvest() => _playSfx('sounds/harvest.mp3');

  /// Play for happy / streak milestone.
  Future<void> playHappy() => _playSfx('sounds/happy.mp3');

  /// Play zen tone for teacher selection.
  Future<void> playZen() => _playSfx('sounds/zen.mp3');

  // ─── Background Ambience ───────────────────────────────────────────────────

  /// Start garden day ambience.
  Future<void> playGardenDay() => _startBg('sounds/garden_day.mp3');

  /// Start garden night ambience.
  Future<void> playGardenNight() => _startBg('sounds/garden_night.mp3');

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
    if (!_enabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ SFX error ($assetPath): $e');
    }
  }

  Future<void> _startBg(String assetPath) async {
    if (!_bgEnabled) return;
    if (_currentBg == assetPath) return; // already playing
    try {
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_bgVolume);
      await _bgPlayer.play(AssetSource(assetPath));
      _currentBg = assetPath;
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ BG audio error ($assetPath): $e');
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bgPlayer.dispose();
  }
}
