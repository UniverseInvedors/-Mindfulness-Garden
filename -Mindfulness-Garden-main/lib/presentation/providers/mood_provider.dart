import 'package:flutter/foundation.dart';
import 'package:pranaverse/data/models/mood_model.dart';
import 'package:pranaverse/data/repositories/mood_repository.dart';

class MoodProvider with ChangeNotifier {
  final MoodRepository _moodRepository = MoodRepository();
  MoodModel? _todayMood;
  List<MoodModel> _recentMoods = [];
  bool _isLoading = false;

  MoodModel? get todayMood => _todayMood;
  List<MoodModel> get recentMoods => _recentMoods;
  bool get isLoading => _isLoading;

  Future<void> loadTodayMood() async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayMood = await _moodRepository.getMoodForDate(DateTime.now());
    } catch (e) {
      if (kDebugMode) {
        print('Error loading today\'s mood: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentMoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recentMoods = await _moodRepository.getRecentMoods();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recent moods: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMood({
    required String mood,
    required int rating,
    String? note,
    List<String> tags = const [],
  }) async {
    try {
      await _moodRepository.saveMood(
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
    }
  }

  Future<List<MoodModel>> getMoodTrends() async {
    return await _moodRepository.getMoodTrends();
  }

  void setTodayMood(String mood) {
    if (_todayMood != null) {
      _todayMood = _todayMood!.copyWith(mood: mood);
    } else {
      _todayMood = MoodModel(
        id: DateTime.now().toIso8601String(),
        date: DateTime.now(),
        mood: mood,
        rating: 3,
      );
    }
    notifyListeners();
  }
}
