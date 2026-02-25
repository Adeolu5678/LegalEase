import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/domain/repositories/subscription_repository.dart';

class SubscriptionPurchaseResult {
  final bool success;
  final String? errorMessage;
  final String? errorCode;
  final Subscription? subscription;
  final bool userCancelled;

  const SubscriptionPurchaseResult._({
    required this.success,
    this.errorMessage,
    this.errorCode,
    this.subscription,
    this.userCancelled = false,
  });

  factory SubscriptionPurchaseResult.success({Subscription? subscription}) {
    return SubscriptionPurchaseResult._(
      success: true,
      subscription: subscription,
    );
  }

  factory SubscriptionPurchaseResult.failure({
    required String errorMessage,
    String? errorCode,
    bool userCancelled = false,
  }) {
    return SubscriptionPurchaseResult._(
      success: false,
      errorMessage: errorMessage,
      errorCode: errorCode,
      userCancelled: userCancelled,
    );
  }

  factory SubscriptionPurchaseResult.cancelled() {
    return const SubscriptionPurchaseResult._(
      success: false,
      errorMessage: 'Purchase was cancelled',
      userCancelled: true,
    );
  }
}

class RestoreResult {
  final bool success;
  final String? errorMessage;
  final List<Subscription> restoredSubscriptions;
  final bool hasRestoredPremium;

  const RestoreResult._({
    required this.success,
    this.errorMessage,
    this.restoredSubscriptions = const [],
    this.hasRestoredPremium = false,
  });

  factory RestoreResult.success({
    List<Subscription> restoredSubscriptions = const [],
  }) {
    return RestoreResult._(
      success: true,
      restoredSubscriptions: restoredSubscriptions,
      hasRestoredPremium: restoredSubscriptions.any((s) => s.isActive),
    );
  }

  factory RestoreResult.noPurchases() {
    return const RestoreResult._(
      success: true,
      restoredSubscriptions: [],
      hasRestoredPremium: false,
    );
  }

  factory RestoreResult.failure({required String errorMessage}) {
    return RestoreResult._(
      success: false,
      errorMessage: errorMessage,
    );
  }
}

class SubscriptionService {
  final SubscriptionRepository _repository;
  StreamSubscription<Subscription?>? _subscriptionSubscription;
  StreamController<SubscriptionStatus>? _statusController;
  bool _isInitialized = false;

  SubscriptionService({required SubscriptionRepository repository})
      : _repository = repository;

  Stream<SubscriptionStatus> get statusStream {
    _statusController ??= StreamController<SubscriptionStatus>.broadcast(
      onCancel: () {
        if (_statusController?.hasListener == false) {
          _statusController?.close();
          _statusController = null;
        }
      },
    );
    return _statusController!.stream;
  }

  Future<void> initialize(String revenueCatApiKey) async {
    if (_isInitialized) {
      debugPrint('[SubscriptionService] Already initialized');
      return;
    }

    try {
      debugPrint('[SubscriptionService] Initializing with RevenueCat');
      await _repository.syncSubscriptionStatus();
      _isInitialized = true;
      debugPrint('[SubscriptionService] Initialization complete');

      _subscriptionSubscription = _repository.subscriptionStream.listen(
        (subscription) {
          final status = subscription?.status ?? SubscriptionStatus.inactive;
          _statusController?.add(status);
          debugPrint('[SubscriptionService] Status updated: $status');
        },
        onError: (error) {
          debugPrint('[SubscriptionService] Subscription stream error: $error');
        },
      );
    } on SubscriptionException catch (e) {
      debugPrint('[SubscriptionService] Initialization failed: ${e.message}');
      throw SubscriptionException(
        _getUserFriendlyInitError(e.code),
        e.code,
      );
    }
  }

  Future<SubscriptionOffering?> getOfferings() async {
    _ensureInitialized();

    try {
      debugPrint('[SubscriptionService] Fetching offerings');
      final offering = await _repository.getOfferings();
      if (offering != null) {
        debugPrint(
          '[SubscriptionService] Found offering: ${offering.identifier}',
        );
      } else {
        debugPrint('[SubscriptionService] No offerings available');
      }
      return offering;
    } on SubscriptionException catch (e) {
      debugPrint(
        '[SubscriptionService] Failed to fetch offerings: ${e.message}',
      );
      return null;
    }
  }

