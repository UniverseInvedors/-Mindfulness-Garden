// lib/core/services/firestore_service.dart
//
// Firestore service for PranaVerse.
// Handles cloud sync for:
//   • User profiles
//   • Session history
//   • Mood logs
//   • Achievements
//   • Garden progress
//   • Streak data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pranaverse/data/models/user_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection references ────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _users.doc(uid);

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _userDoc(uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> _moods(String uid) =>
      _userDoc(uid).collection('moods');

  CollectionReference<Map<String, dynamic>> _achievements(String uid) =>
      _userDoc(uid).collection('achievements');

  // ─── User profile ─────────────────────────────────────────────────────────

  /// Create or update a user document after sign-up / sign-in.
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _userDoc(user.id).set(
        {
          'uid': user.id,
          'name': user.name,
          'email': user.email,
          'gardenLevel': user.gardenLevel,
          'currentStreak': user.currentStreak,
          'totalSessions': user.totalSessions,
          'totalMinutes': user.totalMinutes,
          'achievementCount': user.achievementCount,
          'updatedAt': FieldValue.serverTimestamp(),
          'joinedAt': user.joinedDate.toIso8601String(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('✅ Firestore user upserted: ${user.id}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore createOrUpdateUser: $e');
    }
  }

  /// Create a user document specifically for development-mode signups.
  /// This writes additional metadata so development-created accounts are
  /// identifiable and skip verification flows.
  Future<void> createDevelopmentUser(UserModel user, {String? phone}) async {
    try {
      await _userDoc(user.id).set(
        {
          'uid': user.id,
          'name': user.name,
          'email': user.email,
          'phone': phone ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'authenticationMode': 'development',
          'emailVerified': false,
          'phoneVerified': false,
          'gardenLevel': user.gardenLevel,
          'currentStreak': user.currentStreak,
          'totalSessions': user.totalSessions,
          'totalMinutes': user.totalMinutes,
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('✅ Dev Firestore user created: ${user.id}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore createDevelopmentUser: $e');
    }
  }

  /// Fetch user data from Firestore.
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final snap = await _userDoc(uid).get();
      return snap.data();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getUser: $e');
      return null;
    }
  }

  Future<void> updatePhoneVerification(String uid, String phoneNumber) async {
    try {
      await _userDoc(uid).set(
        {
          'phoneNumber': phoneNumber,
          'phoneVerified': true,
          'phoneVerifiedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Phone verification sync failed: $e');
    }
  }

  /// Stream of live user updates.
  Stream<Map<String, dynamic>?> userStream(String uid) {
    return _userDoc(uid).snapshots().map((snap) => snap.data());
  }

  /// Increment a numeric user field atomically.
  Future<void> incrementUserField(String uid, String field, int amount) async {
    try {
      await _userDoc(uid).update({field: FieldValue.increment(amount)});
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore incrementUserField: $e');
    }
  }

  // ─── Sessions ─────────────────────────────────────────────────────────────

  Future<void> logSession(String uid, Map<String, dynamic> session) async {
    try {
      await _sessions(uid).add({
        ...session,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // Also bump totals on user doc
      await _userDoc(uid).update({
        'totalSessions': FieldValue.increment(1),
        'totalMinutes':
            FieldValue.increment(session['durationMinutes'] as int? ?? 0),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) debugPrint('✅ Session logged for $uid');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore logSession: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSessions(String uid,
      {int limit = 30}) async {
    try {
      final snap = await _sessions(uid)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getSessions: $e');
      return [];
    }
  }

  // ─── Mood logs ────────────────────────────────────────────────────────────

  Future<void> logMood(String uid, Map<String, dynamic> mood) async {
    try {
      final today = DateTime.now();
      final docId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await _moods(uid).doc(docId).set(
        {
          ...mood,
          'date': docId,
          'timestamp': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('✅ Mood logged for $uid');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore logMood: $e');
    }
  }

  Future<Map<String, dynamic>?> getTodayMood(String uid) async {
    try {
      final today = DateTime.now();
      final docId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final snap = await _moods(uid).doc(docId).get();
      return snap.data();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getTodayMood: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRecentMoods(String uid,
      {int days = 7}) async {
    try {
      final snap = await _moods(uid)
          .orderBy('timestamp', descending: true)
          .limit(days)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getRecentMoods: $e');
      return [];
    }
  }

  // ─── Achievements ─────────────────────────────────────────────────────────

  Future<void> unlockAchievement(
      String uid, String achievementId, String title) async {
    try {
      await _achievements(uid).doc(achievementId).set({
        'id': achievementId,
        'title': title,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
      await _userDoc(uid).update({
        'achievementCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (kDebugMode) debugPrint('🏆 Achievement unlocked: $achievementId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore unlockAchievement: $e');
    }
  }

  Future<List<String>> getUnlockedAchievements(String uid) async {
    try {
      final snap = await _achievements(uid).get();
      return snap.docs.map((d) => d.id).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getUnlockedAchievements: $e');
      return [];
    }
  }

  // ─── Garden progress ──────────────────────────────────────────────────────

  Future<void> updateGardenProgress(
      String uid, int level, int plantsGrown) async {
    try {
      await _userDoc(uid).update({
        'gardenLevel': level,
        'plantsGrown': plantsGrown,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore updateGardenProgress: $e');
    }
  }

  // ─── Streak ───────────────────────────────────────────────────────────────

  Future<void> updateStreak(String uid, int streak) async {
    try {
      await _userDoc(uid).update({
        'currentStreak': streak,
        'lastStreakUpdate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore updateStreak: $e');
    }
  }

  // ─── FCM token storage ────────────────────────────────────────────────────

  Future<void> storeFcmToken(String uid, String token) async {
    try {
      await _userDoc(uid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore storeFcmToken: $e');
    }
  }

  // ─── Leaderboard (weekly) ─────────────────────────────────────────────────

  /// Get top N users by totalMinutes this week.
  Future<List<Map<String, dynamic>>> getWeeklyLeaderboard(
      {int limit = 10}) async {
    try {
      final snap = await _users
          .orderBy('totalMinutes', descending: true)
          .limit(limit)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore getWeeklyLeaderboard: $e');
      return [];
    }
  }
}
