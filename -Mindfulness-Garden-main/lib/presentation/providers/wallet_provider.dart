import 'package:flutter/material.dart';
import 'package:pranaverse/core/services/wallet_service.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/models/wallet_model.dart';

/// Provider that manages the unified wallet across all game features
class WalletProvider extends ChangeNotifier {
  final WalletService _walletService;
  
  /// Current wallet
  WalletModel? _wallet;
  
  /// Whether wallet is loading
  bool _isLoading = false;
  
  /// Error message if any
  String? _error;
  
  WalletProvider(this._walletService) {
    // Listen to wallet updates
    _walletService.walletUpdates.listen((wallet) {
      _wallet = wallet;
      notifyListeners();
    });
  }
  
  /// Get current wallet
  WalletModel? get wallet => _wallet;
  
  /// Get wallet loading state
  bool get isLoading => _isLoading;
  
  /// Get error message
  String? get error => _error;
  
  /// Get coins balance
  int get coinsBalance => _wallet?.coins ?? 0;
  
  /// Get premium energy balance
  int get premiumEnergyBalance => _wallet?.premiumEnergy ?? 0;
  
  /// Get mindfulness tokens balance
  int get mindfulnessTokensBalance => _wallet?.mindfulnessTokens ?? 0;
  
  /// Initialize wallet for user
  Future<void> initializeWallet(UserModel user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _walletService.loadWalletForUser(user);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize wallet: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// ============================================
  /// MEDITATION INTEGRATION
  /// ============================================
  
  /// Add earnings from meditation session
  Future<void> addMeditationEarnings({
    required int minutes,
    required double focusScore,
    required int streakDays,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.addMeditationEarnings(
        minutes: minutes,
        focusScore: focusScore,
        streakDays: streakDays,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add meditation earnings: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// ============================================
  /// GARDEN INTEGRATION
  /// ============================================
  
  /// Add earnings from garden harvest
  Future<void> addGardenHarvestEarnings({
    required int baseReward,
    required double careQuality,
    required int plantLevel,
    required bool isPerfectCare,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.addGardenHarvestEarnings(
        baseReward: baseReward,
        careQuality: careQuality,
        plantLevel: plantLevel,
        isPerfectCare: isPerfectCare,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add garden earnings: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// Spend coins in garden
  Future<bool> spendGardenCoins(int amount, {String? description}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _walletService.spendGardenCoins(
        amount,
        description: description,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to spend garden coins: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// ============================================
  /// COMMUNITY INTEGRATION
  /// ============================================
  
  /// Add earnings from community challenge
  Future<void> addCommunityChallengeEarnings({
    required int challengeReward,
    required String challengeName,
    required int rank,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.addCommunityChallengeEarnings(
        challengeReward: challengeReward,
        challengeName: challengeName,
        rank: rank,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add community earnings: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// Spend coins in community
  Future<bool> spendCommunityCoins(int amount, {String? description}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _walletService.spendCommunityCoins(
        amount,
        description: description,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to spend community coins: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// ============================================
  /// ACHIEVEMENTS INTEGRATION
  /// ============================================
  
  /// Add earnings from achievement
  Future<void> addAchievementEarnings({
    required int achievementReward,
    required String achievementName,
    required String achievementTier,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.addAchievementEarnings(
        achievementReward: achievementReward,
        achievementName: achievementName,
        achievementTier: achievementTier,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add achievement earnings: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// ============================================
  /// GENERAL WALLET OPERATIONS
  /// ============================================
  
  /// Check if user can afford a purchase
  bool canAfford(int coinsCost, {int premiumEnergyCost = 0}) {
    return _walletService.canAfford(coinsCost, premiumEnergyCost: premiumEnergyCost);
  }
  
  /// Convert mindfulness tokens to coins
  Future<bool> convertTokensToCoins(int tokens, {double exchangeRate = 10.0}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _walletService.convertTokensToCoins(
        tokens,
        exchangeRate: exchangeRate,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to convert tokens: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Add premium energy
  Future<void> addPremiumEnergy(int amount, {required String source}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.addPremiumEnergy(amount, source: source);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to add premium energy: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// Spend premium energy
  Future<bool> spendPremiumEnergy(int amount, {required String purpose}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await _walletService.spendPremiumEnergy(
        amount,
        purpose: purpose,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to spend premium energy: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Get wallet summary
  Map<String, dynamic> getWalletSummary() {
    return _walletService.getWalletSummary();
  }
  
  /// Get transaction history
  List<Transaction> getTransactionHistory({int limit = 50}) {
    return _walletService.getTransactionHistory(limit: limit);
  }
  
  /// Get transactions by feature
  List<Transaction> getTransactionsByFeature(String feature, {int limit = 20}) {
    return _walletService.getTransactionsByFeature(feature, limit: limit);
  }
  
  /// Get today's earnings
  int getTodayEarnings() {
    return _walletService.getTodayEarnings();
  }
  
  /// Get feature earnings
  int getFeatureEarnings(String feature) {
    return _walletService.getFeatureEarnings(feature);
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Reset wallet (for testing)
  Future<void> resetWallet() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _walletService.resetWallet();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reset wallet: $e';
      notifyListeners();
      rethrow;
    }
  }
  
  /// Dispose
  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }
}
