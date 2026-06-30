// Unified wallet system using JSON serialization with SharedPreferences

/// Unified wallet model for the entire game
/// Tracks all currencies and transactions across all features
class WalletModel {
  final String userId;
  
  int coins;
  
  int premiumEnergy;
  
  int mindfulnessTokens;
  
  DateTime lastUpdated;
  
  List<Transaction> transactionHistory;
  
  Map<String, int> featureBalances; // Feature-specific balances
  
  DailyEarnings dailyEarnings;
  
  LifetimeStats lifetimeStats;
  
  WalletModel({
    required this.userId,
    this.coins = 100, // Starting coins
    this.premiumEnergy = 0,
    this.mindfulnessTokens = 0,
    required this.lastUpdated,
    List<Transaction>? transactionHistory,
    Map<String, int>? featureBalances,
    DailyEarnings? dailyEarnings,
    LifetimeStats? lifetimeStats,
  })  : transactionHistory = transactionHistory ?? [],
        featureBalances = featureBalances ?? {
          'meditation': 0,
          'garden': 0,
          'community': 0,
          'challenges': 0,
          'achievements': 0,
        },
        dailyEarnings = dailyEarnings ?? DailyEarnings(),
        lifetimeStats = lifetimeStats ?? LifetimeStats();
  
  /// Add coins from a specific feature
  void addCoins(int amount, {required String feature, String? description}) {
    if (amount <= 0) return;
    
    coins += amount;
    
    // Update feature balance
    featureBalances[feature] = (featureBalances[feature] ?? 0) + amount;
    
    // Update daily earnings
    dailyEarnings.addEarning(amount, feature);
    
    // Update lifetime stats
    lifetimeStats.totalCoinsEarned += amount;
    lifetimeStats.earningsByFeature[feature] = 
        (lifetimeStats.earningsByFeature[feature] ?? 0) + amount;
    
    // Record transaction
    transactionHistory.add(Transaction.earning(
      amount: amount,
      feature: feature,
      description: description ?? 'Earned from $feature',
    ));
    
    lastUpdated = DateTime.now();
  }
  
  /// Spend coins on a specific feature
  bool spendCoins(int amount, {required String feature, String? description}) {
    if (amount <= 0 || coins < amount) return false;
    
    coins -= amount;
    
    // Update lifetime stats
    lifetimeStats.totalCoinsSpent += amount;
    lifetimeStats.spendingByFeature[feature] = 
        (lifetimeStats.spendingByFeature[feature] ?? 0) + amount;
    
    // Record transaction
    transactionHistory.add(Transaction.spending(
      amount: amount,
      feature: feature,
      description: description ?? 'Spent on $feature',
    ));
    
    lastUpdated = DateTime.now();
    return true;
  }
  
  /// Add premium energy
  void addPremiumEnergy(int amount, {required String source}) {
    if (amount <= 0) return;
    
    premiumEnergy += amount;
    lifetimeStats.totalPremiumEnergyEarned += amount;
    
    transactionHistory.add(Transaction.premiumEnergy(
      amount: amount,
      source: source,
    ));
    
    lastUpdated = DateTime.now();
  }
  
  /// Spend premium energy
  bool spendPremiumEnergy(int amount, {required String purpose}) {
    if (amount <= 0 || premiumEnergy < amount) return false;
    
    premiumEnergy -= amount;
    lifetimeStats.totalPremiumEnergySpent += amount;
    
    transactionHistory.add(Transaction.premiumEnergySpending(
      amount: amount,
      purpose: purpose,
    ));
    
    lastUpdated = DateTime.now();
    return true;
  }
  
  /// Add mindfulness tokens (earned from meditation)
  void addMindfulnessTokens(int amount, {required int meditationMinutes}) {
    if (amount <= 0) return;
    
    mindfulnessTokens += amount;
    featureBalances['meditation'] = (featureBalances['meditation'] ?? 0) + amount;
    dailyEarnings.addMeditationTokens(amount, meditationMinutes);
    lifetimeStats.totalMeditationMinutes += meditationMinutes;
    lifetimeStats.totalMindfulnessTokens += amount;
    
    transactionHistory.add(Transaction.mindfulnessToken(
      amount: amount,
      meditationMinutes: meditationMinutes,
    ));
    
    lastUpdated = DateTime.now();
  }
  
  /// Convert mindfulness tokens to coins (exchange rate)
  bool convertTokensToCoins(int tokens, {double exchangeRate = 10.0}) {
    if (tokens <= 0 || mindfulnessTokens < tokens) return false;
    
    final coinsAmount = (tokens * exchangeRate).round();
    mindfulnessTokens -= tokens;
    coins += coinsAmount;
    
    transactionHistory.add(Transaction.conversion(
      fromAmount: tokens,
      fromCurrency: 'tokens',
      toAmount: coinsAmount,
      toCurrency: 'coins',
      rate: exchangeRate,
    ));
    
    lastUpdated = DateTime.now();
    return true;
  }
  
