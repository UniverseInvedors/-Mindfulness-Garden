import 'package:mindfulness_garden/data/models/challenge_model.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class ChallengeRepository {
  static final List<Map<String, dynamic>> _allChallenges = [
    // Daily
    {'id': 'd1', 'title': 'Morning Calm', 'description': 'Complete a 5-min morning meditation', 'type': ChallengeType.daily, 'reward': 50},
    {'id': 'd2', 'title': 'Breath Break', 'description': 'Do any breathing exercise today', 'type': ChallengeType.daily, 'reward': 40},
    {'id': 'd3', 'title': 'Evening Wind Down', 'description': 'Meditate for 10 min before bed', 'type': ChallengeType.daily, 'reward': 60},
    {'id': 'd4', 'title': 'Mindful Minute', 'description': 'Take 3 mindful breaths every hour', 'type': ChallengeType.daily, 'reward': 30},
    // Weekly
    {'id': 'w1', 'title': '7-Day Streak', 'description': 'Meditate 7 days in a row', 'type': ChallengeType.weekly, 'reward': 300},
    {'id': 'w2', 'title': 'Breath Explorer', 'description': 'Try all 6 breathing exercises', 'type': ChallengeType.weekly, 'reward': 200},
    {'id': 'w3', 'title': 'Garden Keeper', 'description': 'Grow 5 plants this week', 'type': ChallengeType.weekly, 'reward': 250},
    {'id': 'w4', 'title': 'Mood Tracker', 'description': 'Log your mood 5 days this week', 'type': ChallengeType.weekly, 'reward': 150},
    // Achievement
    {'id': 'a1', 'title': 'Breath Master', 'description': 'Complete 10 breathing sessions', 'type': ChallengeType.achievement, 'reward': 500},
    {'id': 'a2', 'title': 'Zen Garden', 'description': 'Unlock all 6 seasons in the garden', 'type': ChallengeType.achievement, 'reward': 400},
    {'id': 'a3', 'title': 'Mindfulness Guru', 'description': 'Reach 30-day meditation streak', 'type': ChallengeType.achievement, 'reward': 1000},
    // AI Opponent
    {'id': 'ai1', 'title': 'Beat Zeno', 'description': 'Complete more sessions than Zeno today', 'type': ChallengeType.social, 'reward': 100},
    {'id': 'ai2', 'title': 'Streak Battle', 'description': 'Maintain a longer streak than Zeno', 'type': ChallengeType.social, 'reward': 150},
    {'id': 'ai3', 'title': 'Garden Duel', 'description': 'Grow more plants than Zeno this week', 'type': ChallengeType.social, 'reward': 120},
  ];

  Future<List<Challenge>> getChallenges() async {
    final List<Challenge> result = [];
    for (final c in _allChallenges) {
      final raw = LocalStorageService.getSetting('challenge_${c['id']}');
      final completed = raw == true;
      final progress = _getRealProgress(c['id'] as String);
      result.add(Challenge(
        id: c['id'] as String,
        title: c['title'] as String,
        description: c['description'] as String,
        type: c['type'] as ChallengeType,
        reward: c['reward'] as int,
        isCompleted: completed,
        progress: completed ? 1.0 : progress,
      ));
    }
    return result;
  }

  /// Calculates real progress from actual stored data
  double _getRealProgress(String id) {
    final sessions = LocalStorageService.getSessions();
    final moods = LocalStorageService.getAllMoods();
    final streak = LocalStorageService.getCurrentStreak();
    final user = LocalStorageService.getUser();

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    switch (id) {
      case 'w1': // 7-Day Streak
        return (streak / 7).clamp(0.0, 1.0);

      case 'w2': // Breath Explorer — count distinct breathing types this week
        final weekSessions = sessions.where((s) =>
            s.startTime.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
        final types = weekSessions.map((s) => s.meditationType).toSet();
        return (types.length / 6).clamp(0.0, 1.0);

      case 'w3': // Garden Keeper — plants grown (stored as setting)
        final plants = LocalStorageService.getSetting('garden_plants_grown') ?? 0;
        return ((plants as int) / 5).clamp(0.0, 1.0);

      case 'w4': // Mood Tracker — mood entries this week
        final weekMoods = moods.where((m) =>
            m.date.isAfter(weekStart.subtract(const Duration(days: 1)))).length;
        return (weekMoods / 5).clamp(0.0, 1.0);

      case 'a1': // Breath Master — 10 breathing sessions total
        final breathSessions = sessions.where((s) =>
            s.meditationType.toLowerCase().contains('breath') ||
            s.meditationType.toLowerCase().contains('box') ||
            s.meditationType.toLowerCase().contains('zeno') ||
            s.meditationType.toLowerCase().contains('nostril') ||
            s.meditationType.toLowerCase().contains('diaphragm') ||
            s.meditationType.toLowerCase().contains('478')).length;
        return (breathSessions / 10).clamp(0.0, 1.0);

      case 'a2': // Zen Garden — 6 seasons (stored as setting)
        final seasons = LocalStorageService.getSetting('garden_seasons_unlocked') ?? 1;
        return ((seasons as int) / 6).clamp(0.0, 1.0);

      case 'a3': // Mindfulness Guru — 30-day streak
        return (streak / 30).clamp(0.0, 1.0);

      case 'ai1': // Beat Zeno — sessions today vs Zeno's 2
        final todaySessions = LocalStorageService.getSessionsByDate(now).length;
        return (todaySessions / 2).clamp(0.0, 1.0);

      case 'ai2': // Streak Battle — streak vs Zeno's 5
        return (streak / 5).clamp(0.0, 1.0);

      case 'ai3': // Garden Duel — plants vs Zeno's 4
        final plants = LocalStorageService.getSetting('garden_plants_grown') ?? 0;
        return ((plants as int) / 4).clamp(0.0, 1.0);

      default:
        return 0.0;
    }
  }

  Future<Challenge?> getTodayChallenge() async {
    final now = DateTime.now();
    final idx = now.day % 4;
    final dailyChallenges = _allChallenges.where((c) => c['type'] == ChallengeType.daily).toList();
    final c = dailyChallenges[idx];
    final raw = LocalStorageService.getSetting('challenge_${c['id']}');
    final completed = raw == true;
    return Challenge(
      id: c['id'] as String,
      title: c['title'] as String,
      description: c['description'] as String,
      type: c['type'] as ChallengeType,
      reward: c['reward'] as int,
      isCompleted: completed,
      progress: completed ? 1.0 : _getRealProgress(c['id'] as String),
    );
  }

  Future<Map<String, bool>> getCompletedChallenges() async {
    final Map<String, bool> result = {};
    for (final c in _allChallenges) {
      final id = c['id'] as String;
      final raw = LocalStorageService.getSetting('challenge_$id');
      result[id] = raw == true;
    }
    return result;
  }

  Future<int> getPoints() async {
    int total = 0;
    for (final c in _allChallenges) {
      final id = c['id'] as String;
      final raw = LocalStorageService.getSetting('challenge_$id');
      if (raw == true) total += c['reward'] as int;
    }
    return total;
  }

  Future<void> completeChallenge(String challengeId) async {
    await LocalStorageService.saveSetting('challenge_$challengeId', true);
  }

  Future<void> claimReward(String challengeId) async {
    await LocalStorageService.saveSetting('reward_$challengeId', true);
  }
}
