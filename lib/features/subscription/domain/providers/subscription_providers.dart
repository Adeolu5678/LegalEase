import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:legalease/features/subscription/data/repositories/revenuecat_subscription_repository.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:legalease/features/subscription/domain/services/subscription_service.dart';

enum SubscriptionScreenState {
  initial,
  loading,
  loaded,
  purchasing,
  restoring,
  error,
}

class SubscriptionScreenData {
  final SubscriptionScreenState state;
  final SubscriptionOffering? offering;
  final SubscriptionPlan? selectedPlan;
  final bool isYearlySelected;
  final String? errorMessage;
  final bool isPremiumUser;

  const SubscriptionScreenData({
    this.state = SubscriptionScreenState.initial,
    this.offering,
    this.selectedPlan,
    this.isYearlySelected = true,
    this.errorMessage,
    this.isPremiumUser = false,
  });

  SubscriptionScreenData copyWith({
    SubscriptionScreenState? state,
    SubscriptionOffering? offering,
    SubscriptionPlan? selectedPlan,
    bool? isYearlySelected,
    String? errorMessage,
    bool? isPremiumUser,
  }) {
    return SubscriptionScreenData(
      state: state ?? this.state,
      offering: offering ?? this.offering,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isYearlySelected: isYearlySelected ?? this.isYearlySelected,
      errorMessage: errorMessage,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
    );
  }

  SubscriptionPlan? get currentPlan {
    if (isYearlySelected) {
      return offering?.yearlyPlan ?? offering?.monthlyPlan;
    }
    return offering?.monthlyPlan ?? offering?.yearlyPlan;
  }
}

class SubscriptionScreenViewModel extends StateNotifier<SubscriptionScreenData> {
  final SubscriptionService _subscriptionService;

  SubscriptionScreenViewModel(Ref ref, this._subscriptionService)
      : super(const SubscriptionScreenData()) {
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    state = state.copyWith(state: SubscriptionScreenState.loading);

    try {
      final offering = await _subscriptionService.getOfferings();
      final isPremium = await _subscriptionService.checkPremiumAccess();

      SubscriptionPlan? initialPlan;
      if (offering?.yearlyPlan != null) {
        initialPlan = offering!.yearlyPlan;
      } else if (offering?.monthlyPlan != null) {
        initialPlan = offering!.monthlyPlan;
        state = state.copyWith(isYearlySelected: false);
      }

      state = state.copyWith(
        state: SubscriptionScreenState.loaded,
        offering: offering,
        selectedPlan: initialPlan,
        isPremiumUser: isPremium,
      );
    } catch (e) {
      state = state.copyWith(
        state: SubscriptionScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void togglePlanType(bool isYearly) {
    final plan = isYearly
        ? state.offering?.yearlyPlan
        : state.offering?.monthlyPlan;
    state = state.copyWith(
      isYearlySelected: isYearly,
      selectedPlan: plan,
    );
  }

  void selectPlan(SubscriptionPlan plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  Future<bool> purchaseSubscription() async {
    if (state.selectedPlan == null) return false;

    state = state.copyWith(state: SubscriptionScreenState.purchasing);

    final result =
        await _subscriptionService.purchaseSubscription(state.selectedPlan!);

    if (result.success) {
      state = state.copyWith(
        state: SubscriptionScreenState.loaded,
        isPremiumUser: true,
      );
      return true;
    } else {
      state = state.copyWith(
        state: SubscriptionScreenState.loaded,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(state: SubscriptionScreenState.restoring);

    final result = await _subscriptionService.restorePurchases();

    if (result.success && result.hasRestoredPremium) {
      state = state.copyWith(
        state: SubscriptionScreenState.loaded,
        isPremiumUser: true,
      );
      return true;
    } else {
      state = state.copyWith(state: SubscriptionScreenState.loaded);
      return false;
    }
  }

  Future<void> retry() async {
    await _loadOfferings();
  }
}

final subscriptionConfigProvider = Provider<String>((ref) {
  final apiKey = dotenv.env['REVENUECAT_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    debugPrint('[SubscriptionConfig] Warning: RevenueCat API key not configured. Set REVENUECAT_API_KEY in .env file.');
  }
  return apiKey;
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final apiKey = ref.watch(subscriptionConfigProvider);
  return RevenueCatSubscriptionRepository(apiKey: apiKey);
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionService(repository: repository);
});

final subscriptionScreenViewModelProvider =
    StateNotifierProvider.autoDispose<SubscriptionScreenViewModel, SubscriptionScreenData>(
        (ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionScreenViewModel(ref, service);
});

final isPremiumUserProvider = Provider<bool>((ref) {
  final data = ref.watch(subscriptionScreenViewModelProvider);
  return data.isPremiumUser;
});

final currentSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getCurrentSubscription();
});
