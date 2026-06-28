// lib/core/services/auth_service.dart
//
// Firebase Authentication service for PranaVerse.
// Supports:
//   â€¢ Email + password (sign-up / sign-in)
//   â€¢ Email verification
//   â€¢ Password reset
//   â€¢ Phone OTP (send + verify)
//   â€¢ Google Sign-In  â† auto sign-up for new users, sign-in for existing
//   â€¢ Auth-state stream

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/core/config.dart';

/// Result of a Google Sign-In attempt, so callers know whether a new account
/// was just created (useful for showing a welcome / onboarding flow).
class GoogleSignInResult {
  final UserCredential credential;
  final bool isNewUser;

  const GoogleSignInResult({
    required this.credential,
    required this.isNewUser,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _webClientId =
      '885156577376-mupbn9ubt8alj2es7sd56u30r6hk072m.apps.googleusercontent.com';

  // serverClientId must match the Web OAuth 2.0 client ID from Firebase Console
  // (type 3 in google-services.json).  Replace the placeholder once you have
  // added the SHA-1 fingerprint and downloaded the updated google-services.json.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // â”€â”€â”€ Auth-state stream â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Stream<String?> get authStateChanges =>
      _auth.authStateChanges().map((user) => user?.uid);

  // â”€â”€â”€ Current user helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  User? get _firebaseUser => _auth.currentUser;
  String? get currentUserId => _firebaseUser?.uid;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  String? get currentEmail => _firebaseUser?.email;
  String? get currentDisplayName => _firebaseUser?.displayName;

  // â”€â”€â”€ Email / Password â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await _auth.setLanguageCode('en');
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      // In development mode we skip sending an email verification so
      // sign-up is quicker and does not require inbox interaction.
      // Production behavior is preserved by guarding this call.
      try {
        // Importing config here would create a circular import in some
        // contexts; callers should control behavior via the global flag
        // in `lib/core/config.dart`. We attempt a runtime check by
        // reading the top-level const via import.
        // Note: the `config.dart` import is added at top of file.
      } catch (_) {}

      // Actual send guarded by config (import at top)
      // (See file-level import added)
      if (!kDevelopmentAuthMode) {
        await cred.user?.sendEmailVerification();
      }
      if (kDebugMode) debugPrint('âœ… Signed up: $email');
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (kDebugMode) debugPrint('âœ… Signed in: $email');
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // â”€â”€â”€ Google Sign-In (auto sign-up for new users) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //
  // Firebase's signInWithCredential does BOTH sign-in and sign-up automatically:
  //   â€¢ Existing account â†’ signs them in
  //   â€¢ New account      â†’ creates it silently, then signs them in
  //
  // We expose isNewUser so the UI can show a welcome screen for first-timers.

  Future<GoogleSignInResult?> signInWithGoogle() async {
    try {
      // Trigger the Google account picker
      final googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        // User dismissed the picker â€” not an error
        if (kDebugMode) debugPrint('â„¹ï¸ Google sign-in cancelled by user');
        return null;
      }

      final googleAuth = await googleAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // signInWithCredential creates the user if they don't exist yet
      final result = await _auth.signInWithCredential(credential);
      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (kDebugMode) {
        debugPrint(isNewUser
            ? 'âœ… Google sign-up (new user): ${result.user?.email}'
            : 'âœ… Google sign-in (existing user): ${result.user?.email}');
      }

      // For new Google users, update their display name if Firebase doesn't
      // have one set yet (Google already provides it, but let's be explicit)
      if (isNewUser && result.user?.displayName == null) {
        await result.user?.updateDisplayName(googleAccount.displayName);
      }

      return GoogleSignInResult(credential: result, isNewUser: isNewUser);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    } on PlatformException catch (e) {
      throw _mapGooglePlatformError(e);
    } catch (e) {
      if (kDebugMode) debugPrint('âŒ Google sign-in error: $e');
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  // â”€â”€â”€ Phone OTP â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String errorMessage) onFailed,
    void Function(PhoneAuthCredential)? onAutoVerified,
    bool linkToCurrentUser = false,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        try {
          if (linkToCurrentUser && _firebaseUser != null) {
            await _firebaseUser!.linkWithCredential(credential);
          } else {
            await _auth.signInWithCredential(credential);
          }
          onAutoVerified?.call(credential);
        } on FirebaseAuthException catch (e) {
          onFailed(_mapFirebaseError(e).toString());
        } catch (_) {
          onFailed('Phone verification failed. Please try again.');
        }
      },
      verificationFailed: (e) {
        if (kDebugMode) debugPrint('âŒ Phone OTP failed: ${e.message}');
        onFailed(_mapFirebaseError(e).toString());
      },
      codeSent: (verificationId, resendToken) {
        if (kDebugMode) debugPrint('ðŸ“± OTP sent to $phoneNumber');
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String otp,
    bool linkToCurrentUser = false,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = linkToCurrentUser && _firebaseUser != null
          ? await _firebaseUser!.linkWithCredential(credential)
          : await _auth.signInWithCredential(credential);
      if (kDebugMode) debugPrint('âœ… Phone OTP verified');
      return result;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> linkPhoneToCurrentUser({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _firebaseUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // â”€â”€â”€ Email verification â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> reloadUser() async => await _firebaseUser?.reload();

  // â”€â”€â”€ Password reset â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // â”€â”€â”€ Profile update â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      if (displayName != null)
        await _firebaseUser?.updateDisplayName(displayName);
      if (photoUrl != null) await _firebaseUser?.updatePhotoURL(photoUrl);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // â”€â”€â”€ Sign out / delete â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await LocalStorageService.deleteUser();
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firebaseUser?.delete();
      await LocalStorageService.deleteUser();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // â”€â”€â”€ Token â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _firebaseUser?.getIdToken(forceRefresh);
    } catch (_) {
      return null;
    }
  }

  // â”€â”€â”€ Build UserModel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  UserModel buildUserModel() {
    final user = _firebaseUser;
    return UserModel(
      id: user?.uid ?? '',
      name: user?.displayName ?? user?.email?.split('@').first ?? 'User',
      email: user?.email ?? '',
      joinedDate: user?.metadata.creationTime ?? DateTime.now(),
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

  // â”€â”€â”€ Error mapping â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Exception _mapFirebaseError(FirebaseAuthException e) {
    final firebaseMessage = e.message ?? '';
    if (e.code == 'operation-not-allowed' &&
        firebaseMessage.contains('SMS unable to be sent')) {
      return Exception(
        'Phone sign-in is not enabled for this region in Firebase. Use email or Google sign-in, or enable Phone auth and the SMS region in Firebase Console.',
      );
    }

    final msg = switch (e.code) {
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password.',
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'The email address is invalid.',
      'weak-password' => 'Password must be at least 6 characters.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' => 'Network error. Check your connection.',
      'operation-not-allowed' =>
        'This sign-in method is disabled in Firebase Console.',
      'invalid-verification-code' => 'Invalid OTP code. Please try again.',
      'invalid-verification-id' => 'Verification session expired. Resend OTP.',
      'credential-already-in-use' =>
        'This credential is linked to another account.',
      'requires-recent-login' => 'Please sign in again before this operation.',
      'sign_in_failed' =>
        'Google sign-in failed. Check SHA-1 in Firebase Console.',
      _ => e.message ?? 'Authentication error (${e.code}).',
    };
    return Exception(msg);
  }

  Exception _mapGooglePlatformError(PlatformException e) {
    final text = '${e.code} ${e.message ?? ''} ${e.details ?? ''}';
    if (text.contains('ApiException: 10') || text.contains('DEVELOPER_ERROR')) {
      return Exception(
        'Google sign-in is not configured for this app signing key. Add this build SHA-1/SHA-256 to Firebase, then download the updated google-services.json.',
      );
    }
    return Exception('Google sign-in failed. Please try again.');
  }
}
