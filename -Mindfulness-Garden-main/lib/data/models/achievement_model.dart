import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 5)
class AchievementModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final String icon;

  @HiveField(5)
  final String rarity; // common, rare, epic, legendary

  @HiveField(6)
  final String requirement;

  @HiveField(7)
  int progress;

  @HiveField(8)
  final int target;

  @HiveField(9)
  bool isUnlocked;

  @HiveField(10)
  DateTime? unlockedAt;

  @HiveField(11)
  final String rewardType;

  @HiveField(12)
  final int rewardValue;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.rarity = 'common',
    required this.requirement,
    this.progress = 0,
    required this.target,
    this.isUnlocked = false,
    this.unlockedAt,
    this.rewardType = 'points',
    this.rewardValue = 0,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? icon,
    String? rarity,
    String? requirement,
    int? progress,
    int? target,
    bool? isUnlocked,
    DateTime? unlockedAt,
    String? rewardType,
    int? rewardValue,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      requirement: requirement ?? this.requirement,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rewardType: rewardType ?? this.rewardType,
      rewardValue: rewardValue ?? this.rewardValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'rarity': rarity,
      'requirement': requirement,
      'progress': progress,
      'target': target,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'rewardType': rewardType,
      'rewardValue': rewardValue,
    };
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      icon: json['icon'],
      rarity: json['rarity'],
      requirement: json['requirement'],
      progress: json['progress'],
      target: json['target'],
      isUnlocked: json['isUnlocked'],
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      rewardType: json['rewardType'],
      rewardValue: json['rewardValue'],
    );
  }

  // Helper getter for percentage progress
  double get progressPercentage => target > 0 ? progress / target : 0.0;

  // Helper getter for points (alias for rewardValue)
  int get points => rewardValue;
}
