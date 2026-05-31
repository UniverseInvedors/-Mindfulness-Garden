// Fix the UserProfile constructor to have default values for missing fields
class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int coins;
  final int premiumEnergy;
  final int mindfulnessTokens;
  final int currentStreak;
  final int totalMinutes;
  final int gardenLevel;
  final int achievementCount;
  final DateTime joinedDate;

  // Constructor with default values
  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.coins = 0,
    this.premiumEnergy = 0,
    this.mindfulnessTokens = 0,
    this.currentStreak = 0,
    this.totalMinutes = 0,
    this.gardenLevel = 1,
    this.achievementCount = 0,
    required this.joinedDate,
  });

  // Simplified factory method
  factory UserProfile.fromFirestore(Map<String, dynamic> doc) {
    return UserProfile(
      id: doc['id']?.toString() ?? '',
      username: doc['username']?.toString() ?? 'User',
      email: doc['email']?.toString() ?? '',
      avatarUrl: doc['avatarUrl']?.toString(),
      coins: (doc['coins'] ?? 0) as int,
      premiumEnergy: (doc['premiumEnergy'] ?? 0) as int,
      mindfulnessTokens: (doc['mindfulnessTokens'] ?? 0) as int,
      currentStreak: (doc['currentStreak'] ?? 0) as int,
      totalMinutes: (doc['totalMinutes'] ?? 0) as int,
      gardenLevel: (doc['gardenLevel'] ?? 1) as int,
      achievementCount: (doc['achievementCount'] ?? 0) as int,
      joinedDate: doc['joinedDate'] != null
          ? DateTime.parse(doc['joinedDate'].toString())
          : DateTime.now(),
    );
  }

  // Simplified constructor for friends screen
  factory UserProfile.simple({
    required String id,
    required String username,
    required String email,
    String? avatarUrl,
    int coins = 0,
    int premiumEnergy = 0,
    int mindfulnessTokens = 0,
    int currentStreak = 0,
    int totalMinutes = 0,
  }) {
    return UserProfile(
      id: id,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      coins: coins,
      premiumEnergy: premiumEnergy,
      mindfulnessTokens: mindfulnessTokens,
      currentStreak: currentStreak,
      totalMinutes: totalMinutes,
      gardenLevel: 1,
      achievementCount: 0,
      joinedDate: DateTime.now(),
    );
  }
}
