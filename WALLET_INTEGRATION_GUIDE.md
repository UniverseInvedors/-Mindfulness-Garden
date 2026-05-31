# Unified Wallet System Integration Guide

## 🎯 **Overview**

I've implemented a **unified wallet system** that works across all game features with proper money logic tied to user profiles. The system allows users to:

1. **Earn coins from meditation** based on minutes and focus quality
2. **Spend coins in the garden** for planting, watering, and upgrades
3. **Earn from community challenges** with rank-based bonuses
4. **Get achievement rewards** with tier-based multipliers
5. **Track all transactions** with detailed history
6. **Convert mindfulness tokens to coins**
7. **Get daily streak bonuses**

## 🏗️ **Architecture**

### **Core Components:**

1. **`WalletModel`** - Unified wallet data model with all currencies
2. **`WalletService`** - Service layer for wallet operations
3. **`WalletProvider`** - Provider for state management
4. **`WalletDisplay`** - UI components for displaying wallet

### **Currencies:**

- **🪙 Coins** - Main currency for all features
- **⚡ Premium Energy** - Special currency for premium features
- **🧠 Mindfulness Tokens** - Earned from meditation, convertible to coins

## 🔧 **Integration Steps**

### **1. Update Main App**

Already done in `main.dart`:
- Registered Hive adapters for wallet models
- Added `WalletService` and `WalletProvider` to MultiProvider
- Set up `ChangeNotifierProxyProvider` to initialize wallet when user is available

### **2. Update User Models**

Already updated:
- `UserModel` now has `coins`, `premiumEnergy`, `mindfulnessTokens` fields
- `UserProfile` model updated for consistency

### **3. Using Wallet in Features**

#### **Meditation Feature:**

```dart
// After meditation session
final walletProvider = context.read<WalletProvider>();
await walletProvider.addMeditationEarnings(
  minutes: sessionMinutes,
  focusScore: focusScore, // 0.0 - 1.0
  streakDays: userStreakDays,
);
```

#### **Garden Feature:**

```dart
// When harvesting a plant
final walletProvider = context.read<WalletProvider>();
await walletProvider.addGardenHarvestEarnings(
  baseReward: 50,
  careQuality: 0.85, // 0.0 - 1.0
  plantLevel: 3,
  isPerfectCare: true,
);

// When spending coins in garden
final canAfford = walletProvider.canAfford(10);
if (canAfford) {
  await walletProvider.spendGardenCoins(
    10,
    description: 'Plant seeds',
  );
}
```

#### **Community Feature:**

```dart
// When completing a challenge
final walletProvider = context.read<WalletProvider>();
await walletProvider.addCommunityChallengeEarnings(
  challengeReward: 100,
  challengeName: '7-Day Mindfulness',
  rank: 1, // 1st place
);
```

#### **Achievements Feature:**

```dart
// When unlocking achievement
final walletProvider = context.read<WalletProvider>();
await walletProvider.addAchievementEarnings(
  achievementReward: 50,
  achievementName: 'First Meditation',
  achievementTier: 'bronze', // bronze, silver, gold, platinum
);
```

### **4. Display Wallet in UI**

#### **Compact View:**
```dart
WalletDisplay(
  detailed: false,
  onTap: () => _showWalletDetails(context),
)
```

#### **Detailed View:**
```dart
WalletDisplay(
  detailed: true,
  showBreakdown: true,
  backgroundColor: Colors.black.withOpacity(0.8),
)
```

#### **Wallet Button:**
```dart
WalletButton(
  onPressed: () => _showWalletDetails(context),
  size: 40.0,
)
```

#### **Transaction History:**
```dart
WalletTransactionList(
  limit: 10,
)
```

## 💰 **Earning Formulas**

### **Meditation Earnings:**
```
Base: 1 coin per minute
Focus Bonus: up to 50% extra based on focus score (0.0-1.0)
Streak Bonus: 10 + (streakDays * 5) coins
Mindfulness Tokens: 1 token per 5 minutes of quality meditation
```

### **Garden Harvest Earnings:**
```
Base Reward: plantLevel * 20
Care Bonus: baseReward * careQuality
Level Bonus: plantLevel * 5
Perfect Care Multiplier: 2.0x if perfect care
```

### **Community Challenge Earnings:**
```
Rank Multipliers:
  1st Place: 1.5x
  2nd Place: 1.25x
  3rd Place: 1.1x
  Others: 1.0x
```

