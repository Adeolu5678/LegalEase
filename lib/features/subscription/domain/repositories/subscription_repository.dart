import 'package:legalease/features/subscription/domain/models/subscription_models.dart';

abstract class SubscriptionRepository {
  Stream<Subscription?> get subscriptionStream;

  Future<Subscription?> getCurrentSubscription();

  Future<List<SubscriptionPlan>> getAvailablePlans();

  Future<SubscriptionOffering?> getOfferings();

  Future<void> purchasePlan(String productId);

  Future<void> restorePurchases();

  Future<bool> isPremiumUser();

  Future<void> syncSubscriptionStatus();
}

class SubscriptionException implements Exception {
  final String message;
  final String code;

  const SubscriptionException(this.message, this.code);

  @override
  String toString() => 'SubscriptionException: $message (code: $code)';
}
