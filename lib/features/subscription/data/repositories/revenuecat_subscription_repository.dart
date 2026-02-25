import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/domain/repositories/subscription_repository.dart';

class RevenueCatSubscriptionRepository implements SubscriptionRepository {
  final String _apiKey;
  final FirebaseAuth _firebaseAuth;
  final StreamController<Subscription?> _subscriptionController =
      StreamController<Subscription?>.broadcast();
  Subscription? _cachedSubscription;

  RevenueCatSubscriptionRepository({
    required String apiKey,
    FirebaseAuth? firebaseAuth,
  })  : _apiKey = apiKey,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _initialize();
  }

  Future<void> _initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    final configuration = PurchasesConfiguration(_apiKey);
    await Purchases.configure(configuration);

    _firebaseAuth.authStateChanges().listen((user) async {
      if (user != null) {
        await Purchases.logIn(user.uid);
        await syncSubscriptionStatus();
      } else {
        await Purchases.logOut();
        _cachedSubscription = null;
        _subscriptionController.add(null);
      }
    });

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateSubscriptionFromCustomerInfo(customerInfo);
    });

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await Purchases.logIn(currentUser.uid);
      await syncSubscriptionStatus();
    }
  }

  void _updateSubscriptionFromCustomerInfo(CustomerInfo customerInfo) {
    final subscription = _mapCustomerInfoToSubscription(customerInfo);
    _cachedSubscription = subscription;
    _subscriptionController.add(subscription);
  }

  Subscription? _mapCustomerInfoToSubscription(CustomerInfo customerInfo) {
    final activeSubscriptions = customerInfo.activeSubscriptions;
    if (activeSubscriptions.isEmpty) {
      return null;
    }

    final productId = activeSubscriptions.first;
    final entitlements = customerInfo.entitlements;

    String? entitlementId;
    if (entitlements.active.isNotEmpty) {
      entitlementId = entitlements.active.keys.first;
    }

    final allExpirationDates = customerInfo.allExpirationDates;
    String? expiryDateStr;
    if (allExpirationDates.containsKey(productId)) {
      expiryDateStr = allExpirationDates[productId];
    }

    DateTime? endDate;
    if (expiryDateStr != null) {
      endDate = DateTime.tryParse(expiryDateStr);
    }

    final userId = _firebaseAuth.currentUser?.uid ?? 'unknown';

    return Subscription(
      id: customerInfo.originalAppUserId,
      userId: userId,
      tier: SubscriptionTier.premium,
      status: _determineSubscriptionStatus(customerInfo, productId),
      planId: entitlementId ?? productId,
      productId: productId,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: endDate,
      willRenew: !allExpirationDates.containsKey(productId) ||
          (endDate != null && endDate.isAfter(DateTime.now())),
      createdAt: DateTime.now(),
    );
  }

  SubscriptionStatus _determineSubscriptionStatus(
      CustomerInfo customerInfo, String productId) {
    if (customerInfo.activeSubscriptions.contains(productId)) {
      return SubscriptionStatus.active;
    }

    final allExpirationDates = customerInfo.allExpirationDates;
    final expiryDateStr = allExpirationDates[productId];
    if (expiryDateStr != null) {
      final expiryDate = DateTime.tryParse(expiryDateStr);
      if (expiryDate != null) {
        final now = DateTime.now();
        if (expiryDate.isBefore(now)) {
          return SubscriptionStatus.expired;
        }
      }
    }

    return SubscriptionStatus.inactive;
  }

  @override
  Stream<Subscription?> get subscriptionStream =>
      _subscriptionController.stream;

  @override
  Future<Subscription?> getCurrentSubscription() async {
    if (_cachedSubscription != null) {
      return _cachedSubscription;
    }
    await syncSubscriptionStatus();
    return _cachedSubscription;
  }

  @override
  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final offerings = await Purchases.getOfferings();
      final plans = <SubscriptionPlan>[];

      for (final offering in offerings.all.values) {
        final monthly = offering.monthly;
        if (monthly != null) {
          plans.add(_mapPackageToPlan(monthly, SubscriptionTier.premium));
        }

        final annual = offering.annual;
        if (annual != null) {
          plans.add(_mapPackageToPlan(annual, SubscriptionTier.premium));
        }
      }

      return plans;
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  SubscriptionPlan _mapPackageToPlan(Package package, SubscriptionTier tier) {
    final product = package.storeProduct;
    final priceString = product.priceString;
    final price = double.tryParse(priceString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    int durationMonths = 1;
    if (package.packageType == PackageType.annual) {
      durationMonths = 12;
    }

    return SubscriptionPlan(
      id: package.identifier,
      tier: tier,
      name: product.title,
      description: product.description,
      price: price,
      currencyCode: product.currencyCode,
      durationMonths: durationMonths,
      productId: product.identifier,
      features: [],
    );
  }

  @override
  Future<SubscriptionOffering?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current == null) {
        return null;
      }

      SubscriptionPlan? monthlyPlan;
      SubscriptionPlan? yearlyPlan;

      if (current.monthly != null) {
        monthlyPlan = _mapPackageToPlan(current.monthly!, SubscriptionTier.premium);
      }

      if (current.annual != null) {
        yearlyPlan = _mapPackageToPlan(current.annual!, SubscriptionTier.premium);
      }

      return SubscriptionOffering(
        identifier: current.identifier,
        description: current.serverDescription,
        monthlyPlan: monthlyPlan,
        yearlyPlan: yearlyPlan,
      );
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  @override
  Future<void> purchasePlan(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      Package? targetPackage;

      for (final offering in offerings.all.values) {
        final packages = offering.availablePackages;
        for (final package in packages) {
          if (package.storeProduct.identifier == productId ||
              package.identifier == productId) {
            targetPackage = package;
            break;
          }
        }
        if (targetPackage != null) break;
      }

      if (targetPackage == null) {
        throw const SubscriptionException(
          'Plan not found',
          'plan-not-found',
        );
      }

      final customerInfo = await Purchases.purchasePackage(targetPackage);
      _updateSubscriptionFromCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateSubscriptionFromCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  @override
  Future<bool> isPremiumUser() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  @override
  Future<void> syncSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionFromCustomerInfo(customerInfo);
    } on PlatformException catch (e) {
      throw _handlePlatformError(e);
    }
  }

  SubscriptionException _handlePlatformError(PlatformException e) {
    final errorCode = e.code;
    
    switch (errorCode) {
      case '1':
      case 'PURCHASE_CANCELLED_ERROR':
        return const SubscriptionException(
          'Purchase was cancelled',
          'purchase-cancelled',
        );
      case '2':
      case 'STORE_PROBLEM_ERROR':
        return const SubscriptionException(
          'Store error occurred',
          'store-error',
        );
      case '3':
      case 'PURCHASE_NOT_ALLOWED_ERROR':
        return const SubscriptionException(
          'Purchase not allowed',
          'purchase-not-allowed',
        );
      case '4':
      case 'PAYMENT_PENDING_ERROR':
        return const SubscriptionException(
          'Payment is pending',
          'payment-pending',
        );
      case '5':
      case 'PRODUCT_NOT_AVAILABLE_FOR_PURCHASE_ERROR':
        return const SubscriptionException(
          'Product not available for purchase',
          'product-not-available',
        );
      case '10':
      case 'NETWORK_ERROR':
        return const SubscriptionException(
          'Network error. Check your connection',
          'network-error',
        );
      case '11':
      case 'INVALID_CREDENTIALS_ERROR':
        return const SubscriptionException(
          'Invalid credentials',
          'invalid-credentials',
        );
      case '15':
      case 'OPERATION_ALREADY_IN_PROGRESS_ERROR':
        return const SubscriptionException(
          'Operation already in progress',
          'operation-in-progress',
        );
      case '0':
      case 'UNKNOWN_ERROR':
        return const SubscriptionException(
          'An unknown error occurred',
          'unknown-error',
        );
      default:
        return SubscriptionException(
          e.message ?? 'An error occurred',
          errorCode,
        );
    }
  }

  void dispose() {
    _subscriptionController.close();
  }
}
