// lib/features/subscription/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:pranaverse/presentation/providers/subscription_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setState(() {
          _packages = offerings.current!.availablePackages;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading packages: $e');
    }
  }

  Future<void> _purchasePackage(Package package) async {
    try {
      final purchaseResult =
          await Purchases.purchase(PurchaseParams.package(package));
      final customerInfo = purchaseResult.customerInfo;
      if (!mounted) return;
      if (customerInfo.entitlements.all['premium']?.isActive == true) {
        context.read<SubscriptionProvider>().updateSubscriptionStatus(true);
        _showPurchaseSuccess();
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final purchaserInfo = await Purchases.restorePurchases();
      if (!mounted) return;
      if (purchaserInfo.entitlements.all['premium']?.isActive == true) {
        context.read<SubscriptionProvider>().updateSubscriptionStatus(true);
        _showRestoreSuccess();
      } else {
        _showNoPurchases();
      }
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }
// ================== MISSING METHODS ==================

  void _showRestoreSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Restored'),
        content: const Text(
          'Your premium subscription has been successfully restored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNoPurchases() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ℹ️ No Purchases Found'),
        content: const Text(
          'No previous premium purchases were found for this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _manageSubscription() {
    // RevenueCat-recommended way
    Purchases.showInAppMessages();
  }

  String _getBillingPeriod(Package package) {
    final period = package.storeProduct.subscriptionPeriod;
    if (period == null || period.isEmpty) return 'One-time purchase';
    // ISO 8601 duration strings: P1W, P1M, P1Y, P7D, etc.
    if (period.contains('Y')) return 'Billed yearly';
    if (period.contains('M')) return 'Billed monthly';
    if (period.contains('W')) return 'Billed weekly';
    if (period.contains('D')) {
      final days = int.tryParse(period.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (days == 7) return 'Billed weekly';
      return 'Billed every $days day(s)';
    }
    return 'Billed periodically';
  }

  void _showPurchaseSuccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Welcome to Premium!'),
        content: const Text(
          'Thank you for subscribing! All premium features are now unlocked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/main'),
        ),
        actions: [
          if (subscriptionProvider.isSubscribed)
            IconButton(
              onPressed: _manageSubscription,
              icon: const Icon(Icons.settings),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(subscriptionProvider),
    );
  }

  Widget _buildContent(SubscriptionProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade900],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 80,
                  color: Colors.yellow,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unlock Full Potential',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Get unlimited access to all meditation content, advanced features, and ad-free experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Features List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PREMIUM FEATURES',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                _buildFeatureItem(
                  Icons.library_music,
                  'Unlimited Meditation Library',
                  'Access 100+ guided meditations',
                ),
                _buildFeatureItem(
                  Icons.spa,
                  'Advanced Garden Features',
                  'Exclusive plants and garden themes',
                ),
                _buildFeatureItem(
                  Icons.offline_bolt,
                  'Offline Access',
                  'Download meditations for offline use',
                ),
                _buildFeatureItem(
                  Icons.remove_circle_outline,
                  'Ad-Free Experience',
                  'No interruptions during meditation',
                ),
                _buildFeatureItem(
                  Icons.auto_awesome,
                  'Premium Sounds & Music',
                  'Exclusive sound therapy tracks',
                ),
              ],
            ),
          ),

          // Pricing Plans
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Text(
                  'CHOOSE YOUR PLAN',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                ..._packages.map((package) {
                  return _buildPricingCard(package);
                }),
              ],
            ),
          ),

          // Restore Purchases
          TextButton(
            onPressed: _restorePurchases,
            child: const Text('Restore Purchases'),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildPricingCard(Package package) {
    final isMostPopular = package.identifier.contains('monthly');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isMostPopular ? Colors.purple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMostPopular ? Colors.purple : Colors.grey.shade300,
          width: isMostPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isMostPopular)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  package.storeProduct.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  package.storeProduct.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Text(
                  package.storeProduct.priceString,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getBillingPeriod(package),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _purchasePackage(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'GET STARTED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
