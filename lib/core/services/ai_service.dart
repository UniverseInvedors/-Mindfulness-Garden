import 'package:flutter_tts/flutter_tts.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Builds a real UserProfile from actual stored data
  Future<UserProfile> getUserProfile() async {
    final sessions = LocalStorageService.getSessions();
    final moods = LocalStorageService.getAllMoods();
    final user = LocalStorageService.getUser();

    // Real streak from storage
    final streak = user?.currentStreak ?? LocalStorageService.getCurrentStreak();

    // Real average session duration
    final totalMinutes = sessions.isEmpty
        ? 0
        : sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final avgMinutes = sessions.isEmpty ? 0 : totalMinutes ~/ sessions.length;

    // Real preferred types from session history
    final typeCounts = <String, int>{};
    for (final s in sessions) {
      typeCounts[s.meditationType] = (typeCounts[s.meditationType] ?? 0) + 1;
    }
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTypes = sortedTypes.take(2).map((e) {
      switch (e.key.toLowerCase()) {
        case 'box breathing':
        case 'box':
          return MeditationType.breathAwareness;
        case 'sleep':
          return MeditationType.sleep;
        case 'stress':
        case 'stress relief':
          return MeditationType.stressRelief;
        case 'loving kindness':
        case 'loving-kindness':
          return MeditationType.lovingKindness;
        case 'gratitude':
          return MeditationType.gratitude;
        case 'energy':
        case 'energy boost':
          return MeditationType.energyBoost;
        default:
          return MeditationType.breathAwareness;
      }
    }).toSet();

    // Real stress level from recent mood ratings (inverted: low mood = high stress)
    double stressLevel = 50.0;
    if (moods.isNotEmpty) {
      final recent = moods.take(7).toList();
      final avgRating =
          recent.fold(0.0, (sum, m) => sum + m.rating) / recent.length;
      // rating 1-5 → stress 90-10
      stressLevel = ((5 - avgRating) / 4 * 80 + 10).clamp(10.0, 90.0);
    }

    // Real last session time
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    final lastSession = sessions.isEmpty ? null : sessions.first.startTime;

    // Today's mood
    final todayMood = LocalStorageService.getMoodForDate(DateTime.now());

    // Sessions today
    final todaySessions = LocalStorageService.getSessionsByDate(DateTime.now());

    return UserProfile(
      meditationStreak: streak,
      averageDuration: Duration(minutes: avgMinutes),
      preferredTypes: topTypes.isEmpty
          ? {MeditationType.breathAwareness}
          : topTypes,
      stressLevel: stressLevel,
      lastMeditationTime: lastSession,
      totalSessions: sessions.length,
      totalMinutes: totalMinutes,
      todayMood: todayMood?.mood,
      todayMoodRating: todayMood?.rating,
      sessionsToday: todaySessions.length,
      healthConditions: _loadHealthConditions(),
    );
  }

  List<String> _loadHealthConditions() {
    final raw = LocalStorageService.getSetting('health_conditions');
    if (raw == null) return [];
    if (raw is List) return List<String>.from(raw);
    return [];
  }

  Future<void> saveHealthConditions(List<String> conditions) async {
    await LocalStorageService.saveSetting('health_conditions', conditions);
  }

  Future<void> saveHealthProfile({
    required String age,
    required String goal,
    required List<String> conditions,
  }) async {
    await LocalStorageService.saveSetting('health_age', age);
    await LocalStorageService.saveSetting('health_goal', goal);
    await LocalStorageService.saveSetting('health_conditions', conditions);
    await LocalStorageService.saveSetting('health_profile_set', true);
  }

  bool get isHealthProfileSet {
    return LocalStorageService.getSetting('health_profile_set') == true;
  }

  Map<String, dynamic> getHealthProfile() {
    return {
      'age': LocalStorageService.getSetting('health_age') ?? '',
      'goal': LocalStorageService.getSetting('health_goal') ?? '',
      'conditions': () {
        final raw = LocalStorageService.getSetting('health_conditions');
        if (raw == null) return <String>[];
        if (raw is List) return List<String>.from(raw);
        return <String>[];
      }(),
    };
  }

  Future<void> speakResponse(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class UserProfile {
  final int meditationStreak;
  final Duration averageDuration;
  final Set<MeditationType> preferredTypes;
  final double stressLevel;
  final DateTime? lastMeditationTime;
  final int totalSessions;
  final int totalMinutes;
  final String? todayMood;
  final double? todayMoodRating;
  final int sessionsToday;
  final List<String> healthConditions;

  UserProfile({
    required this.meditationStreak,
    required this.averageDuration,
    required this.preferredTypes,
    required this.stressLevel,
    this.lastMeditationTime,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.todayMood,
    this.todayMoodRating,
    this.sessionsToday = 0,
    this.healthConditions = const [],
  });
}

enum MeditationType {
  breathAwareness,
  bodyScan,
  lovingKindness,
  gratitude,
  stressRelief,
  sleep,
  energyBoost,
}

class MeditationRecommendation {
  final MeditationType type;
  final Duration duration;
  final String reason;
  final double confidence;
  final String route;

  MeditationRecommendation({
    required this.type,
    required this.duration,
    required this.reason,
    required this.confidence,
    required this.route,
  });
}

// Legacy models kept for compatibility
class Emotion {
  final EmotionType type;
  final double confidence;
  Emotion({required this.type, required this.confidence});
}

enum EmotionType { happy, sad, angry, stressed, tired, neutral }

class EmotionData {
  final Emotion emotion;
  final DateTime timestamp;
  final double confidence;
  EmotionData({
    required this.emotion,
    required this.timestamp,
    required this.confidence,
  });
}

class SpeechAnalysis {
  final Sentiment sentiment;
  final double stressLevel;
  final List<String> keywords;
  SpeechAnalysis({
    required this.sentiment,
    required this.stressLevel,
    required this.keywords,
  });
}

enum Sentiment { positive, negative, neutral }
