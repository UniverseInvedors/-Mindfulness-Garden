import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Syncs Mindfulness Garden user progress to Firestore.
class FirestoreProgressService {
  FirestoreProgressService._();
  static final FirestoreProgressService instance = FirestoreProgressService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _gardenUsers =>
      _firestore.collection('mindfulness_users');

  Future<void> syncUserProgress(UserModel user) async {
    final docRef = _gardenUsers.doc(user.id);
    final profileData = _buildUserPayload(user);

    await docRef.set(
      {
        'profile': profileData,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Map<String, dynamic> _buildUserPayload(UserModel user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'joinedDate': Timestamp.fromDate(user.joinedDate),
      'totalSessions': user.totalSessions,
      'totalMinutes': user.totalMinutes,
      'currentStreak': user.currentStreak,
      'gardenLevel': user.gardenLevel,
      'lastSessionDate': user.lastSessionDate != null
          ? Timestamp.fromDate(user.lastSessionDate!)
          : null,
      'achievements': user.achievements,
      'preferences': user.preferences.toJson(),
      'coins': user.coins,
      'premiumEnergy': user.premiumEnergy,
      'mindfulnessTokens': user.mindfulnessTokens,
    };
  }
}
