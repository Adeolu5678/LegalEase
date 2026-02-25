import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:legalease/features/subscription/domain/services/subscription_service.dart';
import 'package:legalease/features/subscription/data/repositories/revenuecat_subscription_repository.dart';

enum SubscriptionManagementStatus {
  initial,
  loading,
  loaded,
  error,
}

class SubscriptionManagementState {
  final SubscriptionManagementStatus status;
  final Subscription? subscription;
  final SubscriptionPlan? plan;
  final String? errorMessage;
  final bool isLoading;

  const SubscriptionManagementState({
    this.status = SubscriptionManagementStatus.initial,
    this.subscription,
    this.plan,
    this.errorMessage,
    this.isLoading = false,
  });

  SubscriptionManagementState copyWith({
    SubscriptionManagementStatus? status,
    Subscription? subscription,
    SubscriptionPlan? plan,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SubscriptionManagementState(
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      plan: plan ?? this.plan,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SubscriptionManagementViewModel extends StateNotifier<SubscriptionManagementState> {
  final SubscriptionService _subscriptionService;
  final Ref _ref;

  SubscriptionManagementViewModel(this._ref, this._subscriptionService)
      : super(const SubscriptionManagementState());

  Future<void> loadSubscription() async {
    state = state.copyWith(
      status: SubscriptionManagementStatus.loading,
      isLoading: true,
    );

    try {
      final subscription = await _subscriptionService.getCurrentSubscription();
      SubscriptionPlan? plan;

      if (subscription != null) {
        final plans = await _subscriptionService.getAvailablePlans();
        plan = plans.where((p) => p.productId == subscription.productId).firstOrNull;
      }

      state = state.copyWith(
        status: SubscriptionManagementStatus.loaded,
        subscription: subscription,
        plan: plan,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: SubscriptionManagementStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = _ref.read(subscriptionRepositoryProvider);
      await repository.syncSubscriptionStatus();
      await loadSubscription();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<RestoreResult> restorePurchases() async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _subscriptionService.restorePurchases();
      await loadSubscription();
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return RestoreResult.failure(errorMessage: e.toString());
    }
  }
}

const _revenueCatApiKey = String.fromEnvironment(
  'REVENUECAT_API_KEY',
  defaultValue: 'your_revenuecat_api_key_here',
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return RevenueCatSubscriptionRepository(apiKey: _revenueCatApiKey);
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionService(repository: repository);
});

final subscriptionManagementViewModelProvider =
    StateNotifierProvider<SubscriptionManagementViewModel, SubscriptionManagementState>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionManagementViewModel(ref, service);
});
