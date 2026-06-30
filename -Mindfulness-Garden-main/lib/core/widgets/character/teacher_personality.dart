import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/widgets/meditation_scene_widget.dart';
import 'package:pranaverse/core/services/voice_service.dart';

// Teacher personality types for the yoga instructor
enum TeacherPersonality {
  buddha,
  zeno,
  monk,
  shiva, // Destroyer & transformer — cosmic dancer
  tiger, // Tiger-cloth warrior — power & courage
}

// Teacher preference provider for single source of truth
class TeacherPreference extends StateNotifier<TeacherPersonality> {
  static const String _key = 'teacher_personality';

  TeacherPreference() : super(TeacherPersonality.buddha) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_key);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < TeacherPersonality.values.length) {
      state = TeacherPersonality.values[savedIndex];
    }
  }

  Future<void> setTeacher(TeacherPersonality personality) async {
    state = personality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, personality.index);
    await VoiceService().setPersonality(personality.voicePersonality);
  }
}

extension TeacherPersonalityX on TeacherPersonality {
  VoicePersonality get voicePersonality {
    switch (this) {
      case TeacherPersonality.buddha:
        return VoicePersonality.buddha;
      case TeacherPersonality.zeno:
        return VoicePersonality.zeno;
      case TeacherPersonality.monk:
      case TeacherPersonality.shiva:
      case TeacherPersonality.tiger:
        return VoicePersonality.monk;
    }
  }

  String get role {
    switch (this) {
      case TeacherPersonality.buddha:
        return 'Meditation and emotional calm';
      case TeacherPersonality.zeno:
        return 'Yoga, energy and daily coaching';
      case TeacherPersonality.monk:
        return 'Breathwork, focus and discipline';
      case TeacherPersonality.shiva:
        return 'Cosmic transformation & inner fire';
      case TeacherPersonality.tiger:
        return 'Power, courage & warrior spirit';
    }
  }
}

// Provider instance
final teacherPreferenceProvider =
    StateNotifierProvider<TeacherPreference, TeacherPersonality>(
  (ref) => TeacherPreference(),
);

// Theme preference provider for environment and time of day
class ThemePreference extends StateNotifier<ThemeSettings> {
  static const String _envKey = 'theme_environment';
  static const String _timeKey = 'theme_time_of_day';

  ThemePreference() : super(const ThemeSettings()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEnvIndex = prefs.getInt(_envKey);
    final savedTimeIndex = prefs.getInt(_timeKey);

    SceneEnvironment env = SceneEnvironment.forest;
    SceneTimeOfDay time = SceneTimeOfDay.morning;

    if (savedEnvIndex != null &&
        savedEnvIndex >= 0 &&
        savedEnvIndex < SceneEnvironment.values.length) {
      env = SceneEnvironment.values[savedEnvIndex];
    }
    if (savedTimeIndex != null &&
        savedTimeIndex >= 0 &&
        savedTimeIndex < SceneTimeOfDay.values.length) {
      time = SceneTimeOfDay.values[savedTimeIndex];
    }

    state = ThemeSettings(environment: env, timeOfDay: time);
  }

  Future<void> setEnvironment(SceneEnvironment environment) async {
    state = ThemeSettings(environment: environment, timeOfDay: state.timeOfDay);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_envKey, environment.index);
  }

  Future<void> setTimeOfDay(SceneTimeOfDay timeOfDay) async {
    state = ThemeSettings(environment: state.environment, timeOfDay: timeOfDay);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeKey, timeOfDay.index);
  }

  Future<void> setTheme(
      SceneEnvironment environment, SceneTimeOfDay timeOfDay) async {
    state = ThemeSettings(environment: environment, timeOfDay: timeOfDay);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_envKey, environment.index);
    await prefs.setInt(_timeKey, timeOfDay.index);
  }
}

// Theme settings data class
class ThemeSettings {
  final SceneEnvironment environment;
  final SceneTimeOfDay timeOfDay;

  const ThemeSettings({
    this.environment = SceneEnvironment.forest,
    this.timeOfDay = SceneTimeOfDay.morning,
  });

  ThemeSettings copyWith({
    SceneEnvironment? environment,
    SceneTimeOfDay? timeOfDay,
  }) {
    return ThemeSettings(
      environment: environment ?? this.environment,
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }
}

// Provider instance
final themePreferenceProvider =
    StateNotifierProvider<ThemePreference, ThemeSettings>(
  (ref) => ThemePreference(),
);

// Character appearance configuration for each personality
class TeacherAppearance {
  final TeacherPersonality personality;
  final String name;

  // Skin tones
  final Color skinPrimary;
  final Color skinSecondary;
  final Color skinShadow;

  // Hair colors
  final Color hairPrimary;
  final Color hairSecondary;

  // Clothing colors
  final Color clothPrimary;
  final Color clothSecondary;
  final Color clothAccent;

  // Aura colors
  final Color auraPrimary;
  final Color auraSecondary;

  // Body proportions (multipliers)
  final double headScale;
  final double torsoScale;
  final double limbScale;
  final double overallScale;

  // Feature adjustments
  final double eyeSize;
  final double mouthWidth;
  final double noseSize;

