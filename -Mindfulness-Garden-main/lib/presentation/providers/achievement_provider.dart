import 'package:flutter/foundation.dart';
import 'package:pranaverse/data/models/achievement_model.dart';
import 'package:pranaverse/data/repositories/achievement_repository.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementRepository _repository;
  List<AchievementModel> _achievements = [];

  AchievementProvider(this._repository) {
    _loadAchievements();
  }

  List<AchievementModel> get achievements => _achievements;

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get totalCount => _achievements.length;
  int get inProgressCount =>
      _achievements.where((a) => !a.isUnlocked && a.progress > 0).length;
  int get totalPoints => _achievements
      .where((a) => a.isUnlocked)
      .fold<int>(0, (sum, a) => sum + a.rewardValue);

  Future<void> _loadAchievements() async {
    _achievements = await _repository.getAchievements();
    notifyListeners();
  }

  Future<void> unlockAchievement(String achievementId) async {
    await _repository.unlockAchievement(achievementId);
    await _loadAchievements();
  }

  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    await _repository.updateAchievementProgress(achievementId, progress);
    await _loadAchievements();
  }

  Future<void> incrementAchievementProgress(
    String achievementId,
    int increment,
  ) async {
    await _repository.incrementAchievementProgress(achievementId, increment);
    await _loadAchievements();
  }

  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }

  // Helper methods for specific achievements
  Future<void> recordMeditationSession(int minutes) async {
    // Update total minutes achievement
    await incrementAchievementProgress('meditation_minutes_100', minutes);

    // Check and update streak (you'll need to implement streak logic)
    // This is a simplified example
    final currentStreak = 1; // Get actual streak from session repository
    await updateAchievementProgress('meditation_streak_7', currentStreak);
  }
}
