import 'package:flutter/material.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // =========================
  // Getters
  // =========================

  UserModel? get user => _user;

  /// Alias for compatibility with UI (friends_screen)
  UserModel? get currentUser => _user;

  bool get isLoading => _isLoading;

  String? get error => _error;

  // =========================
  // Computed Properties
  // =========================

  String get userName => _user?.name ?? 'Mindful Gardener';

  int get currentStreak => _user?.currentStreak ?? 0;

  int get totalMinutes => _user?.totalMinutes ?? 0;

  int get totalSessions => _user?.totalSessions ?? 0;

  int get gardenLevel => _user?.gardenLevel ?? 1;

  DateTime? get lastSessionDate => _user?.lastSessionDate;

  bool get hasUser => _user != null;

  // =========================
  // Load User
  // =========================

  Future<void> loadUser() async {
    try {
      _setLoading(true);

      _user = await _repository.getCurrentUser();

      if (_user == null) {
        await createDefaultUser();
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // =========================
  // Create Default User
  // =========================

  Future<void> createDefaultUser() async {
    try {
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Mindful Gardener',
        email: '',
        joinedDate: DateTime.now(),
        totalSessions: 0,
        totalMinutes: 0,
        currentStreak: 0,
        gardenLevel: 1,
        lastSessionDate: null,
        achievements: [],
        preferences: UserPreferences(
          theme: 'nature',
          notifications: true,
          sounds: true,
          vibration: true,
        ),
      );

      _user = newUser;
      await _repository.saveUser(newUser);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // =========================
  // Update Entire User
  // =========================

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _user = updatedUser;
      await _repository.saveUser(updatedUser);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // =========================
  // Meditation Session Logic
  // =========================

  Future<void> addSession(int minutes) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      totalSessions: _user!.totalSessions + 1,
      totalMinutes: _user!.totalMinutes + minutes,
      lastSessionDate: DateTime.now(),
      currentStreak: _calculateUpdatedStreak(),
    );

    await updateUser(updatedUser);
  }

  // =========================
  // Streak Logic
  // =========================

  int _calculateUpdatedStreak() {
    if (_user == null) return 0;

    final now = DateTime.now();
    final lastDate = _user!.lastSessionDate;

    if (lastDate == null) return 1;

    final difference = now.difference(lastDate).inDays;

    if (difference == 0) {
      // Same day session
      return _user!.currentStreak;
    } else if (difference == 1) {
      // Consecutive day
      return _user!.currentStreak + 1;
    } else {
      // Streak broken
      return 1;
    }
  }

  Future<void> updateStreak(int streak) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      currentStreak: streak,
    );

    await updateUser(updatedUser);
  }

  // =========================
  // Garden Progression
  // =========================

  Future<void> levelUpGarden() async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      gardenLevel: _user!.gardenLevel + 1,
    );

    await updateUser(updatedUser);
  }

  // =========================
  // Profile Updates
  // =========================

  Future<void> updateName(String name) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      name: name,
    );

    await updateUser(updatedUser);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      preferences: preferences,
    );

    await updateUser(updatedUser);
  }

  // =========================
  // Logout / Reset
  // =========================

  Future<void> clearUser() async {
    _user = null;
    notifyListeners();
  }

  // =========================
  // Private Helpers
  // =========================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }
}
