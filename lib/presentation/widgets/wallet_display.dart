import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/presentation/providers/wallet_provider.dart';

/// Wallet display widget for showing currency balances across the app
class WalletDisplay extends StatelessWidget {
  /// Whether to show detailed view or compact view
  final bool detailed;
  
  /// Whether to show feature earnings breakdown
  final bool showBreakdown;
  
  /// Callback when wallet is tapped
  final VoidCallback? onTap;
  
  /// Custom styling
  final Color? backgroundColor;
  final Color? textColor;
  final double? elevation;
  
  const WalletDisplay({
    super.key,
    this.detailed = false,
    this.showBreakdown = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.elevation,
  });
  
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final wallet = walletProvider.wallet;
    
    if (wallet == null) {
      return _buildLoadingState();
    }
    
    final summary = wallet.getSummary();
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? 2.0,
        color: backgroundColor ?? Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: detailed 
              ? _buildDetailedView(context, wallet, summary)
              : _buildCompactView(context, wallet, summary),
        ),
      ),
    );
  }
  
  /// Build loading state
  Widget _buildLoadingState() {
    return Card(
      elevation: elevation ?? 2.0,
      color: backgroundColor ?? Colors.black.withOpacity(0.7),
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 8),
            Text(
              'Loading wallet...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build compact wallet view
  Widget _buildCompactView(BuildContext context, WalletModel wallet, Map<String, dynamic> summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCurrencyChip('🪙', '${summary['coins']}', 'Coins'),
        _buildCurrencyChip('⚡', '${summary['premiumEnergy']}', 'Energy'),
        _buildCurrencyChip('🧠', '${summary['mindfulnessTokens']}', 'Tokens'),
      ],
    );
  }
  
  /// Build detailed wallet view
  Widget _buildDetailedView(BuildContext context, WalletModel wallet, Map<String, dynamic> summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '💰 Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Today: +${summary['todayEarnings']}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Main currencies
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailedCurrency('🪙', 'Coins', summary['coins'] as int),
            _buildDetailedCurrency('⚡', 'Energy', summary['premiumEnergy'] as int),
            _buildDetailedCurrency('🧠', 'Tokens', summary['mindfulnessTokens'] as int),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Today's earnings breakdown
        if (showBreakdown) ...[
          const Divider(color: Colors.white30),
          const SizedBox(height: 8),
          const Text(
            'Today\'s Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _buildEarningsBreakdown(summary),
        ],
        
        // Feature earnings
        if (showBreakdown) ...[
          const SizedBox(height: 12),
          const Text(
            'Feature Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          _buildFeatureEarnings(summary['featureBalances'] as Map<String, int>),
        ],
      ],
    );
  }
  
  /// Build currency chip for compact view
  Widget _buildCurrencyChip(String icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: (textColor ?? Colors.white).withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  /// Build detailed currency display
  Widget _buildDetailedCurrency(String icon, String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          WalletService.formatCurrency(value, currency: ''),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Build earnings breakdown
  Widget _buildEarningsBreakdown(Map<String, dynamic> summary) {
    final dailyEarnings = summary['dailyEarnings'] as Map<String, dynamic>? ?? {};
    
    return Column(
      children: [
        _buildEarningRow('🧘 Meditation', dailyEarnings['meditationEarnings'] ?? 0),
        _buildEarningRow('🌿 Garden', dailyEarnings['gardenEarnings'] ?? 0),
        _buildEarningRow('👥 Community', dailyEarnings['communityEarnings'] ?? 0),
        _buildEarningRow('🏆 Challenges', dailyEarnings['challengeEarnings'] ?? 0),
        _buildEarningRow('⭐ Achievements', dailyEarnings['achievementEarnings'] ?? 0),
        _buildEarningRow('🔥 Streak', dailyEarnings['streakBonus'] ?? 0),
      ],
    );
  }
  
  /// Build feature earnings breakdown
  Widget _buildFeatureEarnings(Map<String, int> featureBalances) {
    final entries = featureBalances.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: entries.map((entry) {
        return _buildFeatureRow(entry.key, entry.value);
      }).toList(),
    );
  }
  
  /// Build earning row
  Widget _buildEarningRow(String label, int value) {
    if (value <= 0) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          Text(
            '+$value',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build feature row
  Widget _buildFeatureRow(String feature, int value) {
    final icon = WalletService.getFeatureIcon(feature);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                feature.capitalize(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            WalletService.formatCurrency(value, currency: ''),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wallet button for quick access
class WalletButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  
  const WalletButton({
    super.key,
    this.onPressed,
    this.size = 40.0,
  });
  
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final coins = walletProvider.coinsBalance;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.white30),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🪙',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                WalletService.formatCurrency(coins, currency: ''),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wallet transaction list
class WalletTransactionList extends StatelessWidget {
  final int limit;
  
  const WalletTransactionList({
    super.key,
    this.limit = 10,
  });
  
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final transactions = walletProvider.getTransactionHistory(limit: limit);
    
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions yet',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(Transaction transaction) {
    final icon = WalletService.getTransactionTypeIcon(transaction.type);
    final isEarning = transaction.type == TransactionType.earning;
    final isSpending = transaction.type == TransactionType.spending;
    
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isEarning 
              ? Colors.green.withOpacity(0.2)
              : isSpending
                ? Colors.red.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      title: Text(
        transaction.description ?? 'Transaction',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatTransactionTime(transaction.timestamp),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${isEarning ? '+' : '-'}${transaction.amount}',
        style: TextStyle(
          color: isEarning ? Colors.greenAccent : Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _formatTransactionTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