  /// Get daily streak bonus
  int getDailyStreakBonus(int streakDays) {
    // Base bonus + increasing bonus for longer streaks
    final baseBonus = 10;
    final streakBonus = streakDays * 5;
    return baseBonus + streakBonus;
  }
  
  /// Apply daily streak reward
  void applyDailyStreakReward(int streakDays) {
    final bonus = getDailyStreakBonus(streakDays);
    addCoins(bonus, feature: 'streak', description: 'Daily streak bonus');
    dailyEarnings.streakBonus += bonus;
  }
  
  /// Get feature-specific balance
  int getFeatureBalance(String feature) {
    return featureBalances[feature] ?? 0;
  }
  
  /// Get total earned from all features
  int getTotalEarned() {
    return featureBalances.values.fold(0, (sum, balance) => sum + balance);
  }
  
  /// Get today's earnings
  int getTodayEarnings() {
    return dailyEarnings.getTotalEarnings();
  }
  
  /// Reset daily earnings (called at midnight)
  void resetDailyEarnings() {
    dailyEarnings = DailyEarnings();
    lastUpdated = DateTime.now();
  }
  
  /// Get wallet summary for UI
  Map<String, dynamic> getSummary() {
    return {
      'coins': coins,
      'premiumEnergy': premiumEnergy,
      'mindfulnessTokens': mindfulnessTokens,
      'totalEarned': getTotalEarned(),
      'todayEarnings': getTodayEarnings(),
      'featureBalances': Map<String, int>.from(featureBalances),
      'dailyStreakBonus': dailyEarnings.streakBonus,
      'lifetimeStats': lifetimeStats.toMap(),
    };
  }
  
  /// Copy with updates
  WalletModel copyWith({
    String? userId,
    int? coins,
    int? premiumEnergy,
    int? mindfulnessTokens,
    DateTime? lastUpdated,
    List<Transaction>? transactionHistory,
    Map<String, int>? featureBalances,
    DailyEarnings? dailyEarnings,
    LifetimeStats? lifetimeStats,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      coins: coins ?? this.coins,
      premiumEnergy: premiumEnergy ?? this.premiumEnergy,
      mindfulnessTokens: mindfulnessTokens ?? this.mindfulnessTokens,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactionHistory: transactionHistory ?? List<Transaction>.from(this.transactionHistory),
      featureBalances: featureBalances ?? Map<String, int>.from(this.featureBalances),
      dailyEarnings: dailyEarnings ?? this.dailyEarnings.copyWith(),
      lifetimeStats: lifetimeStats ?? this.lifetimeStats.copyWith(),
    );
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'coins': coins,
      'premiumEnergy': premiumEnergy,
      'mindfulnessTokens': mindfulnessTokens,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactionHistory': transactionHistory.map((t) => t.toJson()).toList(),
      'featureBalances': featureBalances,
      'dailyEarnings': dailyEarnings.toJson(),
      'lifetimeStats': lifetimeStats.toJson(),
    };
  }
  
  /// Create from JSON
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId'],
      coins: json['coins'],
      premiumEnergy: json['premiumEnergy'],
      mindfulnessTokens: json['mindfulnessTokens'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      transactionHistory: (json['transactionHistory'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      featureBalances: Map<String, int>.from(json['featureBalances']),
      dailyEarnings: DailyEarnings.fromJson(json['dailyEarnings']),
      lifetimeStats: LifetimeStats.fromJson(json['lifetimeStats']),
    );
  }
}

/// Transaction record
class Transaction {
  final String id;
  
  final DateTime timestamp;
  
  final TransactionType type;
  
  final int amount;
  
  final String? feature;
  
  final String? description;
  
  final Map<String, dynamic> metadata;
  
  Transaction({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.amount,
    this.feature,
    this.description,
    this.metadata = const {},
  });
  
  /// Create earning transaction
  factory Transaction.earning({
    required int amount,
    required String feature,
    String? description,
  }) {
    return Transaction(
      id: 'earn_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.earning,
      amount: amount,
      feature: feature,
      description: description,
    );
  }
  
  /// Create spending transaction
  factory Transaction.spending({
    required int amount,
    required String feature,
    String? description,
  }) {
    return Transaction(
      id: 'spend_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.spending,
      amount: amount,
      feature: feature,
      description: description,
    );
  }
  
  /// Create premium energy transaction
  factory Transaction.premiumEnergy({
    required int amount,
    required String source,
  }) {
    return Transaction(
      id: 'premium_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.premiumEnergy,
      amount: amount,
      feature: 'premium',
      description: 'Premium energy from $source',
    );
  }
  
