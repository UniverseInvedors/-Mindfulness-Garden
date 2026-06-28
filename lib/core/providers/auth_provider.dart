// lib/core/providers/auth_provider.dart
//
// Riverpod auth state — backed by Firebase Auth via AuthService.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/services/auth_service.dart';
import 'package:pranaverse/core/services/analytics_service.dart';
import 'package:pranaverse/core/services/firestore_service.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isEmailVerified;
  final bool awaitingOtp; // phone OTP flow active
  final String? pendingPhone; // phone number waiting for OTP

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isEmailVerified = false,
    this.awaitingOtp = false,
    this.pendingPhone,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isEmailVerified,
    bool? awaitingOtp,
    String? pendingPhone,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      awaitingOtp: awaitingOtp ?? this.awaitingOtp,
      pendingPhone: pendingPhone ?? this.pendingPhone,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _auth;
  final FirestoreService _firestore;
  final AnalyticsService _analytics;

  // Holds the verificationId received from Firebase after sendPhoneOtp
  String? _phoneVerificationId;

  AuthNotifier(this._auth, this._firestore, this._analytics)
      : super(const AuthState()) {
    _listenToAuthChanges();
  }

  // ─── Internal ───────────────────────────────────────────────────────────

  void _listenToAuthChanges() {
    _auth.authStateChanges.listen((uid) async {
      if (uid == null) {
        state = const AuthState(); // signed out
        return;
      }
      // Try to load cached user first for instant UI
      UserModel? cached = LocalStorageService.getUser();
      if (cached != null) {
        state = AuthState(
          user: cached,
          isEmailVerified: _auth.isEmailVerified,
        );
      }
      // Then sync from Firestore
      await _syncUserFromFirestore(uid);
    });
  }

  Future<void> _syncUserFromFirestore(String uid) async {
    try {
      final remoteData = await _firestore.getUser(uid);
      UserModel userModel;

      if (remoteData != null) {
        userModel = UserModel(
          id: uid,
          name: remoteData['name'] as String? ??
              _auth.currentDisplayName ??
              'User',
          email: remoteData['email'] as String? ?? _auth.currentEmail ?? '',
          joinedDate:
              DateTime.tryParse(remoteData['joinedAt'] as String? ?? '') ??
                  DateTime.now(),
          totalSessions: remoteData['totalSessions'] as int? ?? 0,
          totalMinutes: remoteData['totalMinutes'] as int? ?? 0,
          currentStreak: remoteData['currentStreak'] as int? ?? 0,
          gardenLevel: remoteData['gardenLevel'] as int? ?? 1,
          lastSessionDate: null,
          achievements: const [],
          preferences: UserPreferences(
            theme: 'nature',
            notifications: true,
            sounds: true,
            vibration: true,
          ),
        );
      } else {
        userModel = _auth.buildUserModel();
        await _firestore.createOrUpdateUser(userModel);
      }

      await LocalStorageService.saveUser(userModel);
      await _analytics.setUserId(uid);

      state = AuthState(
        user: userModel,
        isEmailVerified: _auth.isEmailVerified,
      );
    } catch (e) {
      // Fall back to local cache if Firestore fails
      final cached = LocalStorageService.getUser();
      state = AuthState(
        user: cached ?? _auth.buildUserModel(),
        isEmailVerified: _auth.isEmailVerified,
      );
    }
  }

  void _setLoading() =>
      state = state.copyWith(isLoading: true, clearError: true);
  void _setError(Object e) =>
      state = state.copyWith(isLoading: false, error: e.toString());

  // ─── Email / password ────────────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      await _auth.signUp(
          email: email, password: password, displayName: displayName);
      // _listenToAuthChanges will pick up the new user automatically.
      // Email verification was sent inside AuthService.signUp.
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      await _auth.signIn(email: email, password: password);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _setError(e);
    }
  }

  // ─── Google Sign-In (auto sign-up for new users) ────────────────────────

  Future<void> signInWithGoogle() async {
    _setLoading();
    try {
      final result = await _auth.signInWithGoogle();
      if (result == null) {
        // User cancelled — not an error, just stop loading
        state = state.copyWith(isLoading: false);
        return;
      }
      // For new users, Firestore doc will be created by _listenToAuthChanges
      // via _syncUserFromFirestore. Nothing extra needed here.
      state = state.copyWith(
        isLoading: false,
        isEmailVerified: true, // Google accounts are always verified
      );
    } catch (e) {
      _setError(e);
    }
  }

  // ─── Phone OTP ───────────────────────────────────────────────────────────

  Future<void> sendPhoneOtp({required String phoneNumber}) async {
    _setLoading();
    try {
      await _auth.sendPhoneOtp(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId, _) {
          _phoneVerificationId = verificationId;
          state = state.copyWith(
            isLoading: false,
            awaitingOtp: true,
            pendingPhone: phoneNumber,
          );
        },
        onFailed: (msg) {
          _setError(Exception(msg));
        },
        onAutoVerified: (_) {
          // auto-verified on Android — auth stream picks it up
          state = state.copyWith(isLoading: false, awaitingOtp: false);
        },
      );
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    _setLoading();
    try {
      await _auth.verifyOtp(
        verificationId: _phoneVerificationId ?? '',
        otp: otp,
      );
      state = state.copyWith(isLoading: false, awaitingOtp: false);
    } catch (e) {
      _setError(e);
    }
  }

  // ─── Email verification ──────────────────────────────────────────────────

  Future<void> sendEmailVerification() async {
    try {
      await _auth.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Poll Firebase to check if email is now verified.
  Future<void> checkEmailVerification() async {
    await _auth.reloadUser();
    if (_auth.isEmailVerified && state.user != null) {
      state = state.copyWith(isEmailVerified: true);
    }
  }

  // ─── Password reset ──────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) async {
    _setLoading();
    try {
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      _setError(e);
    }
  }

  // ─── Profile update ──────────────────────────────────────────────────────

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _auth.updateProfile(displayName: displayName, photoUrl: photoUrl);
      if (displayName != null && state.user != null) {
        final updated = state.user!.copyWith(name: displayName);
        await LocalStorageService.saveUser(updated);
        await _firestore.createOrUpdateUser(updated);
        state = state.copyWith(user: updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // ─── Sign out / delete ───────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading();
    try {
      await _auth.signOut();
      state = const AuthState();
    } catch (e) {
      _setError(e);
    }
  }

  Future<void> deleteAccount() async {
    _setLoading();
    try {
      await _auth.deleteAccount();
      state = const AuthState();
    } catch (e) {
      _setError(e);
    }
  }

  // ─── Utils ───────────────────────────────────────────────────────────────

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Providers ────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(firestoreServiceProvider),
    ref.read(analyticsServiceProvider),
  );
});

// Convenience selectors
final authUserProvider =
    Provider<UserModel?>((ref) => ref.watch(authProvider).user);

final isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(authProvider).isAuthenticated);

final isEmailVerifiedProvider =
    Provider<bool>((ref) => ref.watch(authProvider).isEmailVerified);
