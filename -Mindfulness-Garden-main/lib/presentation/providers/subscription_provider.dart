import 'package:flutter/foundation.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isSubscribed = false;
  String _subscriptionType = '';
  DateTime? _subscriptionEndDate;
  List<String> _entitlements = [];

  bool get isSubscribed => _isSubscribed;
  String get subscriptionType => _subscriptionType;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  List<String> get entitlements => _entitlements;

  Future<void> loadSubscriptionStatus() async {
    // This would typically load from RevenueCat or your backend
    // For now, we'll use mock data
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data
    _isSubscribed = false;
    _subscriptionType = '';
    _subscriptionEndDate = null;
    _entitlements = [];

    notifyListeners();
  }

  void updateSubscriptionStatus(bool subscribed) {
    _isSubscribed = subscribed;
    notifyListeners();
  }

  void updateSubscriptionDetails({
    String? type,
    DateTime? endDate,
    List<String>? entitlements,
  }) {
    if (type != null) _subscriptionType = type;
    if (endDate != null) _subscriptionEndDate = endDate;
    if (entitlements != null) _entitlements = entitlements;
    notifyListeners();
  }

  bool hasEntitlement(String entitlement) {
    return _entitlements.contains(entitlement);
  }

  bool isPremiumUser() {
    return _isSubscribed || hasEntitlement('premium');
  }
}
