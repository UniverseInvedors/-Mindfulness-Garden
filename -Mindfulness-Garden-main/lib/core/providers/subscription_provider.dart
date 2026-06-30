import 'package:flutter_riverpod/flutter_riverpod.dart';

// Subscription State
class SubscriptionState {
  final bool isSubscribed;
  final String subscriptionType;
  final DateTime? subscriptionEndDate;
  final List<String> entitlements;
  final bool isLoading;
  final String? error;

  SubscriptionState({
    this.isSubscribed = false,
    this.subscriptionType = '',
    this.subscriptionEndDate,
    this.entitlements = const [],
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isSubscribed,
    String? subscriptionType,
    DateTime? subscriptionEndDate,
    List<String>? entitlements,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      entitlements: entitlements ?? this.entitlements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool hasEntitlement(String entitlement) {
    return entitlements.contains(entitlement);
  }

  bool isPremiumUser() {
    return isSubscribed || hasEntitlement('premium');
  }
}

// Subscription StateNotifier
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier() : super(SubscriptionState());

  // Getters
  bool get isSubscribed => state.isSubscribed;
  String get subscriptionType => state.subscriptionType;
  DateTime? get subscriptionEndDate => state.subscriptionEndDate;
  List<String> get entitlements => state.entitlements;

  // Load subscription status
  Future<void> loadSubscriptionStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // This would typically load from RevenueCat or your backend
      // For now, we'll use mock data
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      state = state.copyWith(
        isSubscribed: false,
        subscriptionType: '',
        subscriptionEndDate: null,
        entitlements: [],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Update subscription status
  void updateSubscriptionStatus(bool subscribed) {
    state = state.copyWith(isSubscribed: subscribed);
  }

  // Update subscription details
  void updateSubscriptionDetails({
    String? type,
    DateTime? endDate,
    List<String>? entitlements,
  }) {
    state = state.copyWith(
      subscriptionType: type ?? state.subscriptionType,
      subscriptionEndDate: endDate ?? state.subscriptionEndDate,
      entitlements: entitlements ?? state.entitlements,
    );
  }
}

// Providers
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

// Convenience providers
final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isSubscribed;
});

final isPremiumUserProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionProvider).isPremiumUser();
});

final entitlementsProvider = Provider<List<String>>((ref) {
  return ref.watch(subscriptionProvider).entitlements;
});