### **Achievement Earnings:**
```
Tier Multipliers:
  Bronze: 1.0x
  Silver: 1.5x
  Gold: 2.0x
  Platinum: 3.0x
```

## 📊 **Wallet Statistics**

The wallet tracks:
- **Daily earnings** by feature
- **Lifetime statistics** (total earned/spent)
- **Feature-specific balances**
- **Transaction history** with timestamps
- **Net worth** calculation

## 🔄 **Data Flow**

```
User Action → Feature Logic → WalletProvider → WalletService → Hive Storage
      ↓
  UI Update ← WalletProvider ← Wallet Updates
```

## 🧪 **Testing Integration**

### **Check Wallet Initialization:**
```dart
// In your feature screen
@override
void initState() {
  super.initState();
  // Ensure wallet is initialized
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userProvider = context.read<UserProvider>();
    final walletProvider = context.read<WalletProvider>();
    if (userProvider.currentUser != null) {
      walletProvider.initializeWallet(userProvider.currentUser!);
    }
  });
}
```

### **Handle Loading States:**
```dart
final walletProvider = context.watch<WalletProvider>();

if (walletProvider.isLoading) {
  return CircularProgressIndicator();
}

if (walletProvider.error != null) {
  return Text('Error: ${walletProvider.error}');
}

// Use wallet data
final coins = walletProvider.coinsBalance;
```

## 🎮 **Example: Complete Garden Integration**

```dart
class GardenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness Garden'),
        actions: [
          // Wallet button in app bar
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: WalletButton(
              onPressed: () => _showWalletDialog(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Compact wallet display at top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WalletDisplay(
              detailed: false,
              onTap: () => _showWalletDialog(context),
            ),
          ),
          
          Expanded(
            child: YourGardenContent(),
          ),
        ],
      ),
    );
  }
  
  void _showWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Your Wallet'),
        content: SizedBox(
          width: double.maxFinite,
          child: WalletDisplay(
            detailed: true,
            showBreakdown: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _harvestPlant(BuildContext context, Plant plant) async {
    final walletProvider = context.read<WalletProvider>();
    
    // Calculate earnings
    final earnings = calculateHarvestEarnings(plant);
    
    // Add to wallet
    await walletProvider.addGardenHarvestEarnings(
      baseReward: earnings.base,
      careQuality: plant.careQuality,
      plantLevel: plant.level,
      isPerfectCare: plant.isPerfectCare,
    );
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🌿 Harvested! +${earnings.total} coins'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

## 🔒 **Security Considerations**

1. **Server-side validation** for premium currency transactions
2. **Anti-cheat measures** for earning rates
3. **Backup and sync** with cloud storage
4. **Transaction signing** for premium purchases

## 📈 **Analytics Integration**

The wallet system provides data for:
- **Revenue analytics** (coins earned/spent per feature)
- **User engagement** (daily active wallet usage)
- **Feature popularity** (which features generate most coins)
- **Conversion rates** (token to coin conversions)

## 🚀 **Next Steps**

1. **Implement cloud sync** for wallet data
2. **Add premium purchase flow** for premium energy
3. **Create wallet settings** (privacy, transaction limits)
4. **Add gift system** for sending coins to friends
5. **Implement wallet backup/restore**

## 🆘 **Troubleshooting**

### **Wallet not initializing:**
- Check Hive adapters are registered
- Verify user is logged in before initializing wallet
- Check for Hive box opening errors

### **Transactions not saving:**
- Ensure `_saveWallet()` is called after modifications
- Check Hive storage permissions
- Verify transaction limit isn't exceeded

### **UI not updating:**
- Use `context.watch<WalletProvider>()` not `context.read<WalletProvider>()`
- Ensure `notifyListeners()` is called in provider
- Check for exceptions in wallet operations

## ✅ **Benefits Achieved**

1. **Single source of truth** for all currency across the app
2. **Consistent earning/spending logic** across all features
3. **Detailed transaction history** for user transparency
4. **Real-time updates** with provider pattern
5. **Offline support** with Hive persistence
6. **Extensible architecture** for new currencies/features

The unified wallet system ensures that users have a seamless experience earning and spending coins across all mindfulness activities, creating a cohesive economic ecosystem that rewards consistent practice and engagement.