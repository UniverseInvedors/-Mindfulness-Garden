// lib/core/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 'ocean',
      'name': 'Ocean Waves',
      'asset': 'sounds/ocean.mp3',
      'icon': '🌊',
    },
    {
      'id': 'rain',
      'name': 'Gentle Rain',
      'asset': 'sounds/rain.mp3',
      'icon': '🌧️',
    },
    {
      'id': 'forest',
      'name': 'Forest Birds',
      'asset': 'sounds/forest.mp3',
      'icon': '🌲',
    },
    {
      'id': 'bowl',
      'name': 'Singing Bowl',
      'asset': 'sounds/bowl.mp3',
      'icon': '🛎️',
    },
    {
      'id': 'white',
      'name': 'White Noise',
      'asset': 'sounds/white.mp3',
      'icon': '📻',
    },
    {
      'id': 'piano',
      'name': 'Calm Piano',
      'asset': 'sounds/piano.mp3',
      'icon': '🎹',
    },
    // Add more sounds for scenes
    {
      'id': 'waterfall',
      'name': 'Waterfall',
      'asset': 'sounds/waterfall.mp3',
      'icon': '💧',
    },
    {
      'id': 'birds',
      'name': 'Forest Birds',
      'asset': 'sounds/birds.mp3',
      'icon': '🐦',
    },
    {
      'id': 'wind',
      'name': 'Wind Sounds',
      'asset': 'sounds/wind.mp3',
      'icon': '💨',
    },
    {
      'id': 'crickets',
      'name': 'Night Crickets',
      'asset': 'sounds/crickets.mp3',
      'icon': '🦗',
    },
    {
      'id': 'river',
      'name': 'River Stream',
      'asset': 'sounds/river.mp3',
      'icon': '🌊',
    },
  ];

  String? _currentSoundId;
  bool _isPlaying = false;
  double _volume = 0.7;
  bool _isLooping = false;

  List<Map<String, dynamic>> get sounds => _sounds;
  String? get currentSoundId => _currentSoundId;
  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  bool get isLooping => _isLooping;

  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(_volume);
  }
  // In AudioService class, replace the existing playLoopingSound method:
  Future<void> playLoopingSound(String soundId) async {
    return playSound(soundId, loop: true);
  }
  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping all sounds: $e');
    }
  }
  // Play predefined sound by ID
  Future<void> playSound(String soundId, {bool loop = false}) async {
    try {
      final sound = _sounds.firstWhere((s) => s['id'] == soundId,
          orElse: () => {'id': soundId, 'asset': soundId, 'name': soundId});

      if (_currentSoundId == sound['asset'] && _isPlaying) {
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(AssetSource(sound['asset']));
      _currentSoundId = sound['asset'];
      _isPlaying = true;
      _isLooping = loop;

      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
      // Fallback: try to play as direct path
      await playSoundFile(soundId, loop: loop);
    }
  }

  // Play any sound file by path - for backward compatibility
  Future<void> playSoundFile(String path, {bool loop = false}) async {
    try {
      if (_isPlaying && _currentSoundId == path) {
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.play(AssetSource(path));
      _currentSoundId = path;
      _isPlaying = true;
      _isLooping = loop;

      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound file $path: $e');
      }
      // Try alternative path format
      try {
        final fixedPath = path.replaceFirst('assets/', '');
        await _audioPlayer.play(AssetSource(fixedPath));
        _currentSoundId = fixedPath;
        _isPlaying = true;
        _isLooping = loop;
      } catch (e2) {
        if (kDebugMode) {
          print('Error with alternative path: $e2');
        }
      }
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSoundId = null;
      _isLooping = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping sound: $e');
      }
    }
  }

  Future<void> stop() async {
    await stopSound();
  }

  Future<void> pauseAll() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error pausing sound: $e');
      }
    }
  }

  Future<void> pauseSound() async {
    await pauseAll();
  }

  Future<void> pause() async {
    await pauseAll();
  }

  Future<void> resumeSound() async {
    try {
      if (_currentSoundId != null) {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resuming sound: $e');
      }
    }
  }

  Future<void> resume() async {
    await resumeSound();
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting volume: $e');
      }
    }
  }

  Future<void> toggleLoop() async {
    try {
      if (_currentSoundId != null) {
        _isLooping = !_isLooping;
        if (_isLooping) {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        } else {
          await _audioPlayer.setReleaseMode(ReleaseMode.release);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling loop: $e');
      }
    }
  }

  Future<void> toggleSound(String soundId) async {
    if (_currentSoundId == soundId && _isPlaying) {
      await stopSound();
    } else {
      await playSound(soundId);
    }
  }

  // Get sound by ID
  Map<String, dynamic>? getSound(String soundId) {
    try {
      return _sounds.firstWhere((s) => s['id'] == soundId);
    } catch (e) {
      return null;
    }
  }

  // Get all sounds for a category
  List<Map<String, dynamic>> getSoundsByCategory(String category) {
    return _sounds.where((sound) => sound['category'] == category).toList();
  }

  // Check if sound is playing
  bool isSoundPlaying(String soundId) {
    return _isPlaying && _currentSoundId == soundId;
  }

  // Set loop mode
  Future<void> setLoop(bool loop) async {
    try {
      _isLooping = loop;
      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      } else {
        await _audioPlayer.setReleaseMode(ReleaseMode.release);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting loop mode: $e');
      }
    }
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      if (kDebugMode) {
        print('Error seeking: $e');
      }
    }
  }

  // Get current position
  Future<Duration> getPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting position: $e');
      }
      return Duration.zero;
    }
  }

  // Get duration
  Future<Duration> getDuration() async {
    try {
      return await _audioPlayer.getDuration() ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting duration: $e');
      }
      return Duration.zero;
    }
  }

  // Cleanup
  void dispose() {
    _audioPlayer.dispose();
  }
}
