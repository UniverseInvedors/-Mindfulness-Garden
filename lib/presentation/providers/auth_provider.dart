import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mindfulness_garden/core/services/auth_service.dart';
import 'package:mindfulness_garden/data/models/user_model.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isEmailVerified => _isEmailVerified;
  User? get firebaseUser => _authService.currentUser;

  AuthProvider() {
    _initialize();
  }

  /// Initialize auth state listener
  void _initialize() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // User is signed in
        _user = AuthService.userModelFromFirebaseUser(firebaseUser);
        _isEmailVerified = firebaseUser.emailVerified;

        // Save to local storage
        await LocalStorageService.saveUser(_user!);

        if (_isLoading == false) notifyListeners();
      } else {
        // User is signed out
        _user = null;
        _isEmailVerified = false;
        await LocalStorageService.deleteUser();

        if (_isLoading == false) notifyListeners();
      }
    });
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Create local user model
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _user = AuthService.userModelFromFirebaseUser(firebaseUser)
            .copyWith(name: displayName);
        await LocalStorageService.saveUser(_user!);
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );

      // Create local user model
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _user = AuthService.userModelFromFirebaseUser(firebaseUser);
        await LocalStorageService.saveUser(_user!);
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signOut();
      _user = null;
      _isEmailVerified = false;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.sendPasswordResetEmail(email: email);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );

      if (displayName != null && _user != null) {
        _user = _user!.copyWith(name: displayName);
        await LocalStorageService.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.deleteAccount();
      _user = null;
      _isEmailVerified = false;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Reload user data
  Future<void> reloadUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      await firebaseUser.reload();
      _isEmailVerified = firebaseUser.emailVerified;

      _user = AuthService.userModelFromFirebaseUser(firebaseUser)
          .copyWith(name: _user?.name ?? firebaseUser.displayName);
      await LocalStorageService.saveUser(_user!);
      notifyListeners();
    }
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
