import 'package:uuid/uuid.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/data/models/session_model.dart';

class SessionRepository {
  final Uuid _uuid = const Uuid();

  Future<void> saveSession({
    required int durationMinutes,
    required String meditationType,
    String? focusArea,
    String? moodBefore,
    String? moodAfter,
    String? notes,
    List<String> soundsUsed = const [],
  }) async {
    final session = SessionModel(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      meditationType: meditationType,
      focusArea: focusArea ?? '',
      moodBefore: moodBefore ?? '',
      moodAfter: moodAfter ?? '',
      notes: notes ?? '',
      soundsUsed: soundsUsed,
    );

    await LocalStorageService.saveSession(session);
  }

  Future<List<SessionModel>> getRecentSessions({int limit = 10}) async {
    final allSessions = LocalStorageService.getSessions();
    allSessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allSessions.take(limit).toList();
  }

  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    return LocalStorageService.getSessionsByDate(date);
  }

  Future<Map<String, int>> getSessionStats() async {
    final sessions = LocalStorageService.getSessions();

    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'avgSessionLength': 0,
        'currentStreak': 0,
      };
    }

    final totalMinutes = sessions.fold(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final avgSessionLength = totalMinutes ~/ sessions.length;
    final currentStreak = LocalStorageService.getCurrentStreak();

    return {
      'totalSessions': sessions.length,
      'totalMinutes': totalMinutes,
      'avgSessionLength': avgSessionLength,
      'currentStreak': currentStreak,
    };
  }

  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final weeklyMinutes = <String, int>{};

    // Initialize all days
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      weeklyMinutes[dayName] = 0;
    }

    // Fill with actual data
    final allSessions = LocalStorageService.getSessions();
    for (final session in allSessions) {
      if (session.startTime.isAfter(
        startOfWeek.subtract(const Duration(days: 1)),
      )) {
        final dayName = _getDayName(session.startTime.weekday);
        weeklyMinutes[dayName] =
            (weeklyMinutes[dayName] ?? 0) + session.durationMinutes;
      }
    }

    return {
      'weeklyMinutes': weeklyMinutes,
      'totalMinutes': weeklyMinutes.values.fold(
        0,
        (sum, minutes) => sum + minutes,
      ),
    };
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
