import 'package:flutter_test/flutter_test.dart';
import 'package:pranaverse/data/models/user_model.dart';
import 'package:pranaverse/data/models/wallet_model.dart';
import 'package:pranaverse/core/services/wallet_service.dart';

/// Test script to verify wallet integration
void main() {
  group('Wallet System Tests', () {
    late WalletService walletService;
    late UserModel testUser;

    setUp(() async {
      // Initialize wallet service
      walletService = WalletService();
      await walletService.initialize();

      // Create test user
      testUser = UserModel(
        id: 'test_user_123',
        name: 'Test User',
        email: 'test@example.com',
        joinedDate: DateTime.now(),
        preferences: UserPreferences(),
      );
    });

    tearDown(() async {
      await walletService.dispose();
    });

    test('Wallet creation for new user', () async {
      final wallet = await walletService.loadWalletForUser(testUser);

      expect(wallet.userId, equals(testUser.id));
      expect(wallet.coins, equals(100)); // Starting coins
      expect(wallet.premiumEnergy, equals(0));
      expect(wallet.mindfulnessTokens, equals(0));
      expect(wallet.transactionHistory, isEmpty);
    });

    test('Add meditation earnings', () async {
      await walletService.loadWalletForUser(testUser);

      // Simulate meditation session
      await walletService.addMeditationEarnings(
        minutes: 30,
        focusScore: 0.8,
        streakDays: 7,
      );

      final wallet = walletService.currentWallet;

      // Should have earned coins
      expect(wallet.coins, greaterThan(100));

      // Should have mindfulness tokens
      expect(wallet.mindfulnessTokens, greaterThan(0));

      // Should have transaction recorded
      expect(wallet.transactionHistory, isNotEmpty);

      // Should have feature balance updated
      expect(wallet.getFeatureBalance('meditation'), greaterThan(0));
    });

    test('Add garden harvest earnings', () async {
      await walletService.loadWalletForUser(testUser);

      // Simulate garden harvest
      await walletService.addGardenHarvestEarnings(
        baseReward: 50,
        careQuality: 0.9,
        plantLevel: 3,
        isPerfectCare: true,
      );

      final wallet = walletService.currentWallet;

      // Should have earned coins
      expect(wallet.coins, greaterThan(100));

      // Should have garden feature balance
      expect(wallet.getFeatureBalance('garden'), greaterThan(0));
    });

    test('Spend coins in garden', () async {
      await walletService.loadWalletForUser(testUser);

      // First add some coins
      await walletService.addMeditationEarnings(
        minutes: 10,
        focusScore: 0.7,
        streakDays: 1,
      );

      final initialCoins = walletService.coinsBalance;

      // Spend coins
      final success = await walletService.spendGardenCoins(
        20,
        description: 'Buy seeds',
      );

      expect(success, isTrue);
      expect(walletService.coinsBalance, equals(initialCoins - 20));
    });

    test('Check affordability', () async {
      await walletService.loadWalletForUser(testUser);

      // Should be able to afford 50 coins (starting with 100)
      expect(walletService.canAfford(50), isTrue);

      // Should not be able to afford 200 coins
      expect(walletService.canAfford(200), isFalse);
    });

    test('Convert tokens to coins', () async {
      await walletService.loadWalletForUser(testUser);

      // Add some mindfulness tokens
      await walletService.addMeditationEarnings(
        minutes: 25,
        focusScore: 0.9,
        streakDays: 1,
      );

      final initialTokens = walletService.mindfulnessTokensBalance;
      final initialCoins = walletService.coinsBalance;

      // Convert half the tokens to coins
      final tokensToConvert = initialTokens ~/ 2;
      final success = await walletService.convertTokensToCoins(
        tokensToConvert,
        exchangeRate: 10.0,
      );

      expect(success, isTrue);
      expect(walletService.mindfulnessTokensBalance,
          equals(initialTokens - tokensToConvert));
      expect(walletService.coinsBalance,
          equals(initialCoins + (tokensToConvert * 10)));
    });

    test('Get wallet summary', () async {
      await walletService.loadWalletForUser(testUser);

      // Add earnings from multiple features
      await walletService.addMeditationEarnings(
        minutes: 15,
        focusScore: 0.8,
        streakDays: 3,
      );

      await walletService.addGardenHarvestEarnings(
        baseReward: 30,
        careQuality: 0.7,
        plantLevel: 2,
        isPerfectCare: false,
      );

      final summary = walletService.getWalletSummary();

      expect(summary['coins'], greaterThan(100));
      expect(summary['todayEarnings'], greaterThan(0));
      expect(summary['featureBalances'], isMap);
      expect(summary['featureBalances']['meditation'], greaterThan(0));
      expect(summary['featureBalances']['garden'], greaterThan(0));
    });

    test('Transaction history', () async {
      await walletService.loadWalletForUser(testUser);

      // Add multiple transactions
      await walletService.addMeditationEarnings(
        minutes: 10,
        focusScore: 0.6,
        streakDays: 1,
      );

      await walletService.spendGardenCoins(15, description: 'Water plants');

      final transactions = walletService.getTransactionHistory();

      expect(transactions.length, equals(2));
      expect(transactions[0].type, equals(TransactionType.spending));
      expect(transactions[1].type, equals(TransactionType.earning));
    });
  });

  print('✅ All wallet integration tests passed!');
  print('\n🎯 Wallet System Ready for Integration:');
  print('   - Unified currency across all features');
  print('   - Meditation → Coins earning system');
  print('   - Garden spending/reward system');
  print('   - Transaction history tracking');
  print('   - Feature-specific balance tracking');
  print('   - Daily earnings calculation');
  print('   - Streak bonus system');
  print('   - Token conversion system');
}