  const TeacherAppearance({
    required this.personality,
    required this.name,
    required this.skinPrimary,
    required this.skinSecondary,
    required this.skinShadow,
    required this.hairPrimary,
    required this.hairSecondary,
    required this.clothPrimary,
    required this.clothSecondary,
    required this.clothAccent,
    required this.auraPrimary,
    required this.auraSecondary,
    required this.headScale,
    required this.torsoScale,
    required this.limbScale,
    required this.overallScale,
    required this.eyeSize,
    required this.mouthWidth,
    required this.noseSize,
  });

  static const Map<TeacherPersonality, TeacherAppearance> personalities = {
    TeacherPersonality.buddha: TeacherAppearance(
      personality: TeacherPersonality.buddha,
      name: 'Buddha',
      skinPrimary: Color(0xFFf2bd8f),
      skinSecondary: Color(0xFFd99563),
      skinShadow: Color(0xFFb87548),
      hairPrimary: Color(0xFF1a120b),
      hairSecondary: Color(0xFF2a1a10),
      clothPrimary: Color(0xFFff8c00), // Saffron orange
      clothSecondary: Color(0xFF8b4513),
      clothAccent: Color(0xFFffd700),
      auraPrimary: Color(0xFFffd700),
      auraSecondary: Color(0xFFff8c00),
      headScale: 1.15,
      torsoScale: 1.1,
      limbScale: 1.0,
      overallScale: 1.05,
      eyeSize: 1.1,
      mouthWidth: 1.0,
      noseSize: 1.0,
    ),
    TeacherPersonality.zeno: TeacherAppearance(
      personality: TeacherPersonality.zeno,
      name: 'Zeno',
      skinPrimary: Color(0xFFffe4c8),
      skinSecondary: Color(0xFFf2bd8f),
      skinShadow: Color(0xFFb87548),
      hairPrimary: Color(0xFF2c3e50),
      hairSecondary: Color(0xFF34495e),
      clothPrimary: Color(0xFF9d4edd), // Purple
      clothSecondary: Color(0xFF6c5ce7),
      clothAccent: Color(0xFF00b4d8),
      auraPrimary: Color(0xFF9d4edd),
      auraSecondary: Color(0xFF00b4d8),
      headScale: 1.0,
      torsoScale: 1.0,
      limbScale: 1.0,
      overallScale: 1.0,
      eyeSize: 1.0,
      mouthWidth: 1.0,
      noseSize: 1.0,
    ),
    TeacherPersonality.monk: TeacherAppearance(
      personality: TeacherPersonality.monk,
      name: 'Monk',
      skinPrimary: Color(0xFFe8c8a8),
      skinSecondary: Color(0xFFd4a574),
      skinShadow: Color(0xFFa67c52),
      hairPrimary: Color(0xFF1a1a1a),
      hairSecondary: Color(0xFF2d2d2d),
      clothPrimary: Color(0xFF8b0000), // Deep maroon
      clothSecondary: Color(0xFF5c0000),
      clothAccent: Color(0xFFffd700),
      auraPrimary: Color(0xFFffd700),
      auraSecondary: Color(0xFF8b0000),
      headScale: 1.05,
      torsoScale: 1.05,
      limbScale: 0.95,
      overallScale: 0.98,
      eyeSize: 0.95,
      mouthWidth: 0.9,
      noseSize: 0.95,
    ),
    TeacherPersonality.shiva: TeacherAppearance(
      personality: TeacherPersonality.shiva,
      name: 'Shiva',
      skinPrimary: Color(0xFF7ec8e3), // Blue skin (cosmic Shiva)
      skinSecondary: Color(0xFF5aaecc),
      skinShadow: Color(0xFF2e88a8),
      hairPrimary: Color(0xFF1a0a2e), // Dark indigo matted locks
      hairSecondary: Color(0xFF2d1a4a),
      clothPrimary: Color(0xFFd4af37), // Tiger-skin gold wrap
      clothSecondary: Color(0xFF8b6914),
      clothAccent: Color(0xFFffd700),
      auraPrimary: Color(0xFF00e5ff), // Electric blue cosmic aura
      auraSecondary: Color(0xFFb39ddb),
      headScale: 1.08,
      torsoScale: 1.12,
      limbScale: 1.05,
      overallScale: 1.08,
      eyeSize: 1.15, // Third eye prominence
      mouthWidth: 0.95,
      noseSize: 1.0,
    ),
    TeacherPersonality.tiger: TeacherAppearance(
      personality: TeacherPersonality.tiger,
      name: 'Tiger Warrior',
      skinPrimary: Color(0xFFd4956a), // Warm tan warrior skin
      skinSecondary: Color(0xFFb87548),
      skinShadow: Color(0xFF8b5530),
      hairPrimary: Color(0xFF1a1a1a), // Black hair pulled back
      hairSecondary: Color(0xFF2d2d2d),
      clothPrimary: Color(0xFFff6d00), // Tiger orange
      clothSecondary: Color(0xFF1a1a1a), // Black tiger stripes
      clothAccent: Color(0xFFffd54f), // Amber highlights
      auraPrimary: Color(0xFFff6d00), // Blazing orange aura
      auraSecondary: Color(0xFFffe082),
      headScale: 1.0,
      torsoScale: 1.15, // Broad, powerful build
      limbScale: 1.1,
      overallScale: 1.05,
      eyeSize: 1.1,
      mouthWidth: 1.05,
      noseSize: 1.05,
    ),
  };
}
