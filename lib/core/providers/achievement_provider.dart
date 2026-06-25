import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/data/models/achievement_model.dart';
import 'package:pranaverse/data/repositories/achievement_repository.dart';

// Achievement State
class AchievementState {
  final List<AchievementModel> achievements;
  final bool isLoading;
  final String? error;

  AchievementState({
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });

  AchievementState copyWith({
    List<AchievementModel>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Computed properties
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;
  int get totalCount => achievements.length;
  int get inProgressCount =>
      achievements.where((a) => !a.isUnlocked && a.progress > 0).length;
  int get totalPoints => achievements
      .where((a) => a.isUnlocked)
      .fold<int>(0, (sum, a) => sum + a.rewardValue);
}

// Achievement StateNotifier
class AchievementNotifier extends StateNotifier<AchievementState> {
  final AchievementRepository _repository;

  AchievementNotifier(this._repository) : super(AchievementState()) {
    _loadAchievements();
  }

  // Getters
  List<AchievementModel> get achievements => state.achievements;
  int get unlockedCount => state.unlockedCount;
  int get totalCount => state.totalCount;
  int get inProgressCount => state.inProgressCount;
  int get totalPoints => state.totalPoints;

  // Load achievements
  Future<void> _loadAchievements() async {
    try {
      final achievements = await _repository.getAchievements();
      state = state.copyWith(achievements: achievements);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading achievements: $e');
      }
      state = state.copyWith(error: e.toString());
    }
  }

  // Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    try {
      await _repository.unlockAchievement(achievementId);
      await _loadAchievements();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Update achievement progress
  Future<void> updateAchievementProgress(
    String achievementId,
    int progress,
  ) async {
    try {
      await _repository.updateAchievementProgress(achievementId, progress);
      await _loadAchievements();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Increment achievement progress
  Future<void> incrementAchievementProgress(
    String achievementId,
    int increment,
  ) async {
    try {
      await _repository.incrementAchievementProgress(achievementId, increment);
      await _loadAchievements();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Refresh achievements
  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }

  // Helper methods for specific achievements
  Future<void> recordMeditationSession(int minutes) async {
    await incrementAchievementProgress('meditation_minutes_100', minutes);
    final currentStreak = 1; // Get actual streak from session repository
    await updateAchievementProgress('meditation_streak_7', currentStreak);
  }
}

// Providers
final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository();
});

final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  final repository = ref.watch(achievementRepositoryProvider);
  return AchievementNotifier(repository);
});

// Convenience providers
final achievementsProvider = Provider<List<AchievementModel>>((ref) {
  return ref.watch(achievementProvider).achievements;
});

final unlockedCountProvider = Provider<int>((ref) {
  return ref.watch(achievementProvider).unlockedCount;
});

final totalPointsProvider = Provider<int>((ref) {
  return ref.watch(achievementProvider).totalPoints;
});
