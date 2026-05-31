import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';
import 'package:mindfulness_garden/data/models/mood_model.dart';

class MoodRepository {
  final Uuid _uuid = const Uuid();

  /// ✅ Create / Save new mood
  Future<MoodModel> saveMood({
    required String mood,
    required int rating,
    String? note,
    List<String> tags = const [],
    DateTime? date,
  }) async {
    final moodModel = MoodModel(
      id: _uuid.v4(),
      date: date ?? DateTime.now(),
      mood: mood,
      rating: rating.toDouble(),
      note: note,
      tags: tags,
    );

    await LocalStorageService.saveMood(moodModel);
    return moodModel;
  }

  /// ✅ Update mood (overwrite same id)
  Future<void> updateMood(MoodModel mood) async {
    await LocalStorageService.saveMood(mood);
  }

  /// ✅ Delete mood by id
  Future<void> deleteMoodById(String id) async {
    try {
      // LocalStorageService এর public delete method নেই mood id দিয়ে,
      // তাই এখানে Hive box এ direct delete না করে
      // safest approach: mood list থেকে find করে date based delete
      final moods = await getAllMoods();
      final target = moods.where((m) => m.id == id).toList();
      if (target.isNotEmpty) {
        await LocalStorageService.deleteMoodForDate(target.first.date);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ deleteMoodById error: $e");
      }
    }
  }

  /// ✅ Delete mood for a specific date
  Future<void> deleteMoodForDate(DateTime date) async {
    await LocalStorageService.deleteMoodForDate(date);
  }

  /// ✅ Get mood entry for a date
  Future<MoodModel?> getMoodForDate(DateTime date) async {
    return LocalStorageService.getMoodForDate(date);
  }

  /// ✅ Get today's mood
  Future<MoodModel?> getTodaysMood() async {
    return LocalStorageService.getMoodForDate(DateTime.now());
  }

  /// ✅ Get all moods (sorted latest first)
  Future<List<MoodModel>> getAllMoods() async {
    final moods = LocalStorageService.getAllMoods();
    moods.sort((a, b) => b.date.compareTo(a.date));
    return moods;
  }

  /// ✅ Get moods between two dates (inclusive)
  Future<List<MoodModel>> getMoodsBetween(DateTime start, DateTime end) async {
    final moods = LocalStorageService.getMoodsFromRange(start, end);
    moods.sort((a, b) => b.date.compareTo(a.date));
    return moods;
  }

  /// ✅ Recent moods
  Future<List<MoodModel>> getRecentMoods({int limit = 30}) async {
    final all = await getAllMoods();
    return all.take(limit).toList();
  }

  /// ✅ Mood trends (weekly average rating)
  /// Output list will contain MoodModel objects with:
  /// mood = "Average", rating = weekly avg, date = week start date
  Future<List<MoodModel>> getMoodTrends({int recentDays = 90}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: recentDays));

    final moods = await getMoodsBetween(start, now);
    if (moods.isEmpty) return [];

    final Map<String, List<MoodModel>> weeklyMoods = {};

    for (final mood in moods) {
      final weekKey = '${mood.date.year}-${mood.date.weekOfYear}';
      weeklyMoods.putIfAbsent(weekKey, () => []).add(mood);
    }

    final List<MoodModel> trends = [];

    for (final entry in weeklyMoods.entries) {
      final moodsInWeek = entry.value;
      if (moodsInWeek.isEmpty) continue;

      moodsInWeek.sort((a, b) => a.date.compareTo(b.date));

      final totalRating =
      moodsInWeek.map((m) => m.rating).reduce((a, b) => a + b);
      final avgRating = totalRating / moodsInWeek.length;

      final firstMood = moodsInWeek.first;

      trends.add(
        MoodModel(
          id: entry.key,
          date: firstMood.date,
          mood: "Average",
          rating: avgRating,
          note: "Weekly average mood",
          tags: const [],
        ),
      );
    }

    trends.sort((a, b) => a.date.compareTo(b.date));
    return trends;
  }

  /// ✅ Mood statistics summary
  Future<Map<String, dynamic>> getMoodStats() async {
    final moods = await getAllMoods();
    if (moods.isEmpty) {
      return {
        "totalEntries": 0,
        "avgRating": 0.0,
        "mostCommonMood": null,
        "moodDistribution": <String, int>{},
        "trend": "stable",
      };
    }

    // Average rating
    final avgRating =
        moods.fold<double>(0, (sum, m) => sum + m.rating) / moods.length;

    // Distribution
    final Map<String, int> moodCount = {};
    for (final mood in moods) {
      moodCount[mood.mood] = (moodCount[mood.mood] ?? 0) + 1;
    }

    // Most common mood
    String? mostCommonMood;
    int maxCount = 0;
    moodCount.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMood = mood;
      }
    });

    // Trend (based on last 7 vs previous 7)
    final trend = _calculateTrend(moods);

    return {
      "totalEntries": moods.length,
      "avgRating": avgRating,
      "mostCommonMood": mostCommonMood,
      "moodDistribution": moodCount,
      "trend": trend,
    };
  }

  /// ✅ Get mood average for last N days
  Future<double> getAverageMoodLastDays(int days) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));

    final moods = await getMoodsBetween(start, now);
    if (moods.isEmpty) return 0;

    final avg =
        moods.fold<double>(0, (sum, m) => sum + m.rating) / moods.length;
    return avg;
  }

  /// ✅ Helper: calculate improving/declining/stable
  String _calculateTrend(List<MoodModel> moods) {
    // Sort oldest → newest
    final sorted = moods.toList()..sort((a, b) => a.date.compareTo(b.date));

    final last14 = sorted.length > 14 ? sorted.sublist(sorted.length - 14) : sorted;

    if (last14.length < 7) return "stable";

    final first7 = last14.sublist(0, 7);
    final last7 = last14.sublist(last14.length - 7);

    final firstAvg =
        first7.fold<double>(0, (sum, m) => sum + m.rating) / first7.length;
    final lastAvg =
        last7.fold<double>(0, (sum, m) => sum + m.rating) / last7.length;

    final diff = lastAvg - firstAvg;

    if (diff > 0.25) return "improving";
    if (diff < -0.25) return "declining";
    return "stable";
  }
}

/// ✅ Date extension: weekOfYear + helpers
extension DateExtension on DateTime {
  int get weekOfYear {
    final woy = ((ordinalDate - weekday + 10) ~/ 7);
    if (woy == 0) {
      return DateTime(year - 1, 12, 28).weekOfYear;
    }
    return woy;
  }

  int get ordinalDate {
    const List<int> offsets = [
      0,
      31,
      59,
      90,
      120,
      151,
      181,
      212,
      243,
      273,
      304,
      334,
    ];
    return offsets[month - 1] + day + (isLeapYear && month > 2 ? 1 : 0);
  }

  bool get isLeapYear {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  /// ✅ Check same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
