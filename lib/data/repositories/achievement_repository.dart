import 'package:mindfulness_garden/data/models/achievement_model.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class AchievementRepository {
  Future<List<AchievementModel>> getAchievements() async {
    // First try to get saved achievements from storage
    final savedAchievements = await _getSavedAchievements();

    if (savedAchievements.isNotEmpty) {
      return savedAchievements;
    }

    // Return default achievements if no saved ones
    return getDefaultAchievements();
  }

  Future<List<AchievementModel>> getDefaultAchievements() {
    return Future.value([
      AchievementModel(
        id: 'meditation_streak_7',
        title: '7 Day Streak',
        description: 'Meditate for 7 consecutive days',
        icon: '🔥',
        category: 'Meditation',
        rarity: 'rare',
        requirement: 'Complete 7 consecutive days of meditation',
        progress: 3,
        target: 7,
        isUnlocked: false,
        rewardType: 'points',
        rewardValue: 100,
      ),
      AchievementModel(
        id: 'meditation_minutes_100',
        title: '100 Minutes',
        description: 'Complete 100 minutes of meditation',
        icon: '⏱️',
        category: 'Meditation',
        rarity: 'common',
        requirement: 'Accumulate 100 minutes of meditation time',
        progress: 100,
        target: 100,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
        rewardType: 'points',
        rewardValue: 50,
      ),
      AchievementModel(
        id: 'garden_level_5',
        title: 'Garden Master',
        description: 'Reach level 5 in your garden',
        icon: '🌿',
        category: 'Garden',
        rarity: 'epic',
        requirement: 'Reach level 5 in garden progression',
        progress: 2,
        target: 5,
        isUnlocked: false,
        rewardType: 'points',
        rewardValue: 75,
      ),
      AchievementModel(
        id: 'breathing_types_3',
        title: 'Breath Explorer',
        description: 'Try 3 different breathing exercises',
        icon: '🌬️',
        category: 'Meditation',
        rarity: 'common',
        requirement: 'Complete 3 different breathing exercises',
        progress: 2,
        target: 3,
        isUnlocked: false,
        rewardType: 'points',
        rewardValue: 30,
      ),
      AchievementModel(
        id: 'mood_tracker_week',
        title: 'Mindful Tracker',
        description: 'Track your mood for 7 days',
        icon: '📊',
        category: 'Social',
        rarity: 'common',
        requirement: 'Track mood for 7 consecutive days',
        progress: 2,
        target: 7,
        isUnlocked: false,
        rewardType: 'points',
        rewardValue: 40,
      ),
    ]);
  }

  Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index != -1) {
      final achievement = achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      achievements[index] = achievement;
      await _saveAchievements(achievements);
    }
  }

  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index != -1) {
      final achievement = achievements[index].copyWith(
        progress: progress,
      );

      // Auto-unlock if progress reaches target
      if (progress >= achievement.target && !achievement.isUnlocked) {
        await unlockAchievement(achievementId);
      } else {
        achievements[index] = achievement;
        await _saveAchievements(achievements);
      }
    }
  }

  Future<void> incrementAchievementProgress(
    String achievementId,
    int increment,
  ) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index != -1) {
      final newProgress = achievements[index].progress + increment;
      await updateAchievementProgress(achievementId, newProgress);
    }
  }

  Future<bool> isAchievementUnlocked(String achievementId) async {
    final achievements = await getAchievements();
    final achievement = achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => AchievementModel(
        id: '',
        title: '',
        description: '',
        category: '',
        icon: '',
        requirement: '',
        target: 0,
      ),
    );
    return achievement.isUnlocked;
  }

  Future<int> getAchievementProgress(String achievementId) async {
    final achievements = await getAchievements();
    final achievement = achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => AchievementModel(
        id: '',
        title: '',
        description: '',
        category: '',
        icon: '',
        requirement: '',
        target: 0,
      ),
    );
    return achievement.progress;
  }

  // Private helper methods
  Future<List<AchievementModel>> _getSavedAchievements() async {
    final savedData = LocalStorageService.getSetting(
      'achievements_data',
      defaultValue: null,
    );

    if (savedData != null && savedData is List) {
      return savedData.map((item) => AchievementModel.fromJson(item)).toList();
    }

    return [];
  }

  Future<void> _saveAchievements(List<AchievementModel> achievements) async {
    final data = achievements.map((a) => a.toJson()).toList();
    await LocalStorageService.saveSetting('achievements_data', data);
  }

  Future<void> resetAchievements() async {
    await LocalStorageService.removeSetting('achievements_data');
  }
}
