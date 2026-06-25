import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranaverse/data/models/wallet_model.dart';
import 'package:pranaverse/data/models/user_model.dart';

/// Unified wallet service for managing currency across all game features
class WalletService {
  /// SharedPreferences for wallet storage
  late SharedPreferences _prefs;
  
  /// Current user's wallet
  WalletModel? _currentWallet;
  
  /// Stream controller for wallet updates
  final StreamController<WalletModel> _walletStreamController = StreamController<WalletModel>.broadcast();
  
  /// Whether service is initialized
  bool _isInitialized = false;
  
  /// Get wallet update stream
  Stream<WalletModel> get walletUpdates => _walletStreamController.stream;
  
  /// Get current wallet (throws if not initialized)
  WalletModel get currentWallet {
    if (_currentWallet == null) {
      throw StateError('WalletService not initialized. Call initialize() first.');
    }
    return _currentWallet!;
  }
  
  /// Initialize wallet service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    
    _isInitialized = true;
  }
  
  /// Load or create wallet for user
  Future<WalletModel> loadWalletForUser(UserModel user) async {
    if (!_isInitialized) await initialize();
    
    // Check if wallet exists in SharedPreferences
    final walletKey = 'wallet_${user.id}';
    final walletJson = _prefs.getString(walletKey);
    
    if (walletJson != null) {
      // Parse existing wallet
      final walletData = jsonDecode(walletJson);
      _currentWallet = WalletModel.fromJson(walletData);
      
      // Check if daily earnings need reset (new day)
      _checkAndResetDailyEarnings();
    } else {
      // Create new wallet
      _currentWallet = WalletModel(
        userId: user.id,
        lastUpdated: DateTime.now(),
      );
      
      // Save to SharedPreferences
      await _saveWallet();
    }
    
    // Notify listeners
    _walletStreamController.add(_currentWallet!);
    
    return _currentWallet!;
  }
  
  /// Check and reset daily earnings if it's a new day
  void _checkAndResetDailyEarnings() {
    if (_currentWallet == null) return;
    
    final now = DateTime.now();
    final lastUpdated = _currentWallet!.lastUpdated;
    
    // Check if it's a new day
    if (now.year != lastUpdated.year ||
        now.month != lastUpdated.month ||
        now.day != lastUpdated.day) {
      
      // Reset daily earnings
      _currentWallet = _currentWallet!.copyWith(
        dailyEarnings: DailyEarnings(),
        lastUpdated: now,
      );
      
      // Apply daily streak reward if user has streak
      // This would need access to user's streak data
      
      // Save changes
      _saveWallet();
    }
  }
  
  /// Save current wallet to storage
  Future<void> _saveWallet() async {
    if (_currentWallet == null) return;
    
    // Save wallet to SharedPreferences
    final walletKey = 'wallet_${_currentWallet!.userId}';
    final walletJson = jsonEncode(_currentWallet!.toJson());
    await _prefs.setString(walletKey, walletJson);
    
    _walletStreamController.add(_currentWallet!);
  }
  
  /// ============================================
  /// MEDITATION FEATURE INTEGRATION
  /// ============================================
  
  /// Add coins from meditation session
  Future<void> addMeditationEarnings({
    required int minutes,
    required double focusScore, // 0.0 - 1.0
    required int streakDays,
  }) async {
    if (_currentWallet == null) return;
    
    // Calculate base earnings (1 coin per minute)
    int baseEarnings = minutes;
    
    // Focus bonus (up to 50% extra)
    int focusBonus = (baseEarnings * focusScore * 0.5).round();
    
    // Streak bonus
    int streakBonus = _currentWallet!.getDailyStreakBonus(streakDays);
    
    // Total earnings
    int totalEarnings = baseEarnings + focusBonus + streakBonus;
    
    // Calculate mindfulness tokens (1 token per 5 minutes of quality meditation)
    int mindfulnessTokens = (minutes * focusScore / 5).round();
    
    // Update wallet
    _currentWallet = _currentWallet!.copyWith(
      coins: _currentWallet!.coins + totalEarnings,
    );
    
    // Add coins transaction
    _currentWallet!.addCoins(
      totalEarnings,
      feature: 'meditation',
      description: 'Meditation session: ${minutes}min, focus: ${(focusScore * 100).toInt()}%',
    );
    
    // Add mindfulness tokens
    if (mindfulnessTokens > 0) {
      _currentWallet!.addMindfulnessTokens(
        mindfulnessTokens,
        meditationMinutes: minutes,
      );
    }
    
    // Apply daily streak reward
    _currentWallet!.applyDailyStreakReward(streakDays);
    
    await _saveWallet();
  }
  
  /// ============================================
  /// GARDEN FEATURE INTEGRATION
  /// ============================================
  
  /// Add coins from garden harvest
  Future<void> addGardenHarvestEarnings({
    required int baseReward,
    required double careQuality, // 0.0 - 1.0
    required int plantLevel,
    required bool isPerfectCare,
  }) async {
    if (_currentWallet == null) return;
    
    // Calculate quality bonus
    int qualityBonus = (baseReward * careQuality).round();
    
    // Level bonus (higher level plants give more)
    int levelBonus = plantLevel * 5;
    
    // Perfect care multiplier
    double multiplier = isPerfectCare ? 2.0 : 1.0;
    
    // Total earnings
    int totalEarnings = ((baseReward + qualityBonus + levelBonus) * multiplier).round();
    
    // Update wallet
    _currentWallet = _currentWallet!.copyWith(
      coins: _currentWallet!.coins + totalEarnings,
    );
    
    // Add transaction
    _currentWallet!.addCoins(
      totalEarnings,
      feature: 'garden',
      description: 'Plant harvest: level $plantLevel, quality: ${(careQuality * 100).toInt()}%',
    );
    
    await _saveWallet();
  }
  
  /// Spend coins in garden (planting, watering, etc.)
  Future<bool> spendGardenCoins(int amount, {String? description}) async {
    if (_currentWallet == null) return false;
    
    final success = _currentWallet!.spendCoins(
      amount,
      feature: 'garden',
      description: description ?? 'Garden expense',
    );
    
    if (success) {
      await _saveWallet();
    }
    
    return success;
  }
  
  /// ============================================
  /// COMMUNITY FEATURE INTEGRATION
  /// ============================================
  
  /// Add coins from community challenges
  Future<void> addCommunityChallengeEarnings({
    required int challengeReward,
    required String challengeName,
    required int rank, // 1st, 2nd, 3rd, etc.
  }) async {
    if (_currentWallet == null) return;
    
    // Rank bonus (1st place gets 50% extra, 2nd 25%, 3rd 10%)
    double rankMultiplier = switch (rank) {
      1 => 1.5,
      2 => 1.25,
      3 => 1.1,
      _ => 1.0,
    };
    
    int totalEarnings = (challengeReward * rankMultiplier).round();
    
    // Update wallet
    _currentWallet = _currentWallet!.copyWith(
      coins: _currentWallet!.coins + totalEarnings,
    );
    
    // Add transaction
    _currentWallet!.addCoins(
      totalEarnings,
      feature: 'community',
      description: 'Community challenge: $challengeName (rank: $rank)',
    );
    
    await _saveWallet();
  }
  
  /// Spend coins in community (gifts, etc.)
  Future<bool> spendCommunityCoins(int amount, {String? description}) async {
    if (_currentWallet == null) return false;
    
    final success = _currentWallet!.spendCoins(
      amount,
      feature: 'community',
      description: description ?? 'Community expense',
    );
    
    if (success) {
      await _saveWallet();
    }
    
    return success;
  }
  
  /// ============================================
  /// ACHIEVEMENTS FEATURE INTEGRATION
  /// ============================================
  
  /// Add coins from achievement unlock
  Future<void> addAchievementEarnings({
    required int achievementReward,
    required String achievementName,
    required String achievementTier, // bronze, silver, gold, platinum
  }) async {
    if (_currentWallet == null) return;
    
    // Tier multiplier
    double tierMultiplier = switch (achievementTier.toLowerCase()) {
      'bronze' => 1.0,
      'silver' => 1.5,
      'gold' => 2.0,
      'platinum' => 3.0,
      _ => 1.0,
    };
    
    int totalEarnings = (achievementReward * tierMultiplier).round();
    
    // Update wallet
    _currentWallet = _currentWallet!.copyWith(
      coins: _currentWallet!.coins + totalEarnings,
    );
    
    // Add transaction
    _currentWallet!.addCoins(
      totalEarnings,
      feature: 'achievements',
      description: 'Achievement: $achievementName ($achievementTier)',
    );
    
    await _saveWallet();
  }
  
  /// ============================================
  /// GENERAL WALLET OPERATIONS
  /// ============================================
  
  /// Check if user can afford a purchase
  bool canAfford(int coinsCost, {int premiumEnergyCost = 0}) {
    if (_currentWallet == null) return false;
    
    return _currentWallet!.coins >= coinsCost && 
           _currentWallet!.premiumEnergy >= premiumEnergyCost;
  }
  
  /// Get wallet balance
  int get coinsBalance => _currentWallet?.coins ?? 0;
  int get premiumEnergyBalance => _currentWallet?.premiumEnergy ?? 0;
  int get mindfulnessTokensBalance => _currentWallet?.mindfulnessTokens ?? 0;
  
  /// Get feature-specific earnings
  int getFeatureEarnings(String feature) {
    return _currentWallet?.getFeatureBalance(feature) ?? 0;
  }
  
  /// Get today's earnings
  int getTodayEarnings() {
    return _currentWallet?.getTodayEarnings() ?? 0;
  }
  
  /// Get wallet summary for UI
  Map<String, dynamic> getWalletSummary() {
    return _currentWallet?.getSummary() ?? {
      'coins': 0,
      'premiumEnergy': 0,
      'mindfulnessTokens': 0,
      'totalEarned': 0,
      'todayEarnings': 0,
      'featureBalances': {},
      'dailyStreakBonus': 0,
      'lifetimeStats': {},
    };
  }
  
  /// Convert mindfulness tokens to coins
  Future<bool> convertTokensToCoins(int tokens, {double exchangeRate = 10.0}) async {
    if (_currentWallet == null) return false;
    
    final success = _currentWallet!.convertTokensToCoins(tokens, exchangeRate: exchangeRate);
    
    if (success) {
      await _saveWallet();
    }
    
    return success;
  }
  
  /// Add premium energy (from purchases, rewards, etc.)
  Future<void> addPremiumEnergy(int amount, {required String source}) async {
    if (_currentWallet == null) return;
    
    _currentWallet!.addPremiumEnergy(amount, source: source);
    await _saveWallet();
  }
  
  /// Spend premium energy
  Future<bool> spendPremiumEnergy(int amount, {required String purpose}) async {
    if (_currentWallet == null) return false;
    
    final success = _currentWallet!.spendPremiumEnergy(amount, purpose: purpose);
    
    if (success) {
      await _saveWallet();
    }
    
    return success;
  }
  
  /// Get transaction history
  List<Transaction> getTransactionHistory({int limit = 50}) {
    if (_currentWallet == null) return [];
    
    final history = _currentWallet!.transactionHistory;
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return history.take(limit).toList();
  }
  
  /// Get recent transactions by feature
  List<Transaction> getTransactionsByFeature(String feature, {int limit = 20}) {
    if (_currentWallet == null) return [];
    
    return _currentWallet!.transactionHistory
        .where((t) => t.feature == feature)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }
  
  /// Reset wallet (for testing/debugging)
  Future<void> resetWallet() async {
    if (_currentWallet == null) return;
    
    _currentWallet = WalletModel(
      userId: _currentWallet!.userId,
      lastUpdated: DateTime.now(),
    );
    
    await _saveWallet();
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await _walletStreamController.close();
    // SharedPreferences doesn't need explicit closing
  }
  
  /// ============================================
  /// WALLET UI INTEGRATION HELPERS
  /// ============================================
  
  /// Format currency for display
  static String formatCurrency(int amount, {String currency = 'coins'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M $currency';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K $currency';
    }
    return '$amount $currency';
  }
  
  /// Get currency icon
  static String getCurrencyIcon(String currency) {
    return switch (currency) {
      'coins' => '🪙',
      'premiumEnergy' => '⚡',
      'mindfulnessTokens' => '🧠',
      _ => '💰',
    };
  }
  
  /// Get feature icon
  static String getFeatureIcon(String feature) {
    return switch (feature) {
      'meditation' => '🧘',
      'garden' => '🌿',
      'community' => '👥',
      'challenges' => '🏆',
      'achievements' => '⭐',
      'streak' => '🔥',
      _ => '📊',
    };
  }
  
  /// Get transaction type icon
  static String getTransactionTypeIcon(TransactionType type) {
    return switch (type) {
      TransactionType.earning => '➕',
      TransactionType.spending => '➖',
      TransactionType.premiumEnergy => '⚡',
      TransactionType.premiumEnergySpending => '⚡➖',
      TransactionType.mindfulnessToken => '🧠',
      TransactionType.conversion => '🔄',
    };
  }
}
