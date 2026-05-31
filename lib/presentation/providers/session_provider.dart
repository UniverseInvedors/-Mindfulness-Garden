import 'package:flutter/foundation.dart';
import 'package:mindfulness_garden/data/models/session_model.dart';
import 'package:mindfulness_garden/data/repositories/session_repository.dart';

class SessionProvider with ChangeNotifier {
  final SessionRepository _sessionRepository = SessionRepository();
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  SessionModel? _currentSession;

  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  SessionModel? get currentSession => _currentSession;

  SessionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadSessions();
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sessions = await _sessionRepository.getRecentSessions();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sessions: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSession({
    required int durationMinutes,
    required String meditationType,
    String? focusArea,
    String? moodBefore,
    String? moodAfter,
    String? notes,
    List<String> soundsUsed = const [],
  }) async {
    try {
      await _sessionRepository.saveSession(
        durationMinutes: durationMinutes,
        meditationType: meditationType,
        focusArea: focusArea ?? '',
        moodBefore: moodBefore ?? '',
        moodAfter: moodAfter ?? '',
        notes: notes ?? '',
        soundsUsed: soundsUsed,
      );

      // Refresh sessions list
      await loadSessions();

      // Update user stats through user provider
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session: $e');
      }
      rethrow;
    }
  }

  // Alias for saveSession (for backward compatibility)
  Future<void> addSession({
    required int durationMinutes,
    required String meditationType,
    String? focusArea,
    String? moodBefore,
    String? moodAfter,
    String? notes,
    List<String> soundsUsed = const [],
  }) async {
    return saveSession(
      durationMinutes: durationMinutes,
      meditationType: meditationType,
      focusArea: focusArea ?? '',
      moodBefore: moodBefore ?? '',
      moodAfter: moodAfter ?? '',
      notes: notes ?? '',
      soundsUsed: soundsUsed,
    );
  }

  // Start a new session
  void startSession({
    required String meditationType,
    String? focusArea,
    String? moodBefore,
    List<String> soundsUsed = const [],
  }) {
    _currentSession = SessionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      durationMinutes: 0, // Will be updated when completed
      meditationType: meditationType,
      focusArea: focusArea ?? '',
      moodBefore: moodBefore ?? '',
      moodAfter: '',
      notes: '',
      soundsUsed: soundsUsed,
    );
    notifyListeners();
  }

  // Complete the current session
  Future<void> completeCurrentSession({
    int? durationMinutes,
    String? moodAfter,
    String? notes,
  }) async {
    if (_currentSession == null) return;

    final session = _currentSession!;
    final actualDuration = durationMinutes ??
        (DateTime.now().difference(session.startTime).inMinutes)
            .clamp(1, 120); // Limit to reasonable range

    await saveSession(
      durationMinutes: actualDuration,
      meditationType: session.meditationType,
      focusArea: session.focusArea,
      moodBefore: session.moodBefore,
      moodAfter: moodAfter ?? session.moodAfter,
      notes: notes ?? session.notes,
      soundsUsed: session.soundsUsed,
    );

    _currentSession = null;
    notifyListeners();
  }

  // Get session by ID
  SessionModel? getSessionById(String id) {
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get sessions by date
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    return await _sessionRepository.getSessionsByDate(date);
  }

  // Get sessions by type
  List<SessionModel> getSessionsByType(String meditationType) {
    return _sessions
        .where((session) => session.meditationType == meditationType)
        .toList();
  }

  // Get statistics
  Future<Map<String, int>> getStats() async {
    return await _sessionRepository.getSessionStats();
  }

  // Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStats() async {
    return await _sessionRepository.getWeeklyStats();
  }

  // Get total meditation time
  Future<int> getTotalMinutes() async {
    final stats = await getStats();
    return stats['totalMinutes'] ?? 0;
  }

  // Get current streak
  Future<int> getCurrentStreak() async {
    final stats = await getStats();
    return stats['currentStreak'] ?? 0;
  }

  // Get average session length
  Future<int> getAverageSessionLength() async {
    final stats = await getStats();
    return stats['avgSessionLength'] ?? 0;
  }

  // Clear all sessions
  Future<void> clearSessions() async {
    // This would typically clear from storage
    _sessions.clear();
    notifyListeners();
  }

  // Get recent sessions with limit
  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    return await _sessionRepository.getRecentSessions(limit: limit);
  }

  // Get sessions from this week
  Future<List<SessionModel>> getThisWeekSessions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return _sessions.where((session) {
      return session.startTime.isAfter(
        startOfWeek.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  // Get sessions from this month
  Future<List<SessionModel>> getThisMonthSessions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _sessions.where((session) {
      return session.startTime.isAfter(
        startOfMonth.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  // Get best day (most minutes)
  Future<Map<String, dynamic>> getBestDay() async {
    if (_sessions.isEmpty) {
      return {'date': null, 'minutes': 0};
    }

    // Group sessions by date
    final Map<DateTime, int> dailyMinutes = {};

    for (final session in _sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      dailyMinutes[date] = (dailyMinutes[date] ?? 0) + session.durationMinutes;
    }

    // Find day with most minutes
    DateTime? bestDate;
    int maxMinutes = 0;

    dailyMinutes.forEach((date, minutes) {
      if (minutes > maxMinutes) {
        maxMinutes = minutes;
        bestDate = date;
      }
    });

    return {'date': bestDate, 'minutes': maxMinutes};
  }

  // Get favorite meditation type
  String getFavoriteMeditationType() {
    if (_sessions.isEmpty) return 'Breath Awareness';

    final typeCount = <String, int>{};

    for (final session in _sessions) {
      typeCount[session.meditationType] =
          (typeCount[session.meditationType] ?? 0) + 1;
    }

    String favoriteType = 'Breath Awareness';
    int maxCount = 0;

    typeCount.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        favoriteType = type;
      }
    });

    return favoriteType;
  }

  // Get progress over time
  Map<DateTime, int> getProgressOverTime({int days = 30}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final Map<DateTime, int> progress = {};

    // Initialize all days with 0
    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      progress[dayKey] = 0;
    }

    // Fill with actual data
    for (final session in _sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (sessionDate.isAfter(startDate.subtract(const Duration(days: 1)))) {
        progress[sessionDate] =
            (progress[sessionDate] ?? 0) + session.durationMinutes;
      }
    }

    return progress;
  }

  // Check if user has meditated today
  Future<bool> hasMeditatedToday() async {
    final today = DateTime.now();
    final todaySessions = await getSessionsByDate(today);
    return todaySessions.isNotEmpty;
  }

  // Get today's sessions
  Future<List<SessionModel>> getTodaySessions() async {
    final today = DateTime.now();
    return await getSessionsByDate(today);
  }

  // Get today's total minutes
  Future<int> getTodayMinutes() async {
    final todaySessions = await getTodaySessions();
    int total = 0;
    for (final session in todaySessions) {
      total += session.durationMinutes;
    }
    return total;
  }

  // Update session notes
  Future<void> updateSessionNotes(String sessionId, String notes) async {
    final session = getSessionById(sessionId);
    if (session != null) {
      // In a real app, you would update this in the database
      // For now, we'll just update the local list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = session.copyWith(notes: notes);
        notifyListeners();
      }
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((session) => session.id == sessionId);
    notifyListeners();
  }

  // Cancel current session
  void cancelCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  // Update current session duration in real-time
  void updateCurrentSessionDuration(int minutes) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(durationMinutes: minutes);
      notifyListeners();
    }
  }

  // Get streak history
  Future<Map<DateTime, bool>> getStreakHistory({int days = 30}) async {
    final now = DateTime.now();
    final history = <DateTime, bool>{};

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final sessionsOnDate = await getSessionsByDate(date);
      history[date] = sessionsOnDate.isNotEmpty;
    }

    return history;
  }
}
