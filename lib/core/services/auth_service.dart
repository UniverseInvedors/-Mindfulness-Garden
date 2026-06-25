import 'package:flutter/foundation.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/services/backend_integration_service.dart';

/// Backend authentication service using universe_backend_sdk
class AuthService {
  static BackendIntegrationService? _backendService;
  static String? _currentUserId;

  /// Initialize auth service with backend
  static Future<void> initialize(BackendIntegrationService backendService) async {
    _backendService = backendService;
    _currentUserId = await _backendService!.isAuthenticated() 
        ? await _getUserIdFromStorage() 
        : null;
  }

  /// Stream of auth state changes (simulated for compatibility)
  Stream<String?> get authStateChanges async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield _currentUserId;
    }
  }

  /// Get current user ID
  String? get currentUserId => _currentUserId;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUserId != null;

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      if (_backendService == null) {
        throw Exception('Backend service not initialized');
      }

      final success = await _backendService!.register(
        email,
        password,
        displayName.split(' ').first,
        displayName.split(' ').length > 1 ? displayName.split(' ').last : '',
      );

      if (success) {
        // Auto-login after registration
        await signIn(email: email, password: password);
      }

      if (kDebugMode) {
        print('✅ User signed up: $email');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up failed: $e');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_backendService == null) {
        throw Exception('Backend service not initialized');
      }

      final success = await _backendService!.login(email, password);

      if (success) {
        _currentUserId = email; // Use email as user ID for now
        await _saveUserIdToStorage(email);
      }

      if (kDebugMode) {
        print('✅ User signed in: $email');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in failed: $e');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _backendService?.logout();
      _currentUserId = null;
      await _clearUserIdFromStorage();

      // Clear local user data
      await LocalStorageService.deleteUser();

      if (kDebugMode) {
        print('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
      rethrow;
    }
  }

  /// Send password reset email (placeholder - needs backend implementation)
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      // TODO: Implement password reset via backend
      if (kDebugMode) {
        print('⚠️ Password reset not yet implemented for backend');
      }
      throw UnimplementedError('Password reset requires backend implementation');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Password reset failed: $e');
      }
      rethrow;
    }
  }

  /// Get ID token for API calls (placeholder)
  Future<String?> getIdToken() async {
    try {
      // TODO: Implement token retrieval from backend
      return _currentUserId;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get ID token: $e');
      }
      return null;
    }
  }

  /// Create local UserModel from backend user data
  static UserModel userModelFromBackendUser(String email, String displayName) {
    return UserModel(
      id: email,
      name: displayName,
      email: email,
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
  }

  /// Update user profile (placeholder)
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      // TODO: Implement profile update via backend
      if (kDebugMode) {
        print('⚠️ Profile update not yet implemented for backend');
      }
      throw UnimplementedError('Profile update requires backend implementation');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update profile: $e');
      }
      rethrow;
    }
  }

  /// Delete user account (placeholder)
  Future<void> deleteAccount() async {
    try {
      // TODO: Implement account deletion via backend
      await signOut();
      if (kDebugMode) {
        print('⚠️ Account deletion not yet implemented for backend');
      }
      throw UnimplementedError('Account deletion requires backend implementation');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete account: $e');
      }
      rethrow;
    }
  }

  /// Verify email (placeholder)
  Future<void> sendEmailVerification() async {
    try {
      // TODO: Implement email verification via backend
      if (kDebugMode) {
        print('⚠️ Email verification not yet implemented for backend');
      }
      throw UnimplementedError('Email verification requires backend implementation');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send verification email: $e');
      }
      rethrow;
    }
  }

  /// Check if email is verified (placeholder)
  bool get isEmailVerified => true; // Assume verified for backend

  // Storage helpers
  static Future<void> _saveUserIdToStorage(String userId) async {
    await LocalStorageService.saveSetting('user_id', userId);
  }

  static Future<String?> _getUserIdFromStorage() async {
    return await LocalStorageService.getSetting('user_id');
  }

  static Future<void> _clearUserIdFromStorage() async {
    await LocalStorageService.deleteSetting('user_id');
  }
}
