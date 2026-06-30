import 'package:hive/hive.dart';

part 'user_preferences_model.g.dart';

@HiveType(typeId: 4)
class UserPreferences {
  @HiveField(0)
  final String theme;

  @HiveField(1)
  final bool notifications;

  @HiveField(2)
  final bool sounds;

  @HiveField(3)
  final bool vibration;

  @HiveField(4)
  final bool hapticFeedback;

  @HiveField(5)
  final bool autoPlayMusic;

  @HiveField(6)
  final int defaultSessionDuration;

  @HiveField(7)
  final String defaultBreathingTechnique;

  UserPreferences({
    this.theme = 'nature',
    this.notifications = true,
    this.sounds = true,
    this.vibration = true,
    this.hapticFeedback = true,
    this.autoPlayMusic = false,
    this.defaultSessionDuration = 5,
    this.defaultBreathingTechnique = 'box',
  });

  UserPreferences copyWith({
    String? theme,
    bool? notifications,
    bool? sounds,
    bool? vibration,
    bool? hapticFeedback,
    bool? autoPlayMusic,
    int? defaultSessionDuration,
    String? defaultBreathingTechnique,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      sounds: sounds ?? this.sounds,
      vibration: vibration ?? this.vibration,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoPlayMusic: autoPlayMusic ?? this.autoPlayMusic,
      defaultSessionDuration:
      defaultSessionDuration ?? this.defaultSessionDuration,
      defaultBreathingTechnique:
      defaultBreathingTechnique ?? this.defaultBreathingTechnique,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'sounds': sounds,
      'vibration': vibration,
      'hapticFeedback': hapticFeedback,
      'autoPlayMusic': autoPlayMusic,
      'defaultSessionDuration': defaultSessionDuration,
      'defaultBreathingTechnique': defaultBreathingTechnique,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'nature',
      notifications: json['notifications'] ?? true,
      sounds: json['sounds'] ?? true,
      vibration: json['vibration'] ?? true,
      hapticFeedback: json['hapticFeedback'] ?? true,
      autoPlayMusic: json['autoPlayMusic'] ?? false,
      defaultSessionDuration: json['defaultSessionDuration'] ?? 5,
      defaultBreathingTechnique: json['defaultBreathingTechnique'] ?? 'box',
    );
  }

  @override
  String toString() {
    return 'UserPreferences(theme: $theme, notifications: $notifications, sounds: $sounds, vibration: $vibration, hapticFeedback: $hapticFeedback, autoPlayMusic: $autoPlayMusic, defaultSessionDuration: $defaultSessionDuration, defaultBreathingTechnique: $defaultBreathingTechnique)';
  }
}
