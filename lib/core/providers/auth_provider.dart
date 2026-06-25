import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/services/auth_service.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';

// Auth State
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isEmailVerified;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isEmailVerified = true, // Backend assumes verified
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isEmailVerified,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

// Auth StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initialize();
  }

  // Getters
  UserModel? get user => state.user;
  bool get isLoading => state.isLoading;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentUserId => _authService.currentUserId;

  // Initialize auth state listener
  void _initialize() {
    _authService.authStateChanges.listen((userId) async {
      if (userId != null) {
        // Load user from local storage or create default
        UserModel? userModel = await LocalStorageService.getUser();
        if (userModel == null) {
          userModel = AuthService.userModelFromBackendUser(userId, 'User');
        }

        await LocalStorageService.saveUser(userModel);

        state = state.copyWith(
          user: userModel,
          isEmailVerified: true,
        );
      } else {
        await LocalStorageService.deleteUser();

        state = state.copyWith(
          user: null,
          isEmailVerified: false,
        );
      }
    });
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (success) {
        final userModel = AuthService.userModelFromBackendUser(email, displayName);
        await LocalStorageService.saveUser(userModel);
        state = state.copyWith(user: userModel, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.signIn(
        email: email,
        password: password,
      );

      if (success) {
        final userModel = AuthService.userModelFromBackendUser(email, email.split('@')[0]);
        await LocalStorageService.saveUser(userModel);
        state = state.copyWith(user: userModel, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.signOut();
      state = state.copyWith(
        user: null,
        isEmailVerified: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      if (displayName != null && state.user != null) {
        final updatedUser = state.user!.copyWith(name: displayName);
        await LocalStorageService.saveUser(updatedUser);
        state = state.copyWith(user: updatedUser);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.deleteAccount();
      state = state.copyWith(
        user: null,
        isEmailVerified: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      UserModel? userModel = await LocalStorageService.getUser();
      if (userModel != null) {
        await LocalStorageService.saveUser(userModel);
        state = state.copyWith(
          user: userModel,
          isEmailVerified: true,
        );
      }
    }
  }

  // Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(service);
});

// Convenience providers
final authUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});
