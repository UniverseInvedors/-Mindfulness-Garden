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
      'icon': 'waves',
    },
    {
      'id': 'rain',
      'name': 'Gentle Rain',
      'asset': 'sounds/rain.mp3',
      'icon': 'rain',
    },
    {
      'id': 'forest',
      'name': 'Forest Birds',
      'asset': 'sounds/forest.mp3',
      'icon': 'forest',
    },
    {
      'id': 'bowl',
      'name': 'Singing Bowl',
      'asset': 'sounds/bowl.mp3',
      'icon': 'bowl',
    },
    {
      'id': 'white',
      'name': 'White Noise',
      'asset': 'sounds/rainforest.mp3',
      'icon': 'noise',
    },
    {
      'id': 'piano',
      'name': 'Calm Piano',
      'asset': 'sounds/piano.mp3',
      'icon': 'piano',
    },
    {
      'id': 'waterfall',
      'name': 'Waterfall',
      'asset': 'sounds/waterfall.mp3',
      'icon': 'waterfall',
    },
    {
      'id': 'birds',
      'name': 'Forest Birds',
      'asset': 'sounds/birds.mp3',
      'icon': 'birds',
    },
    {
      'id': 'wind',
      'name': 'Wind Sounds',
      'asset': 'sounds/wind.mp3',
      'icon': 'wind',
    },
    {
      'id': 'crickets',
      'name': 'Night Crickets',
      'asset': 'sounds/crickets.mp3',
      'icon': 'crickets',
    },
    {
      'id': 'river',
      'name': 'River Stream',
      'asset': 'sounds/river.wav',
      'icon': 'river',
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

  Future<void> playLoopingSound(String soundId) {
    return playSound(soundId, loop: true);
  }

  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentSoundId = null;
      _isLooping = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping all sounds: $e');
      }
    }
  }

  Future<void> playSound(String soundId, {bool loop = false}) async {
    try {
      final sound = _sounds.firstWhere(
        (s) => s['id'] == soundId,
        orElse: () => {
          'id': soundId,
          'asset': 'sounds/$soundId.mp3',
          'name': soundId,
        },
      );

      await playSoundFile(sound['asset'] as String, loop: loop);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  Future<void> playSoundFile(String path, {bool loop = false}) async {
    try {
      final assetPath = path.replaceFirst('assets/', '');
      if (_isPlaying && _currentSoundId == assetPath) {
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.stop();
      }

      await _audioPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await _audioPlayer.play(AssetSource(assetPath));
      _currentSoundId = assetPath;
      _isPlaying = true;
      _isLooping = loop;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error playing sound file $path: $e');
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
        debugPrint('Error stopping sound: $e');
      }
    }
  }

  Future<void> stop() => stopSound();

  Future<void> pauseAll() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error pausing sound: $e');
      }
    }
  }

  Future<void> pauseSound() => pauseAll();

  Future<void> pause() => pauseAll();

  Future<void> resumeSound() async {
    try {
      if (_currentSoundId != null) {
        await _audioPlayer.resume();
        _isPlaying = true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resuming sound: $e');
      }
    }
  }

  Future<void> resume() => resumeSound();

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting volume: $e');
      }
    }
  }

  Future<void> toggleLoop() async {
    await setLoop(!_isLooping);
  }

  Future<void> toggleSound(String soundId) async {
    final sound = getSound(soundId);
    final asset = sound?['asset'] as String?;
    if (_isPlaying &&
        (_currentSoundId == soundId || _currentSoundId == asset)) {
      await stopSound();
    } else {
      await playSound(soundId);
    }
  }

  Map<String, dynamic>? getSound(String soundId) {
    try {
      return _sounds.firstWhere((s) => s['id'] == soundId);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getSoundsByCategory(String category) {
    return _sounds.where((sound) => sound['category'] == category).toList();
  }

  bool isSoundPlaying(String soundId) {
    final sound = getSound(soundId);
    return _isPlaying &&
        (_currentSoundId == soundId || _currentSoundId == sound?['asset']);
  }

  Future<void> setLoop(bool loop) async {
    try {
      _isLooping = loop;
      await _audioPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error setting loop mode: $e');
      }
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error seeking: $e');
      }
    }
  }

  Future<Duration> getPosition() async {
    try {
      return await _audioPlayer.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting position: $e');
      }
      return Duration.zero;
    }
  }

  Future<Duration> getDuration() async {
    try {
      return await _audioPlayer.getDuration() ?? Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting duration: $e');
      }
      return Duration.zero;
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
