import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/data/models/challenge_model.dart';
import 'package:pranaverse/data/repositories/challenge_repository.dart';

// Challenge State
class ChallengeState {
  final List<Challenge> challenges;
  final Challenge? todayChallenge;
  final Map<String, bool> completedChallenges;
  final int points;
  final bool isLoading;
  final String? error;

  ChallengeState({
    this.challenges = const [],
    this.todayChallenge,
    this.completedChallenges = const {},
    this.points = 0,
    this.isLoading = false,
    this.error,
  });

  ChallengeState copyWith({
    List<Challenge>? challenges,
    Challenge? todayChallenge,
    Map<String, bool>? completedChallenges,
    int? points,
    bool? isLoading,
    String? error,
  }) {
    return ChallengeState(
      challenges: challenges ?? this.challenges,
      todayChallenge: todayChallenge ?? this.todayChallenge,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      points: points ?? this.points,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Challenge StateNotifier
class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;

  ChallengeNotifier(this._repository) : super(ChallengeState());

  // Getters
  List<Challenge> get challenges => state.challenges;
  Challenge? get todayChallenge => state.todayChallenge;
  Map<String, bool> get completedChallenges => state.completedChallenges;
  int get points => state.points;
  bool get isLoading => state.isLoading;

  // Load challenges
  Future<void> loadChallenges() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final challenges = await _repository.getChallenges();
      final todayChallenge = await _repository.getTodayChallenge();
      final completedChallenges = await _repository.getCompletedChallenges();
      final points = await _repository.getPoints();

      state = state.copyWith(
        challenges: challenges,
        todayChallenge: todayChallenge,
        completedChallenges: completedChallenges,
        points: points,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading challenges: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh challenges
  Future<void> refreshChallenges() async {
    await loadChallenges();
  }

  // Complete challenge
  Future<void> completeChallenge(String challengeId) async {
    try {
      await _repository.completeChallenge(challengeId);
      await loadChallenges();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Claim reward
  Future<void> claimReward(String challengeId) async {
    try {
      await _repository.claimReward(challengeId);
      await loadChallenges();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

final challengeProvider = StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  final repository = ref.watch(challengeRepositoryProvider);
  return ChallengeNotifier(repository);
});

// Convenience providers
final challengesProvider = Provider<List<Challenge>>((ref) {
  return ref.watch(challengeProvider).challenges;
});

final todayChallengeProvider = Provider<Challenge?>((ref) {
  return ref.watch(challengeProvider).todayChallenge;
});

final challengePointsProvider = Provider<int>((ref) {
  return ref.watch(challengeProvider).points;
});
