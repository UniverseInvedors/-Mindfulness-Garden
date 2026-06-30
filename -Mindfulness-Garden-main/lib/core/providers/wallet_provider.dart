import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/services/wallet_service.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/models/wallet_model.dart';

// Wallet State
class WalletState {
  final WalletModel? wallet;
  final bool isLoading;
  final String? error;

  WalletState({
    this.wallet,
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    WalletModel? wallet,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Wallet StateNotifier
class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(WalletState()) {
    _walletService.walletUpdates.listen((wallet) {
      state = state.copyWith(wallet: wallet);
    });
  }

  // Getters
  WalletModel? get wallet => state.wallet;
  bool get isLoading => state.isLoading;
  int get coinsBalance => state.wallet?.coins ?? 0;
  int get premiumEnergyBalance => state.wallet?.premiumEnergy ?? 0;
  int get mindfulnessTokensBalance => state.wallet?.mindfulnessTokens ?? 0;

  // Initialize wallet for user
  Future<void> initializeWallet(UserModel user) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _walletService.loadWalletForUser(user);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize wallet: $e',
      );
      rethrow;
    }
  }

  // Meditation Integration
  Future<void> addMeditationEarnings({
    required int minutes,
    required double focusScore,
    required int streakDays,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.addMeditationEarnings(
        minutes: minutes,
        focusScore: focusScore,
        streakDays: streakDays,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add meditation earnings: $e',
      );
      rethrow;
    }
  }

  // Garden Integration
  Future<void> addGardenHarvestEarnings({
    required int baseReward,
    required double careQuality,
    required int plantLevel,
    required bool isPerfectCare,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.addGardenHarvestEarnings(
        baseReward: baseReward,
        careQuality: careQuality,
        plantLevel: plantLevel,
        isPerfectCare: isPerfectCare,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add garden earnings: $e',
      );
      rethrow;
    }
  }

  Future<bool> spendGardenCoins(int amount, {String? description}) async {
    try {
      state = state.copyWith(isLoading: true);
      final success = await _walletService.spendGardenCoins(
        amount,
        description: description,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to spend garden coins: $e',
      );
      return false;
    }
  }

  // Community Integration
  Future<void> addCommunityChallengeEarnings({
    required int challengeReward,
    required String challengeName,
    required int rank,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.addCommunityChallengeEarnings(
        challengeReward: challengeReward,
        challengeName: challengeName,
        rank: rank,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add community earnings: $e',
      );
      rethrow;
    }
  }

  Future<bool> spendCommunityCoins(int amount, {String? description}) async {
    try {
      state = state.copyWith(isLoading: true);
      final success = await _walletService.spendCommunityCoins(
        amount,
        description: description,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to spend community coins: $e',
      );
      return false;
    }
  }

  // Achievements Integration
  Future<void> addAchievementEarnings({
    required int achievementReward,
    required String achievementName,
    required String achievementTier,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.addAchievementEarnings(
        achievementReward: achievementReward,
        achievementName: achievementName,
        achievementTier: achievementTier,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add achievement earnings: $e',
      );
      rethrow;
    }
  }

  // General Wallet Operations
  bool canAfford(int coinsCost, {int premiumEnergyCost = 0}) {
    return _walletService.canAfford(coinsCost, premiumEnergyCost: premiumEnergyCost);
  }

  Future<bool> convertTokensToCoins(int tokens, {double exchangeRate = 10.0}) async {
    try {
      state = state.copyWith(isLoading: true);
      final success = await _walletService.convertTokensToCoins(
        tokens,
        exchangeRate: exchangeRate,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to convert tokens: $e',
      );
      return false;
    }
  }

  Future<void> addPremiumEnergy(int amount, {required String source}) async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.addPremiumEnergy(amount, source: source);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add premium energy: $e',
      );
      rethrow;
    }
  }

  Future<bool> spendPremiumEnergy(int amount, {required String purpose}) async {
    try {
      state = state.copyWith(isLoading: true);
      final success = await _walletService.spendPremiumEnergy(
        amount,
        purpose: purpose,
      );
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to spend premium energy: $e',
      );
      return false;
    }
  }

  Map<String, dynamic> getWalletSummary() {
    return _walletService.getWalletSummary();
  }

  List<Transaction> getTransactionHistory({int limit = 50}) {
    return _walletService.getTransactionHistory(limit: limit);
  }

  List<Transaction> getTransactionsByFeature(String feature, {int limit = 20}) {
    return _walletService.getTransactionsByFeature(feature, limit: limit);
  }

  int getTodayEarnings() {
    return _walletService.getTodayEarnings();
  }

  int getFeatureEarnings(String feature) {
    return _walletService.getFeatureEarnings(feature);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> resetWallet() async {
    try {
      state = state.copyWith(isLoading: true);
      await _walletService.resetWallet();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to reset wallet: $e',
      );
      rethrow;
    }
  }

  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }
}

// Providers
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final service = ref.watch(walletServiceProvider);
  return WalletNotifier(service);
});

// Convenience providers
final walletDataProvider = Provider<WalletModel?>((ref) {
  return ref.watch(walletProvider).wallet;
});

final coinsBalanceProvider = Provider<int>((ref) {
  return ref.watch(walletProvider).coinsBalance;
});

final premiumEnergyBalanceProvider = Provider<int>((ref) {
  return ref.watch(walletProvider).premiumEnergyBalance;
});

final mindfulnessTokensBalanceProvider = Provider<int>((ref) {
  return ref.watch(walletProvider).mindfulnessTokensBalance;
});
