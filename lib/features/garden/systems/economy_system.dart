import 'dart:convert';

/// Economy system for managing currency, rewards, and penalties
/// Simplified version without Hive - uses in-memory storage
class EconomySystem {
  /// Coins (basic currency)
  int coins;
  
  /// Premium energy (special currency)
  int premiumEnergy;
  
  /// Total coins earned (lifetime)
  int totalCoinsEarned;
  
  /// Total coins spent (lifetime)
  int totalCoinsSpent;
  
  /// Current score
  int score;
  
  /// High score
  int highScore;
  
  /// Current streak (consecutive days with activity)
  int currentStreak;
  
  /// Longest streak
  int longestStreak;
  
  /// Last activity date (for streak tracking)
  DateTime lastActivityDate;
  
  /// Whether economy system is initialized
  bool _isInitialized = false;
  
  EconomySystem({
    this.coins = 100,
    this.premiumEnergy = 0,
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.score = 0,
    this.highScore = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastActivityDate,
  }) : lastActivityDate = lastActivityDate ?? DateTime.now();
  
  /// Initialize economy system
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // For now, just mark as initialized
    // In a real app, you would load from SharedPreferences
    _isInitialized = true;
  }
  
  /// Save economy data
  Future<void> save() async {
    // For now, just update streak
    _updateStreak();
  }
  
  /// Update streak based on last activity
  void _updateStreak() {
    final now = DateTime.now();
    final lastDate = DateTime(lastActivityDate.year, lastActivityDate.month, lastActivityDate.day);
    final today = DateTime(now.year, now.month, now.day);
    
    final difference = today.difference(lastDate).inDays;
    
    if (difference == 0) {
      // Already updated today
      return;
    } else if (difference == 1) {
      // Consecutive day - increment streak
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else if (difference > 1) {
      // Streak broken
      currentStreak = 1;
    }
    
    lastActivityDate = now;
  }
  
  /// Add coins with reward rules
  void addCoins(int amount, {String source = 'unknown', double multiplier = 1.0}) {
    if (amount <= 0) return;
    
    final adjustedAmount = (amount * multiplier).round();
    coins += adjustedAmount;
    totalCoinsEarned += adjustedAmount;
    
    // Update score based on coins earned
    score += adjustedAmount ~/ 10;
    
    // Update high score if needed
    if (score > highScore) {
      highScore = score;
    }
    
    // Update streak
    _updateStreak();
    
    // Save changes
    save();
  }
  
  /// Spend coins with validation
  bool spendCoins(int amount, {String purpose = 'unknown'}) {
    if (amount <= 0 || coins < amount) {
      return false;
    }
    
    coins -= amount;
    totalCoinsSpent += amount;
    
    // Save changes
    save();
    
    return true;
  }
  
  /// Add premium energy
  void addPremiumEnergy(int amount, {String source = 'unknown'}) {
    if (amount <= 0) return;
    
    premiumEnergy += amount;
    
    // Save changes
    save();
  }
  
  /// Spend premium energy with validation
  bool spendPremiumEnergy(int amount, {String purpose = 'unknown'}) {
    if (amount <= 0 || premiumEnergy < amount) {
      return false;
    }
    
    premiumEnergy -= amount;
    
    // Save changes
    save();
    
    return true;
  }
  
  /// Apply penalty (coin loss)
  void applyPenalty(int amount, {String reason = 'unknown'}) {
    if (amount <= 0) return;
    
    coins = (coins - amount).clamp(0, coins);
    
    // Penalty also reduces score
    score = (score - amount ~/ 20).clamp(0, score);
    
    // Save changes
    save();
  }
  
  /// Apply disturbance penalty (for disturbing meditators)
  void applyDisturbancePenalty(int amount) {
    applyPenalty(amount, reason: 'disturbance');
    
    // Disturbance also reduces premium energy
    premiumEnergy = (premiumEnergy - amount ~/ 10).clamp(0, premiumEnergy);
  }
  
  /// Calculate harvest reward
  int calculateHarvestReward({
    required int plantLevel,
    required double careQuality,
    required double growthProgress,
    required double health,
    bool isPerfectCare = false,
  }) {
    // Base reward based on plant level
    int baseReward = plantLevel * 20;
    
    // Care quality bonus
    int careBonus = (careQuality * 50).round();
    
    // Growth progress bonus
    int growthBonus = (growthProgress / 100 * 30).round();
    
    // Health bonus
    int healthBonus = (health / 100 * 20).round();
    
    // Perfect care multiplier
    double multiplier = 1.0;
    if (isPerfectCare) {
      multiplier = 2.0; // Double reward for perfect care
    }
    
    // Calculate total reward
    int totalReward = ((baseReward + careBonus + growthBonus + healthBonus) * multiplier).round();
    
    return totalReward;
  }
  
  /// Calculate plant death penalty
  int calculateDeathPenalty({
    required int plantLevel,
    required double investment,
  }) {
    // Penalty is a percentage of the investment
    int penalty = (investment * 0.3).round();
    
    // Minimum penalty based on plant level
    int minPenalty = plantLevel * 5;
    
    return penalty.clamp(minPenalty, investment ~/ 2);
  }
  
  /// Check if player can afford a purchase
  bool canAfford({int coinsCost = 0, int energyCost = 0}) {
    return coins >= coinsCost && premiumEnergy >= energyCost;
  }
  
  /// Get economy stats for UI
  Map<String, dynamic> getStats() {
    return {
      'coins': coins,
      'premium_energy': premiumEnergy,
      'total_coins_earned': totalCoinsEarned,
      'total_coins_spent': totalCoinsSpent,
      'score': score,
      'high_score': highScore,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'net_worth': coins + (premiumEnergy * 10), // Premium energy is worth 10x coins
    };
  }
  
  /// Reset economy to defaults
  Future<void> reset() async {
    coins = 100;
    premiumEnergy = 0;
    totalCoinsEarned = 0;
    totalCoinsSpent = 0;
    score = 0;
    highScore = 0;
    currentStreak = 0;
    longestStreak = 0;
    lastActivityDate = DateTime.now();
    
    await save();
  }
  
  /// Export economy data as JSON
  String exportData() {
    return jsonEncode({
      'coins': coins,
      'premium_energy': premiumEnergy,
      'total_coins_earned': totalCoinsEarned,
      'total_coins_spent': totalCoinsSpent,
      'score': score,
      'high_score': highScore,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate.toIso8601String(),
      'version': '1.0',
    });
  }
  
  /// Import economy data from JSON
  Future<void> importData(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      coins = data['coins'] as int? ?? coins;
      premiumEnergy = data['premium_energy'] as int? ?? premiumEnergy;
      totalCoinsEarned = data['total_coins_earned'] as int? ?? totalCoinsEarned;
      totalCoinsSpent = data['total_coins_spent'] as int? ?? totalCoinsSpent;
      score = data['score'] as int? ?? score;
      highScore = data['high_score'] as int? ?? highScore;
      currentStreak = data['current_streak'] as int? ?? currentStreak;
      longestStreak = data['longest_streak'] as int? ?? longestStreak;
      
      final lastActivityStr = data['last_activity_date'] as String?;
      if (lastActivityStr != null) {
        lastActivityDate = DateTime.parse(lastActivityStr);
      }
      
      await save();
    } catch (e) {
      throw Exception('Failed to import economy data: $e');
    }
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await save();
  }
}
