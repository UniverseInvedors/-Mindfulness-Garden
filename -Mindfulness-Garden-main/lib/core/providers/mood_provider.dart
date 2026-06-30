import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/data/models/mood_model.dart';
import 'package:pranaverse/data/repositories/mood_repository.dart';

// Mood State
class MoodState {
  final MoodModel? todayMood;
  final List<MoodModel> recentMoods;
  final bool isLoading;
  final String? error;

  MoodState({
    this.todayMood,
    this.recentMoods = const [],
    this.isLoading = false,
    this.error,
  });

  MoodState copyWith({
    MoodModel? todayMood,
    List<MoodModel>? recentMoods,
    bool? isLoading,
    String? error,
  }) {
    return MoodState(
      todayMood: todayMood ?? this.todayMood,
      recentMoods: recentMoods ?? this.recentMoods,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Mood StateNotifier
class MoodNotifier extends StateNotifier<MoodState> {
  final MoodRepository _repository;

  MoodNotifier(this._repository) : super(MoodState());

  // Getters
  MoodModel? get todayMood => state.todayMood;
  List<MoodModel> get recentMoods => state.recentMoods;
  bool get isLoading => state.isLoading;

  // Load Today's Mood
  Future<void> loadTodayMood() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final mood = await _repository.getMoodForDate(DateTime.now());
      state = state.copyWith(todayMood: mood, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading today\'s mood: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load Recent Moods
  Future<void> loadRecentMoods() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final moods = await _repository.getRecentMoods();
      state = state.copyWith(recentMoods: moods, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent moods: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Save Mood
  Future<void> saveMood({
    required String mood,
    required int rating,
    String? note,
    List<String> tags = const [],
  }) async {
    try {
      await _repository.saveMood(
        mood: mood,
        rating: rating,
        note: note,
        tags: tags,
      );
      await loadTodayMood();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving mood: $e');
      }
      state = state.copyWith(error: e.toString());
    }
  }

  // Get Mood Trends
  Future<List<MoodModel>> getMoodTrends() async {
    return await _repository.getMoodTrends();
  }

  // Set Today's Mood (local update)
  void setTodayMood(String mood) {
    final updatedMood = state.todayMood?.copyWith(mood: mood) ?? MoodModel(
      id: DateTime.now().toIso8601String(),
      date: DateTime.now(),
      mood: mood,
      rating: 3,
    );
    state = state.copyWith(todayMood: updatedMood);
  }
}

// Providers
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return MoodNotifier(repository);
});

// Convenience providers
final todayMoodProvider = Provider<MoodModel?>((ref) {
  return ref.watch(moodProvider).todayMood;
});

final recentMoodsProvider = Provider<List<MoodModel>>((ref) {
  return ref.watch(moodProvider).recentMoods;
});
