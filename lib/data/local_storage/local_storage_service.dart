import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:convert';

// Import models
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/mood_model.dart';
import '../models/achievement_model.dart';
import '../models/music_track_model.dart';

/// 🌿 Nature-themed local storage service for Mindfulness Garden
/// Provides persistent storage with gardening/nature themed operations
class LocalStorageService {
  // Box names with nature themes
  static const String _userBox = 'garden_user_seeds';
  static const String _sessionsBox = 'meditation_blooms';
  static const String _moodsBox = 'emotional_harmony';
  static const String _achievementsBox = 'garden_achievements';
  static const String _musicBox = 'nature_symphony';
  static const String _settingsBox = 'garden_settings';
  static const String _appStateBox = 'garden_state';

  // Box references
  static late Box<UserModel> _userBoxInstance;
  static late Box<SessionModel> _sessionsBoxInstance;
  static late Box<MoodModel> _moodsBoxInstance;
  static late Box<AchievementModel> _achievementsBoxInstance;
  static late Box<MusicTrackModel> _musicBoxInstance;
  static late Box _settingsBoxInstance;
  static late Box _appStateBoxInstance;

  // Initialization flags
  static bool _isInitialized = false;
  static bool _isInitializing = false;

  /// 🌱 Initialize the garden storage system
  static Future<void> init() async {
    if (_isInitialized || _isInitializing) return;

    _isInitializing = true;

    try {
      if (kDebugMode) {
        print('🌱 Planting storage seeds...');
      }

      // Get application documents directory
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Initialize Hive with custom path
      Hive.init(appDocumentDir.path);

      // Register adapters with unique typeIds
      await _registerAdapters();

      // Open all boxes with recovery mechanism
      await _openAllBoxes();

      _isInitialized = true;
      _isInitializing = false;

      if (kDebugMode) {
        print('🌿 Garden storage fully bloomed!');
        print('📊 Storage Statistics:');
        print('  👤 Users: ${_userBoxInstance.length}');
        print('  🧘 Sessions: ${_sessionsBoxInstance.length}');
        print('  😊 Moods: ${_moodsBoxInstance.length}');
        print('  🏆 Achievements: ${_achievementsBoxInstance.length}');
        print('  📍 Storage Path: ${appDocumentDir.path}');
      }

      // Perform initial compaction if needed
      if (_sessionsBoxInstance.length > 50) {
        await compactBoxes();
      }
    } catch (error, stackTrace) {
      _isInitializing = false;

      if (kDebugMode) {
        print('❌ Failed to cultivate garden storage: $error');
        print('📝 Stack trace: $stackTrace');
      }

      // Try emergency initialization
      await _emergencyInit();
    }
  }

  /// 🌼 Register all Hive adapters for our garden models
  static Future<void> _registerAdapters() async {
    try {
      // User Model (typeId: 1)
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      // Session Model (typeId: 2)
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SessionModelAdapter());
      }