  Future<SubscriptionPurchaseResult> purchaseSubscription(
    SubscriptionPlan plan,
  ) async {
    _ensureInitialized();

    try {
      debugPrint(
        '[SubscriptionService] Starting purchase for plan: ${plan.name}',
      );

      await _repository.purchasePlan(plan.productId);

      final subscription = await _repository.getCurrentSubscription();
      debugPrint('[SubscriptionService] Purchase successful');
      return SubscriptionPurchaseResult.success(subscription: subscription);
    } on SubscriptionException catch (e) {
      debugPrint('[SubscriptionService] Purchase failed: ${e.message}');
      return SubscriptionPurchaseResult.failure(
        errorMessage: _getUserFriendlyPurchaseError(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('[SubscriptionService] Unexpected purchase error: $e');
      return SubscriptionPurchaseResult.failure(
        errorMessage: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  Future<RestoreResult> restorePurchases() async {
    _ensureInitialized();

    try {
      debugPrint('[SubscriptionService] Restoring purchases');

      await _repository.restorePurchases();

      final subscription = await _repository.getCurrentSubscription();

      if (subscription == null || !subscription.isActive) {
        debugPrint('[SubscriptionService] No purchases to restore');
        return RestoreResult.noPurchases();
      }

      debugPrint(
        '[SubscriptionService] Restored subscription: ${subscription.productId}',
      );

      return RestoreResult.success(
        restoredSubscriptions: [subscription],
      );
    } on SubscriptionException catch (e) {
      debugPrint('[SubscriptionService] Restore failed: ${e.message}');
      return RestoreResult.failure(
        errorMessage: _getUserFriendlyRestoreError(e.code),
      );
    } catch (e) {
      debugPrint('[SubscriptionService] Unexpected restore error: $e');
      return RestoreResult.failure(
        errorMessage: 'An unexpected error occurred while restoring purchases.',
      );
    }
  }

  Future<bool> checkPremiumAccess() async {
    _ensureInitialized();

    try {
      debugPrint('[SubscriptionService] Checking premium access');
      final hasAccess = await _repository.isPremiumUser();
      debugPrint('[SubscriptionService] Premium access: $hasAccess');
      return hasAccess;
    } on SubscriptionException catch (e) {
      debugPrint(
        '[SubscriptionService] Failed to check premium access: ${e.message}',
      );
      return false;
    }
  }

  Future<void> handleDeepLink(String url) async {
    _ensureInitialized();

    try {
      debugPrint('[SubscriptionService] Handling deep link: $url');
      await _repository.syncSubscriptionStatus();
      debugPrint('[SubscriptionService] Deep link handled successfully');
    } on SubscriptionException catch (e) {
      debugPrint(
        '[SubscriptionService] Deep link handling failed: ${e.message}',
      );
      rethrow;
    }
  }

  Future<Subscription?> getCurrentSubscription() async {
    _ensureInitialized();

    try {
      return _repository.getCurrentSubscription();
    } on SubscriptionException catch (e) {
      debugPrint(
        '[SubscriptionService] Failed to get current subscription: ${e.message}',
      );
      return null;
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    _ensureInitialized();

    try {
      return _repository.getAvailablePlans();
    } on SubscriptionException catch (e) {
      debugPrint(
        '[SubscriptionService] Failed to get available plans: ${e.message}',
      );
      return [];
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const SubscriptionException(
        'SubscriptionService not initialized. Call initialize() first.',
        'NOT_INITIALIZED',
      );
    }
  }

  String _getUserFriendlyInitError(String? code) {
    switch (code) {
      case 'INVALID_API_KEY':
        return 'Invalid subscription configuration. Please contact support.';
      case 'NETWORK_ERROR':
        return 'Unable to connect to subscription service. Check your internet connection.';
      default:
        return 'Failed to initialize subscription service. Please restart the app.';
    }
  }

  String _getUserFriendlyPurchaseError(String? code) {
    switch (code) {
      case 'PAYMENT_PENDING':
        return 'Your payment is pending approval. You will be notified once approved.';
      case 'PAYMENT_DECLINED':
        return 'Payment was declined. Please check your payment method and try again.';
      case 'PRODUCT_NOT_FOUND':
        return 'This subscription is temporarily unavailable. Please try again later.';
      case 'NETWORK_ERROR':
        return 'Unable to connect to the store. Check your internet connection.';
      case 'STORE_PROBLEM':
        return 'There was a problem with the app store. Please try again later.';
      case 'ALREADY_SUBSCRIBED':
        return 'You already have an active subscription.';
      case 'INSUFFICIENT_FUNDS':
        return 'Insufficient funds. Please check your payment method.';
      case 'PURCHASE_CANCELLED':
        return 'Purchase was cancelled.';
      default:
        return 'Purchase failed. Please try again or contact support.';
    }
  }

  String _getUserFriendlyRestoreError(String? code) {
    switch (code) {
      case 'NETWORK_ERROR':
        return 'Unable to connect to the store. Check your internet connection.';
      case 'STORE_PROBLEM':
        return 'There was a problem with the app store. Please try again later.';
      default:
        return 'Unable to restore purchases. Please try again or contact support.';
    }
  }

  void dispose() {
    _subscriptionSubscription?.cancel();
    _subscriptionSubscription = null;
    _statusController?.close();
    _statusController = null;
    _isInitialized = false;
    debugPrint('[SubscriptionService] Disposed');
  }
}
