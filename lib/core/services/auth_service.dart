import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:mindfulness_garden/data/models/user_model.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

/// Firebase authentication service
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName.trim());
      await userCredential.user?.reload();

      if (kDebugMode) {
        print('✅ User signed up: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign up failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (kDebugMode) {
        print('✅ User signed in: ${userCredential.user?.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Sign in failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();

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

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      if (kDebugMode) {
        print('✅ Password reset email sent to: $email');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Password reset failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Get ID token for API calls
  Future<String?> getIdToken() async {
    try {
      return await currentUser?.getIdToken();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get ID token: $e');
      }
      return null;
    }
  }

  /// Create local UserModel from Firebase User
  static UserModel userModelFromFirebaseUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Mindful Gardener',
      email: firebaseUser.email ?? '',
      joinedDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
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

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      if (photoUrl != null) {
        await currentUser?.updatePhotoURL(photoUrl);
      }
      await currentUser?.reload();

      if (kDebugMode) {
        print('✅ Profile updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update profile: $e');
      }
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      await LocalStorageService.deleteUser();

      if (kDebugMode) {
        print('✅ Account deleted');
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete account: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Verify email
  Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();

      if (kDebugMode) {
        print('✅ Verification email sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send verification email: $e');
      }
      rethrow;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;
}