      // Mood Model (typeId: 3)
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(MoodModelAdapter());
      }

      // Achievement Model (typeId: 4)
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(AchievementModelAdapter());
      }

      // Music Track Model (typeId: 6)
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(MusicTrackModelAdapter());
      }

      // Note: ChallengeModel and CommunityChallengeModel adapters are not registered
      // because they might not exist or be needed yet
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Some adapters could not be registered: $error');
      }
    }
  }

  /// 🌻 Open all storage boxes with graceful error handling
  static Future<void> _openAllBoxes() async {
    try {
      final futures = [
        _openBoxWithRecovery<UserModel>(_userBox)
            .then((box) => _userBoxInstance = box),
        _openBoxWithRecovery<SessionModel>(_sessionsBox)
            .then((box) => _sessionsBoxInstance = box),
        _openBoxWithRecovery<MoodModel>(_moodsBox)
            .then((box) => _moodsBoxInstance = box),
        _openBoxWithRecovery<AchievementModel>(_achievementsBox)
            .then((box) => _achievementsBoxInstance = box),
        _openBoxWithRecovery<MusicTrackModel>(_musicBox)
            .then((box) => _musicBoxInstance = box),
        _openUntypedBoxWithRecovery(_settingsBox)
            .then((box) => _settingsBoxInstance = box),
        _openUntypedBoxWithRecovery(_appStateBox)
            .then((box) => _appStateBoxInstance = box),
      ];

      await Future.wait(futures);
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Error opening boxes: $error');
      }
      throw Exception('Failed to open garden storage boxes');
    }
  }

  /// 🍃 Open a typed box with recovery mechanism
  static Future<Box<T>> _openBoxWithRecovery<T>(String boxName) async {
    try {
      // Check if box is already open
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<T>(boxName);
      }

      // Try normal opening
      return await Hive.openBox<T>(
        boxName,
        compactionStrategy: (entries, deletedEntries) {
          // Compact if more than 50% of entries are deleted
          return deletedEntries > 50;
        },
      );
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Box $boxName opening failed: $error');
      }

      try {
        // Try to delete corrupted box
        await Hive.deleteBoxFromDisk(boxName);

        // Open fresh box
        return await Hive.openBox<T>(boxName);
      } catch (recoveryError) {
        if (kDebugMode) {
          print('❌ Box $boxName recovery failed: $recoveryError');
        }

        // Last resort: in-memory box
        return await Hive.openBox<T>(boxName, path: null);
      }
    }
  }

  /// Open untyped box with recovery
  static Future<Box> _openUntypedBoxWithRecovery(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      }

      return await Hive.openBox(
        boxName,
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 50,
      );
    } catch (error) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
        return await Hive.openBox(boxName);
      } catch (recoveryError) {
        return await Hive.openBox(boxName, path: null);
      }
    }
  }

  /// Emergency initialization as fallback
  static Future<void> _emergencyInit() async {
    try {
      // Create in-memory boxes as fallback
      _userBoxInstance = await Hive.openBox<UserModel>('temp_user', path: null);
      _sessionsBoxInstance =
          await Hive.openBox<SessionModel>('temp_sessions', path: null);
      _moodsBoxInstance =
          await Hive.openBox<MoodModel>('temp_moods', path: null);
      _achievementsBoxInstance =
          await Hive.openBox<AchievementModel>('temp_achievements', path: null);
      _musicBoxInstance =
          await Hive.openBox<MusicTrackModel>('temp_music', path: null);
      _settingsBoxInstance = await Hive.openBox('temp_settings', path: null);
      _appStateBoxInstance = await Hive.openBox('temp_state', path: null);

      _isInitialized = true;

      if (kDebugMode) {
        print('⚠️ Emergency storage initialized (in-memory only)');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Emergency initialization failed: $error');
      }
    }
  }

  // ============= PUBLIC UTILITY METHODS =============

  /// Check if storage is ready
  static bool get isReady => _isInitialized;

  /// Get storage health status
  static Map<String, dynamic> get storageHealth {
    try {
      return {
        'initialized': _isInitialized,
        'userBox': _userBoxInstance.isOpen,
        'sessionsBox': _sessionsBoxInstance.isOpen,
        'moodsBox': _moodsBoxInstance.isOpen,
        'achievementsBox': _achievementsBoxInstance.isOpen,
        'userCount': _userBoxInstance.length,
        'sessionCount': _sessionsBoxInstance.length,
        'moodCount': _moodsBoxInstance.length,
        'achievementCount': _achievementsBoxInstance.length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// 🌷 Compact all boxes to save space
  static Future<void> compactBoxes() async {
    try {
      final boxes = [
        _userBoxInstance,
        _sessionsBoxInstance,
        _moodsBoxInstance,
        _achievementsBoxInstance,
        _musicBoxInstance,
        _settingsBoxInstance,
        _appStateBoxInstance,
      ];

      for (final box in boxes) {
        try {
          await box.compact();
        } catch (e) {
          // Ignore individual box compaction errors
        }
      }

      if (kDebugMode) {
        print('🧹 Garden storage compacted and cleaned');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Compaction failed: $error');
      }
    }
  }

  // ============= 🌿 USER GARDEN METHODS =============

  /// 🌱 Plant a new user in the garden
  static Future<void> saveUser(UserModel user) async {
    try {
      await _userBoxInstance.put('current_gardener', user);

      // Also save user ID for quick access
      await _appStateBoxInstance.put('current_user_id', user.id);

      if (kDebugMode) {
        print('👤 New gardener planted: ${user.name}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to plant gardener: $error');
        print('📝 Stack trace: $stackTrace');
      }
      throw Exception('Could not save user to garden');
    }
  }

  /// 🌻 Get the current gardener (alias for getUser)
  static UserModel? getCurrentGardener() {
    return getUser();
  }

  /// 🌻 Get the current user
  static UserModel? getUser() {
    try {
      return _userBoxInstance.get('current_gardener');
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to retrieve gardener: $error');
      }
      return null;
    }
  }

  /// 🍃 Update gardener's progress (alias for updateUser)
  static Future<void> updateGardener(UserModel user) async {
    await saveUser(user);
  }

  /// 🍃 Update user data
  static Future<void> updateUser(UserModel user) async {
    await saveUser(user);
  }

  /// 🍂 Remove gardener from the garden
  static Future<void> removeGardener() async {
    await deleteUser();
  }

  /// 🍂 Delete user
  static Future<void> deleteUser() async {
    try {
      await _userBoxInstance.delete('current_gardener');
      await _appStateBoxInstance.delete('current_user_id');

      if (kDebugMode) {
        print('👤 Gardener removed from garden');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to remove gardener: $error');
      }
    }
  }

  // ============= 🌸 MEDITATION SESSION METHODS =============

  /// 🌼 Plant a new meditation session (alias for saveSession)
  static Future<void> plantSession(SessionModel session) async {
    await saveSession(session);
  }

  /// 🌼 Save a meditation session
  static Future<void> saveSession(SessionModel session) async {
    try {
      await _sessionsBoxInstance.put(session.id, session);

      if (kDebugMode) {
        print('🧘 Meditation session saved: ${session.id}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to save session: $error');
        print('📝 Stack trace: $stackTrace');
      }
      throw Exception('Could not save meditation session');
    }
  }

  /// 🌺 Get all meditation blooms (alias for getSessions)
  static List<SessionModel> getAllBlooms() {
    return getSessions();
  }

  /// 🌺 Get all meditation sessions
  static List<SessionModel> getSessions() {
    try {
      return _sessionsBoxInstance.values.toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get sessions: $error');
      }
      return [];
    }
  }

  /// 🍀 Get today's meditation blooms (alias for getSessionsByDate)
  static List<SessionModel> getTodaysBlooms() {
    return getSessionsByDate(DateTime.now());
  }

  /// 🍀 Get sessions by date
  static List<SessionModel> getSessionsByDate(DateTime date) {
    try {
      final allSessions = getSessions();
      return allSessions.where((session) {
        return session.startTime.year == date.year &&
            session.startTime.month == date.month &&
            session.startTime.day == date.day;
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get sessions by date: $error');
      }
      return [];
    }
  }

  /// 🌸 Get meditation blooms from a growth period (alias for getSessionsFromRange)
  static List<SessionModel> getBloomsFromPeriod(DateTime start, DateTime end) {
    return getSessionsFromRange(start, end);
  }

  /// 🌸 Get sessions from period
  static List<SessionModel> getSessionsFromRange(DateTime start, DateTime end) {
    try {
      final allSessions = getSessions();
      return allSessions.where((session) {
        return session.startTime.isAfter(
              start.subtract(const Duration(days: 1)),
            ) &&
            session.startTime.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get sessions from range: $error');
      }
      return [];
    }
  }

  /// 🌱 Calculate total meditation minutes (growth time)
  static int getTotalGrowthTime() {
    return getTotalSessionMinutes();
  }

  /// 🌱 Calculate total meditation minutes
  static int getTotalSessionMinutes() {
    try {
      final sessions = getSessions();
      return sessions.fold(0, (sum, session) => sum + session.durationMinutes);
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to calculate total minutes: $error');
      }
      return 0;
    }
  }

  /// 🌿 Calculate current growth streak
  static int getCurrentGrowthStreak() {
    return getCurrentStreak();
  }

  /// 🌿 Calculate current streak
  static int getCurrentStreak() {
    try {
      final sessions = getSessions();
      if (sessions.isEmpty) return 0;

      // Get unique session dates
      final Set<String> uniqueDates = {};
      for (final session in sessions) {
        final dateKey =
            '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
        uniqueDates.add(dateKey);
      }

      // Convert to sorted list
      final List<DateTime> dates = uniqueDates.map((dateStr) {
        final parts = dateStr.split('-');
        return DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      }).toList();

      dates.sort((a, b) => b.compareTo(a));

      // Calculate streak
      DateTime currentDate = DateTime.now();
      int streak = 0;

      for (final date in dates) {
        final sessionDate = DateTime(date.year, date.month, date.day);
        final expectedDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
        );

        if (sessionDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else if (sessionDate.isBefore(expectedDate)) {
          // Check if we missed only one day
          final yesterday = expectedDate.subtract(const Duration(days: 1));
          if (sessionDate.isAtSameMomentAs(yesterday)) {
            streak++;
            currentDate = currentDate.subtract(const Duration(days: 2));
          } else {
            break;
          }
        } else {
          break;
        }
      }

      return streak;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to calculate streak: $error');
      }
      return 0;
    }
  }

  /// 🍂 Remove a withered bloom (alias for deleteSession)
  static Future<void> removeBloom(String bloomId) async {
    await deleteSession(bloomId);
  }

  /// 🍂 Delete a session
  static Future<void> deleteSession(String sessionId) async {
    try {
      await _sessionsBoxInstance.delete(sessionId);

      if (kDebugMode) {
        print('🍂 Session deleted: $sessionId');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to delete session: $error');
      }
    }
  }

  /// 🌻 Get garden bloom statistics (alias for getSessionStats)
  static Map<String, dynamic> getGardenStats() {
    return getSessionStats();
  }

  /// 🌻 Get session statistics
  static Map<String, dynamic> getSessionStats() {
    try {
      final sessions = getSessions();
      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'totalMinutes': 0,
          'avgSessionLength': 0,
          'currentStreak': 0,
          'lastSessionDate': null,
        };
      }

      final totalMinutes = getTotalSessionMinutes();
      final avgSessionLength = totalMinutes ~/ sessions.length;
      final currentStreak = getCurrentStreak();

      // Find most recent session
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      final lastSessionDate = sessions.first.startTime;

      return {
        'totalSessions': sessions.length,
        'totalMinutes': totalMinutes,
        'avgSessionLength': avgSessionLength,
        'currentStreak': currentStreak,
        'lastSessionDate': lastSessionDate,
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get session stats: $error');
      }
      return {
        'totalSessions': 0,
        'totalMinutes': 0,
        'avgSessionLength': 0,
        'currentStreak': 0,
        'lastSessionDate': null,
      };
    }
  }

  // ============= 🌈 MOOD METHODS =============

  /// 🌈 Plant an emotional bloom (alias for saveMood)
  static Future<void> plantEmotion(MoodModel emotion) async {
    await saveMood(emotion);
  }

  /// 🌈 Save a mood entry
  static Future<void> saveMood(MoodModel mood) async {
    try {
      await _moodsBoxInstance.put(mood.id, mood);

      if (kDebugMode) {
        print('😊 Mood saved: ${mood.id}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to save mood: $error');
        print('📝 Stack trace: $stackTrace');
      }
      throw Exception('Could not save mood');
    }
  }

  /// 🌸 Get today's emotional state
  static MoodModel? getTodaysEmotion() {
    return getMoodForDate(DateTime.now());
  }

  /// 🌸 Get mood for a specific date
  static MoodModel? getMoodForDate(DateTime date) {
    try {
      final allMoods = _moodsBoxInstance.values.toList();

      for (final mood in allMoods) {
        if (mood.date.year == date.year &&
            mood.date.month == date.month &&
            mood.date.day == date.day) {
          return mood;
        }
      }
      return null;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get mood for date: $error');
      }
      return null;
    }
  }

  /// 🌼 Get emotional blooms for a week
  static List<MoodModel> getWeeklyEmotions(DateTime weekStart) {
    final endDate = weekStart.add(const Duration(days: 6));
    return getMoodsFromRange(weekStart, endDate);
  }

  /// 🌼 Get moods from date range
  static List<MoodModel> getMoodsFromRange(DateTime start, DateTime end) {
    try {
      final allMoods = getAllMoods();
      return allMoods.where((mood) {
        return mood.date.isAfter(start.subtract(const Duration(days: 1))) &&
            mood.date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get moods from range: $error');
      }
      return [];
    }
  }

  /// 🌻 Get all emotional blooms (alias for getAllMoods)
  static List<MoodModel> getAllEmotions() {
    return getAllMoods();
  }

  /// 🌻 Get all moods
  static List<MoodModel> getAllMoods() {
    try {
      return _moodsBoxInstance.values.toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get all moods: $error');
      }
      return [];
    }
  }

  /// 🌿 Get emotional harmony statistics
  static Map<String, dynamic> getHarmonyStats() {
    return getMoodStats();
  }

  /// 🌿 Get mood statistics
  static Map<String, dynamic> getMoodStats() {
    try {
      final allMoods = getAllMoods();
      if (allMoods.isEmpty) {
        return {
          'totalEntries': 0,
          'avgRating': 0.0,
          'mostCommonMood': null,
          'moodDistribution': {},
        };
      }

      // Calculate average rating
      final totalRating = allMoods.fold(0.0, (sum, mood) => sum + mood.rating);
      final avgRating = totalRating / allMoods.length;

      // Find most common mood
      final moodCount = <String, int>{};
      for (final mood in allMoods) {
        moodCount[mood.mood] = (moodCount[mood.mood] ?? 0) + 1;
      }

      String? mostCommonMood;
      int maxCount = 0;
      moodCount.forEach((mood, count) {
        if (count > maxCount) {
          maxCount = count;
          mostCommonMood = mood;
        }
      });

      return {
        'totalEntries': allMoods.length,
        'avgRating': avgRating,
        'mostCommonMood': mostCommonMood,
        'moodDistribution': moodCount,
        'emotionalTrend': _calculateEmotionalTrend(allMoods),
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get mood stats: $error');
      }
      return {
        'totalEntries': 0,
        'avgRating': 0.0,
        'mostCommonMood': null,
        'moodDistribution': {},
        'emotionalTrend': 'stable',
      };
    }
  }

  /// Calculate emotional trend (improving, declining, stable)
  static String _calculateEmotionalTrend(List<MoodModel> emotions) {
    if (emotions.length < 5) return 'stable';

    // Get last 5 emotions
    final recentEmotions = emotions.sublist(math.max(0, emotions.length - 5));

    // Calculate trend
    double sum = 0;
    for (int i = 0; i < recentEmotions.length; i++) {
      sum += recentEmotions[i].rating * (i + 1);
    }

    final avgPosition =
        sum / (recentEmotions.length * (recentEmotions.length + 1) / 2);
    final avgRating = recentEmotions.fold(0.0, (sum, e) => sum + e.rating) /
        recentEmotions.length;

    if (avgPosition > avgRating * 1.2) return 'improving';
    if (avgPosition < avgRating * 0.8) return 'declining';
    return 'stable';
  }

  /// 🍂 Remove emotional bloom for a date
  static Future<void> removeEmotionForDate(DateTime date) async {
    await deleteMoodForDate(date);
  }

  /// 🍂 Delete mood for a date
  static Future<void> deleteMoodForDate(DateTime date) async {
    try {
      final mood = getMoodForDate(date);
      if (mood != null) {
        await _moodsBoxInstance.delete(mood.id);
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to delete mood: $error');
      }
    }
  }

  // ============= 🏆 ACHIEVEMENT METHODS =============

  /// 🏆 Plant a new achievement in the garden (alias for saveAchievement)
  static Future<void> plantAchievement(AchievementModel achievement) async {
    await saveAchievement(achievement);
  }

  /// 🏆 Save an achievement
  static Future<void> saveAchievement(AchievementModel achievement) async {
    try {
      await _achievementsBoxInstance.put(achievement.id, achievement);

      if (kDebugMode) {
        print('🏆 Achievement saved: ${achievement.title}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to save achievement: $error');
        print('📝 Stack trace: $stackTrace');
      }
      throw Exception('Could not save achievement');
    }
  }

  /// 🌟 Get all garden achievements
  static List<AchievementModel> getAllAchievements() {
    try {
      return _achievementsBoxInstance.values.toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get achievements: $error');
      }
      return [];
    }
  }

  /// ✨ Get unlocked achievements
  static List<AchievementModel> getUnlockedAchievements() {
    try {
      final achievements = getAllAchievements();
      return achievements
          .where((achievement) => achievement.isUnlocked)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get unlocked achievements: $error');
      }
      return [];
    }
  }

  /// 🔒 Get locked achievements
  static List<AchievementModel> getLockedAchievements() {
    try {
      final achievements = getAllAchievements();
      return achievements
          .where((achievement) => !achievement.isUnlocked)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get locked achievements: $error');
      }
      return [];
    }
  }

  /// 🎯 Get achievements by category
  static List<AchievementModel> getAchievementsByCategory(String category) {
    try {
      final achievements = getAllAchievements();
      return achievements
          .where((achievement) => achievement.category == category)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get achievements by category: $error');
      }
      return [];
    }
  }

  /// 🌟 Unlock an achievement
  static Future<void> unlockAchievement(
      String achievementId, DateTime unlockedAt) async {
    try {
      final achievement = _achievementsBoxInstance.get(achievementId);
      if (achievement != null && !achievement.isUnlocked) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: unlockedAt,
        );
        await _achievementsBoxInstance.put(achievementId, unlockedAchievement);

        if (kDebugMode) {
          print('✨ Achievement unlocked: ${achievement.title}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to unlock achievement: $error');
      }
    }
  }

  /// 📊 Get achievement statistics
  static Map<String, dynamic> getAchievementStats() {
    try {
      final achievements = getAllAchievements();
      if (achievements.isEmpty) {
        return {
          'totalAchievements': 0,
          'unlockedAchievements': 0,
          'completionPercentage': 0,
          'rarityDistribution': {},
          'categoryDistribution': {},
        };
      }

      final unlockedCount = achievements.where((a) => a.isUnlocked).length;
      final completionPercentage = (unlockedCount / achievements.length) * 100;

      // Calculate rarity distribution
      final rarityDistribution = <String, int>{};
      for (final achievement in achievements) {
        rarityDistribution[achievement.rarity] =
            (rarityDistribution[achievement.rarity] ?? 0) + 1;
      }

      // Calculate category distribution
      final categoryDistribution = <String, int>{};
      for (final achievement in achievements) {
        categoryDistribution[achievement.category] =
            (categoryDistribution[achievement.category] ?? 0) + 1;
      }

      // Get recently unlocked achievements
      final recentlyUnlocked = achievements
          .where((a) => a.isUnlocked && a.unlockedAt != null)
          .toList()
        ..sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));

      return {
        'totalAchievements': achievements.length,
        'unlockedAchievements': unlockedCount,
        'completionPercentage': completionPercentage,
        'rarityDistribution': rarityDistribution,
        'categoryDistribution': categoryDistribution,
        'recentlyUnlocked': recentlyUnlocked.take(5).toList(),
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get achievement stats: $error');
      }
      return {
        'totalAchievements': 0,
        'unlockedAchievements': 0,
        'completionPercentage': 0,
        'rarityDistribution': {},
        'categoryDistribution': {},
        'recentlyUnlocked': [],
      };
    }
  }

  // ============= 🎵 MUSIC METHODS =============

  /// 🎵 Plant a music track in the garden (alias for saveMusicTrack)
  static Future<void> plantMusicTrack(MusicTrackModel track) async {
    await saveMusicTrack(track);
  }

  /// 🎵 Save a music track
  static Future<void> saveMusicTrack(MusicTrackModel track) async {
    try {
      await _musicBoxInstance.put(track.id, track);

      if (kDebugMode) {
        print('🎵 Music track saved: ${track.title}');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ Failed to save music track: $error');
        print('📝 Stack trace: $stackTrace');
      }
      throw Exception('Could not save music track');
    }
  }

  /// 🎶 Get all nature symphonies (alias for getAllMusicTracks)
  static List<MusicTrackModel> getAllSymphonies() {
    return getAllMusicTracks();
  }

  /// 🎶 Get all music tracks
  static List<MusicTrackModel> getAllMusicTracks() {
    try {
      return _musicBoxInstance.values.toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get music tracks: $error');
      }
      return [];
    }
  }

  /// 🌿 Get music by category
  static List<MusicTrackModel> getMusicByCategory(String category) {
    try {
      final tracks = getAllMusicTracks();
      return tracks.where((track) => track.category == category).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get music by category: $error');
      }
      return [];
    }
  }

  /// 🍃 Get favorite tracks
  static List<MusicTrackModel> getFavoriteTracks() {
    try {
      final tracks = getAllMusicTracks();
      return tracks.where((track) => track.isFavorite).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get favorite tracks: $error');
      }
      return [];
    }
  }

  /// 🌼 Toggle track favorite status
  static Future<void> toggleFavoriteTrack(String trackId) async {
    try {
      final track = _musicBoxInstance.get(trackId);
      if (track != null) {
        final updatedTrack = track.copyWith(isFavorite: !track.isFavorite);
        await _musicBoxInstance.put(trackId, updatedTrack);

        if (kDebugMode) {
          print(
              '${updatedTrack.isFavorite ? '❤️' : '🤍'} Track favorite toggled: ${track.title}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to toggle favorite: $error');
      }
    }
  }

  /// 🎧 Get recently played tracks
  static List<MusicTrackModel> getRecentlyPlayed() {
    try {
      final tracks = getAllMusicTracks();
      tracks.sort(
          (a, b) => b.lastPlayed?.compareTo(a.lastPlayed ?? DateTime(0)) ?? 0);
      return tracks
          .where((track) => track.lastPlayed != null)
          .take(10)
          .toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to get recently played: $error');
      }
      return [];
    }
  }

  // ============= ⚙️ SETTINGS METHODS =============

  /// ⚙️ Save a garden setting
  static Future<void> saveSetting(String key, dynamic value) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ saveSetting called before storage initialized: $key');
      }
      return;
    }

    try {
      await _settingsBoxInstance.put(key, value);

      if (kDebugMode) {
        print('⚙️ Setting saved: $key = $value');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to save setting: $error');
      }
    }
  }

  /// 🌙 Get a garden setting
  static dynamic getSetting(String key, {dynamic defaultValue}) {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ getSetting called before storage initialized: $key');
      }
      return defaultValue;
    }

    try {
      return _settingsBoxInstance.get(key, defaultValue: defaultValue);
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to get setting: $error');
      }
      return defaultValue;
    }
  }

  /// 🌈 Get all garden settings
  static Map<String, dynamic> getAllSettings() {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ getAllSettings called before storage initialized');
      }
      return {};
    }

    try {
      final settings = <String, dynamic>{};
      for (final key in _settingsBoxInstance.keys) {
        settings[key.toString()] = _settingsBoxInstance.get(key);
      }
      return settings;
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to get all settings: $error');
      }
      return {};
    }
  }

  /// 🍂 Remove a garden setting
  static Future<void> removeSetting(String key) async {
    if (!_isInitialized) return;
    await deleteSetting(key);
  }

  /// 🍂 Delete a setting
  static Future<void> deleteSetting(String key) async {
    if (!_isInitialized) return;
    try {
      await _settingsBoxInstance.delete(key);

      if (kDebugMode) {
        print('🍂 Setting removed: $key');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Failed to remove setting: $error');
      }
    }
  }

  // ============= 📊 MAINTENANCE METHODS =============

  /// 🌸 Clear the entire garden (use with caution!)
  static Future<void> clearGarden() async {
    await clearAllData();
  }

  /// 🌸 Clear all data
  static Future<void> clearAllData() async {
    try {
      await _userBoxInstance.clear();
      await _sessionsBoxInstance.clear();
      await _moodsBoxInstance.clear();
      await _achievementsBoxInstance.clear();
      await _musicBoxInstance.clear();
      await _settingsBoxInstance.clear();
      await _appStateBoxInstance.clear();

      if (kDebugMode) {
        print('🌸 All data cleared');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to clear data: $error');
      }
    }
  }

  /// 📤 Export garden data as JSON
  static Map<String, dynamic> exportGardenData() {
    try {
      final gardener = getCurrentGardener();
      final blooms = getAllBlooms();
      final emotions = getAllEmotions();
      final achievements = getAllAchievements();
      final symphonies = getAllSymphonies();
      final settings = getAllSettings();

      return {
        'metadata': {
          'exportDate': DateTime.now().toIso8601String(),
          'appVersion': '1.0.0',
          'gardenName': 'Mindfulness Garden',
          'dataVersion': 'v1',
        },
        'gardener': gardener?.toJson(),
        'blooms': blooms.map((bloom) => bloom.toJson()).toList(),
        'emotions': emotions.map((emotion) => emotion.toJson()).toList(),
        'achievements':
            achievements.map((achievement) => achievement.toJson()).toList(),
        'symphonies': symphonies.map((track) => track.toJson()).toList(),
        'settings': settings,
        'statistics': {
          'totalGrowthTime': getTotalGrowthTime(),
          'growthStreak': getCurrentGrowthStreak(),
          'gardenStats': getGardenStats(),
          'harmonyStats': getHarmonyStats(),
          'achievementStats': getAchievementStats(),
        },
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to export data: $error');
      }
      return {'error': error.toString()};
    }
  }

  /// 📥 Import garden data from JSON
  static Future<Map<String, dynamic>> importGardenData(
      Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('📥 Importing garden data...');
      }

      int importedCount = 0;

      // Import gardener
      if (data['gardener'] != null) {
        final gardener =
            UserModel.fromJson(data['gardener'] as Map<String, dynamic>);
        await saveUser(gardener);
        importedCount++;
      }

      // Import blooms
      if (data['blooms'] is List) {
        for (final bloomData in data['blooms'] as List) {
          final bloom =
              SessionModel.fromJson(bloomData as Map<String, dynamic>);
          await saveSession(bloom);
          importedCount++;
        }
      }

      // Import emotions
      if (data['emotions'] is List) {
        for (final emotionData in data['emotions'] as List) {
          final emotion =
              MoodModel.fromJson(emotionData as Map<String, dynamic>);
          await saveMood(emotion);
          importedCount++;
        }
      }

      // Import achievements
      if (data['achievements'] is List) {
        for (final achievementData in data['achievements'] as List) {
          final achievement = AchievementModel.fromJson(
              achievementData as Map<String, dynamic>);
          await saveAchievement(achievement);
          importedCount++;
        }
      }

      // Import symphonies
      if (data['symphonies'] is List) {
        for (final trackData in data['symphonies'] as List) {
          final track =
              MusicTrackModel.fromJson(trackData as Map<String, dynamic>);
          await saveMusicTrack(track);
          importedCount++;
        }
      }

      // Import settings
      if (data['settings'] is Map) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await saveSetting(entry.key, entry.value);
          importedCount++;
        }
      }

      if (kDebugMode) {
        print('✅ Garden data imported: $importedCount items');
      }

      return {
        'success': true,
        'importedItems': importedCount,
        'message': 'Garden successfully imported',
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to import garden data: $error');
      }

      return {
        'success': false,
        'error': error.toString(),
        'message': 'Failed to import garden data',
      };
    }
  }

  /// 📊 Get comprehensive garden statistics
  static Map<String, dynamic> getComprehensiveStats() {
    try {
      return {
        'storage': {
          'userBoxSize': _userBoxInstance.length,
          'sessionsBoxSize': _sessionsBoxInstance.length,
          'moodsBoxSize': _moodsBoxInstance.length,
          'achievementsBoxSize': _achievementsBoxInstance.length,
          'musicBoxSize': _musicBoxInstance.length,
          'settingsBoxSize': _settingsBoxInstance.length,
          'appStateBoxSize': _appStateBoxInstance.length,
        },
        'gardener': getCurrentGardener()?.toJson() ?? {},
        'garden': getGardenStats(),
        'harmony': getHarmonyStats(),
        'achievements': getAchievementStats(),
        'music': {
          'totalTracks': _musicBoxInstance.length,
          'favoriteTracks': getFavoriteTracks().length,
          'recentlyPlayed': getRecentlyPlayed().length,
        },
        'timestamps': {
          'firstSession': _getFirstSessionDate(),
          'lastSession': _getLastSessionDate(),
          'firstMood': _getFirstMoodDate(),
          'lastMood': _getLastMoodDate(),
          'gardenAge': _calculateGardenAge(),
        },
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to gather comprehensive stats: $error');
      }
      return {'error': error.toString()};
    }
  }

  // Helper methods for comprehensive stats
  static DateTime? _getFirstSessionDate() {
    final blooms = getAllBlooms();
    if (blooms.isEmpty) return null;
    blooms.sort((a, b) => a.startTime.compareTo(b.startTime));
    return blooms.first.startTime;
  }

  static DateTime? _getLastSessionDate() {
    final blooms = getAllBlooms();
    if (blooms.isEmpty) return null;
    blooms.sort((a, b) => b.startTime.compareTo(a.startTime));
    return blooms.first.startTime;
  }

  static DateTime? _getFirstMoodDate() {
    final emotions = getAllEmotions();
    if (emotions.isEmpty) return null;
    emotions.sort((a, b) => a.date.compareTo(b.date));
    return emotions.first.date;
  }

  static DateTime? _getLastMoodDate() {
    final emotions = getAllEmotions();
    if (emotions.isEmpty) return null;
    emotions.sort((a, b) => b.date.compareTo(a.date));
    return emotions.first.date;
  }

  static String _calculateGardenAge() {
    final firstSession = _getFirstSessionDate();
    if (firstSession == null) return 'New Garden';

    final now = DateTime.now();
    final difference = now.difference(firstSession);

    if (difference.inDays < 1) return 'Today';
    if (difference.inDays < 7) return '${difference.inDays} days';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30} months';
    return '${difference.inDays ~/ 365} years';
  }

  /// 🔄 Create a garden backup
  static Future<Map<String, dynamic>> createBackup() async {
    try {
      final backupData = exportGardenData();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupKey = 'backup_$timestamp';

      // Save backup to app state box
      await _appStateBoxInstance.put(backupKey, json.encode(backupData));

      // Manage backup rotation (keep last 5)
      final backupKeys = _appStateBoxInstance.keys
          .where((key) => key.toString().startsWith('backup_'))
          .toList()
          .cast<String>();

      if (backupKeys.length > 5) {
        backupKeys.sort();
        for (int i = 0; i < backupKeys.length - 5; i++) {
          await _appStateBoxInstance.delete(backupKeys[i]);
        }
      }

      if (kDebugMode) {
        print('💾 Garden backup created: $backupKey');
      }

      return {
        'success': true,
        'backupKey': backupKey,
        'timestamp': timestamp,
        'size': json.encode(backupData).length,
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to create backup: $error');
      }

      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// 🔙 Restore garden from backup
  static Future<Map<String, dynamic>> restoreBackup(String backupKey) async {
    try {
      final backupData = _appStateBoxInstance.get(backupKey);
      if (backupData == null) {
        return {
          'success': false,
          'error': 'Backup not found',
        };
      }

      // Parse backup data
      final parsedData =
          json.decode(backupData as String) as Map<String, dynamic>;

      // Clear current garden
      await clearGarden();

      // Import backup data
      final result = await importGardenData(parsedData);

      if (kDebugMode) {
        print('🔙 Garden restored from backup: $backupKey');
      }

      return {
        'success': true,
        'restoredItems': result['importedItems'],
        'message': 'Garden successfully restored',
      };
    } catch (error) {
      if (kDebugMode) {
        print('❌ Failed to restore backup: $error');
      }

      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// 🏁 Close the garden storage
  static Future<void> closeGarden() async {
    try {
      // Save closing state
      await _appStateBoxInstance.put(
          'last_closed', DateTime.now().toIso8601String());

      // Close all boxes
      await _userBoxInstance.close();
      await _sessionsBoxInstance.close();
      await _moodsBoxInstance.close();
      await _achievementsBoxInstance.close();
      await _musicBoxInstance.close();
      await _settingsBoxInstance.close();
      await _appStateBoxInstance.close();

      _isInitialized = false;

      if (kDebugMode) {
        print('🏁 Garden storage closed gracefully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Error closing garden: $error');
      }
    }
  }

  /// 🌙 Perform nightly garden maintenance
  static Future<void> performNightlyMaintenance() async {
    try {
      if (kDebugMode) {
        print('🌙 Performing nightly garden maintenance...');
      }

      // Compact boxes
      await compactBoxes();

      // Clean up old sessions (keep only last 365 days)
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      final blooms = getAllBlooms();

      for (final bloom in blooms) {
        if (bloom.startTime.isBefore(oneYearAgo)) {
          await deleteSession(bloom.id);
        }
      }

      // Update garden statistics
      await _appStateBoxInstance.put(
          'last_maintenance', DateTime.now().toIso8601String());

      // Create automatic backup if 7 days have passed
      final lastBackup = _appStateBoxInstance.get('last_auto_backup');
      if (lastBackup == null ||
          DateTime.now().difference(DateTime.parse(lastBackup)).inDays >= 7) {
        await createBackup();
        await _appStateBoxInstance.put(
            'last_auto_backup', DateTime.now().toIso8601String());
      }

      if (kDebugMode) {
        print('✅ Nightly maintenance completed');
      }
    } catch (error) {
      if (kDebugMode) {
        print('⚠️ Nightly maintenance failed: $error');
      }
    }
  }
}
