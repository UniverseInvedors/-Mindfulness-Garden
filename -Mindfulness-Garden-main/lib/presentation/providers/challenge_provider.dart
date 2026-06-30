import 'package:flutter/foundation.dart';
import 'package:pranaverse/data/models/challenge_model.dart';
import 'package:pranaverse/data/repositories/challenge_repository.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeRepository _repository = ChallengeRepository();

  List<Challenge> _challenges = [];
  Challenge? _todayChallenge;
  Map<String, bool> _completedChallenges = {};
  int _points = 0;
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  Challenge? get todayChallenge => _todayChallenge;
  Map<String, bool> get completedChallenges => _completedChallenges;
  int get points => _points;
  bool get isLoading => _isLoading;

  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();
    try {
      _challenges = await _repository.getChallenges();
      _todayChallenge = await _repository.getTodayChallenge();
      _completedChallenges = await _repository.getCompletedChallenges();
      _points = await _repository.getPoints();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshChallenges() async {
    await loadChallenges();
  }

  Future<void> completeChallenge(String challengeId) async {
    await _repository.completeChallenge(challengeId);
    await loadChallenges();
  }

  Future<void> claimReward(String challengeId) async {
    await _repository.claimReward(challengeId);
    await loadChallenges();
  }
}
