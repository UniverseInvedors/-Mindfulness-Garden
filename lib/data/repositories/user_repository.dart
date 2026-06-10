import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';
import 'package:mindfulness_garden/data/models/user_model.dart';
import 'package:mindfulness_garden/data/services/firestore_progress_service.dart';

class UserRepository {
  final FirestoreProgressService _progressService;

  UserRepository({FirestoreProgressService? progressService})
      : _progressService = progressService ?? FirestoreProgressService.instance;

  Future<UserModel?> getCurrentUser() async {
    return LocalStorageService.getUser();
  }

  Future<void> saveUser(UserModel user) async {
    await LocalStorageService.saveUser(user);
    await _syncUserProgress(user);
  }

  Future<void> updateUser({
    int? totalSessions,
    int? totalMinutes,
    int? gardenLevel,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        totalSessions: totalSessions ?? currentUser.totalSessions,
        totalMinutes: totalMinutes ?? currentUser.totalMinutes,
        gardenLevel: gardenLevel ?? currentUser.gardenLevel,
        lastSessionDate: DateTime.now(),
      );
      await LocalStorageService.updateUser(updatedUser);
      await _syncUserProgress(updatedUser);
    }
  }

  Future<void> _syncUserProgress(UserModel user) async {
    try {
      await _progressService.syncUserProgress(user);
    } catch (_) {
      // Firestore sync is optional and should not block local progress.
    }
  }

  Future<int> getCurrentStreak() async {
    return LocalStorageService.getCurrentStreak();
  }

  Future<int> getTotalMinutes() async {
    return LocalStorageService.getTotalSessionMinutes();
  }

  Future<void> completeSession(int durationMinutes) async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final totalMinutes = await getTotalMinutes();

      // Calculate garden level (1 level per 60 minutes)
      final newGardenLevel = ((totalMinutes + durationMinutes) ~/ 60) + 1;

      await updateUser(
        totalSessions: currentUser.totalSessions + 1,
        totalMinutes: totalMinutes + durationMinutes,
        gardenLevel: newGardenLevel,
      );
    }
  }
}
