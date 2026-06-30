// lib/presentation/providers/auth_provider.dart
//
// ChangeNotifier-based auth provider consumed by widget-tree via Provider.
// Delegates all Firebase operations to AuthService and syncs with Firestore.

import 'package:flutter/material.dart';
import 'package:pranaverse/core/services/auth_service.dart';
import 'package:pranaverse/core/services/firestore_service.dart';
import 'package:pranaverse/core/services/analytics_service.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/core/config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();
  final AnalyticsService _analytics = AnalyticsService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;
  bool _awaitingOtp = false;
  String? _pendingPhone;
  String? _phoneVerificationId;
  bool _linkOtpToCurrentUser = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _isEmailVerified;
  bool get awaitingOtp => _awaitingOtp;
  String? get pendingPhone => _pendingPhone;
  bool get isLinkingPhone => _linkOtpToCurrentUser;
  String? get currentUserId => _authService.currentUserId;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((uid) async {
      if (uid == null) {
        _user = null;
        _isEmailVerified = false;
        if (!_isLoading) notifyListeners();
        return;
      }
      // Instant UI from cache
      _user = LocalStorageService.getUser();
      _isEmailVerified = _authService.isEmailVerified;
      if (!_isLoading) notifyListeners();

      // Sync from Firestore in background
      await _syncUserFromFirestore(uid);
    });
  }

  Future<void> _syncUserFromFirestore(String uid) async {
    try {
      final remoteData = await _firestore.getUser(uid);
      if (remoteData != null) {
        _user = UserModel(
          id: uid,
          name: remoteData['name'] as String? ??
              _authService.currentDisplayName ??
              'User',
          email:
              remoteData['email'] as String? ?? _authService.currentEmail ?? '',
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
        _user = _authService.buildUserModel();
        await _firestore.createOrUpdateUser(_user!);
      }
      await LocalStorageService.saveUser(_user!);
      await _analytics.setUserId(uid);
      _isEmailVerified = _authService.isEmailVerified;
      notifyListeners();
    } catch (_) {
      // keep cached user
      notifyListeners();
    }
  }

  // ─── Email / password ──────────────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    _setLoading(true);
    try {
      final cred = await _authService.signUp(
          email: email, password: password, displayName: displayName);

      if (kDevelopmentAuthMode) {
        // Development mode: do not send OTP or email verification.
        // Create a lightweight Firestore user record and cache locally.
        _user = _authService.buildUserModel();
        try {
          await _firestore.createDevelopmentUser(_user!, phone: phoneNumber);
          await LocalStorageService.saveUser(_user!);
        } catch (e) {
          // ignore failure here; we'll still proceed to sign-in
        }
        _isEmailVerified = false;
        _awaitingOtp = false;
        _linkOtpToCurrentUser = false;
        _phoneVerificationId = null;
        _pendingPhone = null;
        _setLoading(false);
        return;
      }

      // Production flow: may link phone and send OTP as before
      await _primeCurrentUser();

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        _linkOtpToCurrentUser = true;
        _pendingPhone = phoneNumber;
        await _authService.sendPhoneOtp(
          phoneNumber: phoneNumber,
          linkToCurrentUser: true,
          onCodeSent: (verificationId, _) {
            _phoneVerificationId = verificationId;
            _awaitingOtp = true;
            _setLoading(false);
          },
          onFailed: (msg) => _setError(_cleanAuthError(msg)),
          onAutoVerified: (_) async {
            await _markPhoneVerified(phoneNumber);
            _awaitingOtp = false;
            _linkOtpToCurrentUser = false;
            _phoneVerificationId = null;
            _setLoading(false);
          },
        );
      } else {
        _setLoading(false);
      }
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      await _primeCurrentUser();
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Google Sign-In (auto sign-up for new users) ─────────────────────────

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        // Cancelled by user
        _setLoading(false);
        return;
      }
      // Google accounts are always email-verified
      _isEmailVerified = true;
      await _primeCurrentUser();
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Phone OTP ────────────────────────────────────────────────────────────

  Future<void> sendPhoneOtp({required String phoneNumber}) async {
    _setLoading(true);
    try {
      await _authService.sendPhoneOtp(
        phoneNumber: phoneNumber,
        linkToCurrentUser: false,
        onCodeSent: (verificationId, _) {
          _phoneVerificationId = verificationId;
          _awaitingOtp = true;
          _pendingPhone = phoneNumber;
          _linkOtpToCurrentUser = false;
          _setLoading(false);
        },
        onFailed: (msg) => _setError(_cleanAuthError(msg)),
        onAutoVerified: (_) {
          _awaitingOtp = false;
          _linkOtpToCurrentUser = false;
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  Future<void> verifyOtp({required String otp}) async {
    _setLoading(true);
    try {
      final phone = _pendingPhone;
      final linking = _linkOtpToCurrentUser;
      await _authService.verifyOtp(
        verificationId: _phoneVerificationId ?? '',
        otp: otp,
        linkToCurrentUser: linking,
      );
      if (linking && phone != null) {
        await _markPhoneVerified(phone);
      } else {
        await _primeCurrentUser();
      }
      _awaitingOtp = false;
      _linkOtpToCurrentUser = false;
      _phoneVerificationId = null;
      _pendingPhone = null;
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Email verification ────────────────────────────────────────────────────

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  Future<void> checkEmailVerification() async {
    await _authService.reloadUser();
    if (_authService.isEmailVerified) {
      _isEmailVerified = true;
      notifyListeners();
    }
  }

  // ─── Password reset ────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email: email);
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Profile update ────────────────────────────────────────────────────────

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _authService.updateProfile(
          displayName: displayName, photoUrl: photoUrl);
      if (displayName != null && _user != null) {
        _user = _user!.copyWith(name: displayName);
        await LocalStorageService.saveUser(_user!);
        await _firestore.createOrUpdateUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Sign out / delete ─────────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _isEmailVerified = false;
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      await _authService.deleteAccount();
      _user = null;
      _isEmailVerified = false;
      _setLoading(false);
    } catch (e) {
      _setError(_cleanAuthError(e));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool val) {
    _isLoading = val;
    if (!val) _error = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    _isLoading = false;
    notifyListeners();
  }

  String _cleanAuthError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<void> _primeCurrentUser() async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    await _syncUserFromFirestore(uid);
  }

  Future<void> _markPhoneVerified(String phoneNumber) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;
    await _firestore.updatePhoneVerification(uid, phoneNumber);
    await _primeCurrentUser();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