  /// Create premium energy spending transaction
  factory Transaction.premiumEnergySpending({
    required int amount,
    required String purpose,
  }) {
    return Transaction(
      id: 'premium_spend_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.premiumEnergySpending,
      amount: amount,
      feature: 'premium',
      description: 'Premium energy spent on $purpose',
    );
  }
  
  /// Create mindfulness token transaction
  factory Transaction.mindfulnessToken({
    required int amount,
    required int meditationMinutes,
  }) {
    return Transaction(
      id: 'token_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.mindfulnessToken,
      amount: amount,
      feature: 'meditation',
      description: 'Mindfulness tokens from meditation',
      metadata: {'meditationMinutes': meditationMinutes},
    );
  }
  
  /// Create conversion transaction
  factory Transaction.conversion({
    required int fromAmount,
    required String fromCurrency,
    required int toAmount,
    required String toCurrency,
    required double rate,
  }) {
    return Transaction(
      id: 'convert_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      type: TransactionType.conversion,
      amount: toAmount,
      feature: 'conversion',
      description: 'Converted $fromAmount $fromCurrency to $toAmount $toCurrency',
      metadata: {
        'fromAmount': fromAmount,
        'fromCurrency': fromCurrency,
        'toAmount': toAmount,
        'toCurrency': toCurrency,
        'rate': rate,
      },
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'amount': amount,
      'feature': feature,
      'description': description,
      'metadata': metadata,
    };
  }
  
  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.earning,
      ),
      amount: json['amount'],
      feature: json['feature'],
      description: json['description'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

/// Transaction types
enum TransactionType {
  earning,
  spending,
  premiumEnergy,
  premiumEnergySpending,
  mindfulnessToken,
  conversion,
}

/// Daily earnings tracker
class DailyEarnings {
  final DateTime date;
  
  int meditationEarnings;
  
  int gardenEarnings;
  
  int communityEarnings;
  
  int challengeEarnings;
  
  int achievementEarnings;
  
  int streakBonus;
  
  int meditationMinutes;
  
  int mindfulnessTokens;
  
  DailyEarnings({
    DateTime? date,
    this.meditationEarnings = 0,
    this.gardenEarnings = 0,
    this.communityEarnings = 0,
    this.challengeEarnings = 0,
    this.achievementEarnings = 0,
    this.streakBonus = 0,
    this.meditationMinutes = 0,
    this.mindfulnessTokens = 0,
  }) : date = date ?? DateTime.now();
  
  /// Add earning from any feature
  void addEarning(int amount, String feature) {
    switch (feature) {
      case 'meditation':
        meditationEarnings += amount;
        break;
      case 'garden':
        gardenEarnings += amount;
        break;
      case 'community':
        communityEarnings += amount;
        break;
      case 'challenges':
        challengeEarnings += amount;
        break;
      case 'achievements':
        achievementEarnings += amount;
        break;
    }
  }
  
  /// Add meditation tokens
  void addMeditationTokens(int tokens, int minutes) {
    mindfulnessTokens += tokens;
    meditationMinutes += minutes;
  }
  
  /// Get total earnings for the day
  int getTotalEarnings() {
    return meditationEarnings +
           gardenEarnings +
           communityEarnings +
           challengeEarnings +
           achievementEarnings +
           streakBonus;
  }
  
  /// Copy with updates
  DailyEarnings copyWith({
    DateTime? date,
    int? meditationEarnings,
    int? gardenEarnings,
    int? communityEarnings,
    int? challengeEarnings,
    int? achievementEarnings,
    int? streakBonus,
    int? meditationMinutes,
    int? mindfulnessTokens,
  }) {
    return DailyEarnings(
      date: date ?? this.date,
      meditationEarnings: meditationEarnings ?? this.meditationEarnings,
      gardenEarnings: gardenEarnings ?? this.gardenEarnings,
      communityEarnings: communityEarnings ?? this.communityEarnings,
      challengeEarnings: challengeEarnings ?? this.challengeEarnings,
      achievementEarnings: achievementEarnings ?? this.achievementEarnings,
      streakBonus: streakBonus ?? this.streakBonus,
      meditationMinutes: meditationMinutes ?? this.meditationMinutes,
      mindfulnessTokens: mindfulnessTokens ?? this.mindfulnessTokens,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meditationEarnings': meditationEarnings,
      'gardenEarnings': gardenEarnings,
      'communityEarnings': communityEarnings,
      'challengeEarnings': challengeEarnings,
      'achievementEarnings': achievementEarnings,
      'streakBonus': streakBonus,
      'meditationMinutes': meditationMinutes,
      'mindfulnessTokens': mindfulnessTokens,
    };
  }
  
  /// Create from JSON
  factory DailyEarnings.fromJson(Map<String, dynamic> json) {
    return DailyEarnings(
      date: DateTime.parse(json['date']),
      meditationEarnings: json['meditationEarnings'],
      gardenEarnings: json['gardenEarnings'],
      communityEarnings: json['communityEarnings'],
      challengeEarnings: json['challengeEarnings'],
      achievementEarnings: json['achievementEarnings'],
      streakBonus: json['streakBonus'],
      meditationMinutes: json['meditationMinutes'],
      mindfulnessTokens: json['mindfulnessTokens'],
    );
  }
}

/// Lifetime statistics
class LifetimeStats {
  int totalCoinsEarned;
  
  int totalCoinsSpent;
  
  int totalPremiumEnergyEarned;
  
  int totalPremiumEnergySpent;
  
  int totalMindfulnessTokens;
  
  int totalMeditationMinutes;
  
  Map<String, int> earningsByFeature;
  
  Map<String, int> spendingByFeature;
  
  LifetimeStats({
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.totalPremiumEnergyEarned = 0,
    this.totalPremiumEnergySpent = 0,
    this.totalMindfulnessTokens = 0,
    this.totalMeditationMinutes = 0,
    Map<String, int>? earningsByFeature,
    Map<String, int>? spendingByFeature,
  })  : earningsByFeature = earningsByFeature ?? {
          'meditation': 0,
          'garden': 0,
          'community': 0,
          'challenges': 0,
          'achievements': 0,
        },
        spendingByFeature = spendingByFeature ?? {
          'garden': 0,
          'community': 0,
          'shop': 0,
          'upgrades': 0,
        };
  
  /// Get net worth (coins + premium energy value)
  int get netWorth {
    return (totalCoinsEarned - totalCoinsSpent) + (totalPremiumEnergyEarned - totalPremiumEnergySpent) * 10;
  }
  
  /// Get feature with most earnings
  String get topEarningFeature {
    if (earningsByFeature.isEmpty) return 'None';
    
    final entries = earningsByFeature.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
  
  /// Copy with updates
  LifetimeStats copyWith({
    int? totalCoinsEarned,
    int? totalCoinsSpent,
    int? totalPremiumEnergyEarned,
    int? totalPremiumEnergySpent,
    int? totalMindfulnessTokens,
    int? totalMeditationMinutes,
    Map<String, int>? earningsByFeature,
    Map<String, int>? spendingByFeature,
  }) {
    return LifetimeStats(
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalCoinsSpent: totalCoinsSpent ?? this.totalCoinsSpent,
      totalPremiumEnergyEarned: totalPremiumEnergyEarned ?? this.totalPremiumEnergyEarned,
      totalPremiumEnergySpent: totalPremiumEnergySpent ?? this.totalPremiumEnergySpent,
      totalMindfulnessTokens: totalMindfulnessTokens ?? this.totalMindfulnessTokens,
      totalMeditationMinutes: totalMeditationMinutes ?? this.totalMeditationMinutes,
      earningsByFeature: earningsByFeature ?? Map<String, int>.from(this.earningsByFeature),
      spendingByFeature: spendingByFeature ?? Map<String, int>.from(this.spendingByFeature),
    );
  }
  
  /// Convert to map for UI
  Map<String, dynamic> toMap() {
    return {
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'totalPremiumEnergyEarned': totalPremiumEnergyEarned,
      'totalPremiumEnergySpent': totalPremiumEnergySpent,
      'totalMindfulnessTokens': totalMindfulnessTokens,
      'totalMeditationMinutes': totalMeditationMinutes,
      'netWorth': netWorth,
      'topEarningFeature': topEarningFeature,
      'earningsByFeature': Map<String, int>.from(earningsByFeature),
      'spendingByFeature': Map<String, int>.from(spendingByFeature),
    };
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'totalPremiumEnergyEarned': totalPremiumEnergyEarned,
      'totalPremiumEnergySpent': totalPremiumEnergySpent,
      'totalMindfulnessTokens': totalMindfulnessTokens,
      'totalMeditationMinutes': totalMeditationMinutes,
      'earningsByFeature': earningsByFeature,
      'spendingByFeature': spendingByFeature,
    };
  }
  
  /// Create from JSON
  factory LifetimeStats.fromJson(Map<String, dynamic> json) {
    return LifetimeStats(
      totalCoinsEarned: json['totalCoinsEarned'],
      totalCoinsSpent: json['totalCoinsSpent'],
      totalPremiumEnergyEarned: json['totalPremiumEnergyEarned'],
      totalPremiumEnergySpent: json['totalPremiumEnergySpent'],
      totalMindfulnessTokens: json['totalMindfulnessTokens'],
      totalMeditationMinutes: json['totalMeditationMinutes'],
      earningsByFeature: Map<String, int>.from(json['earningsByFeature']),
      spendingByFeature: Map<String, int>.from(json['spendingByFeature']),
    );
  }
}
