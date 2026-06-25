import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/data/models/session_model.dart';
import 'package:pranaverse/data/repositories/session_repository.dart';

// Session State
class SessionState {
  final List<SessionModel> sessions;
  final SessionModel? currentSession;
  final bool isLoading;
  final String? error;

  SessionState({
    this.sessions = const [],
    this.currentSession,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    List<SessionModel>? sessions,
    SessionModel? currentSession,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Session StateNotifier
class SessionNotifier extends StateNotifier<SessionState> {
  final SessionRepository _repository;

  SessionNotifier(this._repository) : super(SessionState()) {
    _initialize();
  }

  // Getters
  List<SessionModel> get sessions => state.sessions;
  SessionModel? get currentSession => state.currentSession;
  bool get isLoading => state.isLoading;

  // Initialize
  Future<void> _initialize() async {
    await loadSessions();
  }

  // Load Sessions
  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final sessions = await _repository.getRecentSessions();
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sessions: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Save Session
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
      await _repository.saveSession(
        durationMinutes: durationMinutes,
        meditationType: meditationType,
        focusArea: focusArea ?? '',
        moodBefore: moodBefore ?? '',
        moodAfter: moodAfter ?? '',
        notes: notes ?? '',
        soundsUsed: soundsUsed,
      );

      await loadSessions();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving session: $e');
      }
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Alias for saveSession
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
    state = state.copyWith(
      currentSession: SessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        durationMinutes: 0,
        meditationType: meditationType,
        focusArea: focusArea ?? '',
        moodBefore: moodBefore ?? '',
        moodAfter: '',
        notes: '',
        soundsUsed: soundsUsed,
      ),
    );
  }

  // Complete the current session
  Future<void> completeCurrentSession({
    int? durationMinutes,
    String? moodAfter,
    String? notes,
  }) async {
    if (state.currentSession == null) return;

    final session = state.currentSession!;
    final actualDuration = durationMinutes ??
        (DateTime.now().difference(session.startTime).inMinutes)
            .clamp(1, 120);

    await saveSession(
      durationMinutes: actualDuration,
      meditationType: session.meditationType,
      focusArea: session.focusArea,
      moodBefore: session.moodBefore,
      moodAfter: moodAfter ?? session.moodAfter,
      notes: notes ?? session.notes,
      soundsUsed: session.soundsUsed,
    );

    state = state.copyWith(currentSession: null);
  }

  // Get session by ID
  SessionModel? getSessionById(String id) {
    try {
      return state.sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get sessions by date
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    return await _repository.getSessionsByDate(date);
  }

  // Get sessions by type
  List<SessionModel> getSessionsByType(String meditationType) {
    return state.sessions
        .where((session) => session.meditationType == meditationType)
        .toList();
  }

  // Get statistics
  Future<Map<String, int>> getStats() async {
    return await _repository.getSessionStats();
  }

  // Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStats() async {
    return await _repository.getWeeklyStats();
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
    state = state.copyWith(sessions: []);
  }

  // Get recent sessions with limit
  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    return await _repository.getRecentSessions(limit: limit);
  }

  // Get sessions from this week
  Future<List<SessionModel>> getThisWeekSessions() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return state.sessions.where((session) {
      return session.startTime.isAfter(
        startOfWeek.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  // Get sessions from this month
  Future<List<SessionModel>> getThisMonthSessions() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return state.sessions.where((session) {
      return session.startTime.isAfter(
        startOfMonth.subtract(const Duration(days: 1)),
      );
    }).toList();
  }

  // Get best day (most minutes)
  Future<Map<String, dynamic>> getBestDay() async {
    if (state.sessions.isEmpty) {
      return {'date': null, 'minutes': 0};
    }

    final Map<DateTime, int> dailyMinutes = {};

    for (final session in state.sessions) {
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      dailyMinutes[date] = (dailyMinutes[date] ?? 0) + session.durationMinutes;
    }

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
    if (state.sessions.isEmpty) return 'Breath Awareness';

    final typeCount = <String, int>{};

    for (final session in state.sessions) {
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

    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day);
      progress[dayKey] = 0;
    }

    for (final session in state.sessions) {
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
      final updatedSessions = state.sessions.map((s) {
        if (s.id == sessionId) {
          return s.copyWith(notes: notes);
        }
        return s;
      }).toList();
      state = state.copyWith(sessions: updatedSessions);
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    final updatedSessions = state.sessions.where((session) => session.id != sessionId).toList();
    state = state.copyWith(sessions: updatedSessions);
  }

  // Cancel current session
  void cancelCurrentSession() {
    state = state.copyWith(currentSession: null);
  }

  // Update current session duration in real-time
  void updateCurrentSessionDuration(int minutes) {
    if (state.currentSession != null) {
      state = state.copyWith(
        currentSession: state.currentSession!.copyWith(durationMinutes: minutes),
      );
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

// Providers
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repository);
});

// Convenience providers
final sessionsProvider = Provider<List<SessionModel>>((ref) {
  return ref.watch(sessionProvider).sessions;
});

final currentSessionProvider = Provider<SessionModel?>((ref) {
  return ref.watch(sessionProvider).currentSession;
});
