import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/repositories/user_repository.dart';

// User State
class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// User StateNotifier
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState());

  // Getters for convenience
  UserModel? get user => state.user;
  bool get isLoading => state.isLoading;
  String? get error => state.error;
  String get userName => state.user?.name ?? 'Mindful Gardener';
  int get currentStreak => state.user?.currentStreak ?? 0;
  int get totalMinutes => state.user?.totalMinutes ?? 0;
  int get totalSessions => state.user?.totalSessions ?? 0;
  int get gardenLevel => state.user?.gardenLevel ?? 1;
  DateTime? get lastSessionDate => state.user?.lastSessionDate;
  bool get hasUser => state.user != null;

  // Load User
  Future<void> loadUser() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await _repository.getCurrentUser();

      if (user == null) {
        await createDefaultUser();
      } else {
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create Default User
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

      await _repository.saveUser(newUser);
      state = state.copyWith(user: newUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update Entire User
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _repository.saveUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Meditation Session Logic
  Future<void> addSession(int minutes) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      totalSessions: state.user!.totalSessions + 1,
      totalMinutes: state.user!.totalMinutes + minutes,
      lastSessionDate: DateTime.now(),
      currentStreak: _calculateUpdatedStreak(),
    );

    await updateUser(updatedUser);
  }

  // Streak Logic
  int _calculateUpdatedStreak() {
    if (state.user == null) return 0;

    final now = DateTime.now();
    final lastDate = state.user!.lastSessionDate;

    if (lastDate == null) return 1;

    final difference = now.difference(lastDate).inDays;

    if (difference == 0) {
      return state.user!.currentStreak;
    } else if (difference == 1) {
      return state.user!.currentStreak + 1;
    } else {
      return 1;
    }
  }

  Future<void> updateStreak(int streak) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      currentStreak: streak,
    );

    await updateUser(updatedUser);
  }

  // Garden Progression
  Future<void> levelUpGarden() async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      gardenLevel: state.user!.gardenLevel + 1,
    );

    await updateUser(updatedUser);
  }

  // Profile Updates
  Future<void> updateName(String name) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      name: name,
    );

    await updateUser(updatedUser);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    if (state.user == null) return;

    final updatedUser = state.user!.copyWith(
      preferences: preferences,
    );

    await updateUser(updatedUser);
  }

  // Logout / Reset
  Future<void> clearUser() async {
    state = state.copyWith(user: null);
  }
}

// Providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});

// Convenience providers
final userDataProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProvider).user;
});

final userNameProvider = Provider<String>((ref) {
  return ref.watch(userProvider).userName;
});

final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(userProvider).currentStreak;
});

final totalMinutesProvider = Provider<int>((ref) {
  return ref.watch(userProvider).totalMinutes;
});

final totalSessionsProvider = Provider<int>((ref) {
  return ref.watch(userProvider).totalSessions;
});

final gardenLevelProvider = Provider<int>((ref) {
  return ref.watch(userProvider).gardenLevel;
});
