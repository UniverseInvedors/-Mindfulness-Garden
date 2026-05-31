// data/models/user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final DateTime joinedDate;

  @HiveField(4)
  final int totalSessions;

  @HiveField(5)
  final int totalMinutes;

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final int gardenLevel;

  @HiveField(8)
  final DateTime? lastSessionDate;

  @HiveField(9)
  final List<String> achievements;

  @HiveField(10)
  final UserPreferences preferences;

  @HiveField(11)
  final int coins; // Unified wallet integration

  @HiveField(12)
  final int premiumEnergy; // Unified wallet integration

  @HiveField(13)
  final int mindfulnessTokens; // Unified wallet integration

  int get achievementCount => achievements.length;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedDate,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.gardenLevel = 1,
    this.lastSessionDate,
    this.achievements = const [],
    required this.preferences,
    this.coins = 100, // Starting coins
    this.premiumEnergy = 0,
    this.mindfulnessTokens = 0,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinedDate,
    int? totalSessions,
    int? totalMinutes,
    int? currentStreak,
    int? gardenLevel,
    DateTime? lastSessionDate,
    List<String>? achievements,
    UserPreferences? preferences,
    int? coins,
    int? premiumEnergy,
    int? mindfulnessTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedDate: joinedDate ?? this.joinedDate,
      totalSessions: totalSessions ?? this.totalSessions,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      gardenLevel: gardenLevel ?? this.gardenLevel,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      coins: coins ?? this.coins,
      premiumEnergy: premiumEnergy ?? this.premiumEnergy,
      mindfulnessTokens: mindfulnessTokens ?? this.mindfulnessTokens,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'joinedDate': joinedDate.toIso8601String(),
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'currentStreak': currentStreak,
      'gardenLevel': gardenLevel,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'achievements': achievements,
      'preferences': preferences.toJson(),
      'coins': coins,
      'premiumEnergy': premiumEnergy,
      'mindfulnessTokens': mindfulnessTokens,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      joinedDate: DateTime.parse(json['joinedDate']),
      totalSessions: json['totalSessions'],
      totalMinutes: json['totalMinutes'],
      currentStreak: json['currentStreak'],
      gardenLevel: json['gardenLevel'],
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'])
          : null,
      achievements: List<String>.from(json['achievements']),
      preferences: UserPreferences.fromJson(json['preferences']),
      coins: json['coins'] ?? 100,
      premiumEnergy: json['premiumEnergy'] ?? 0,
      mindfulnessTokens: json['mindfulnessTokens'] ?? 0,
    );
  }
}

@HiveType(typeId: 2)
class UserPreferences {
  @HiveField(0)
  final String theme;

  @HiveField(1)
  final bool notifications;

  @HiveField(2)
  final bool sounds;

  @HiveField(3)
  final bool vibration;

  UserPreferences({
    this.theme = 'nature',
    this.notifications = true,
    this.sounds = true,
    this.vibration = true,
  });

  UserPreferences copyWith({
    String? theme,
    bool? notifications,
    bool? sounds,
    bool? vibration,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      sounds: sounds ?? this.sounds,
      vibration: vibration ?? this.vibration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notifications': notifications,
      'sounds': sounds,
      'vibration': vibration,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'nature',
      notifications: json['notifications'] ?? true,
      sounds: json['sounds'] ?? true,
      vibration: json['vibration'] ?? true,
    );
  }
}
