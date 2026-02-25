import 'package:flutter_test/flutter_test.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';

void main() {
  group('Subscription Models', () {
    group('Subscription', () {
      test('creates subscription with correct properties', () {
        final subscription = Subscription(
          id: 'sub-123',
          userId: 'user-456',
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.active,
          planId: 'monthly-premium',
          productId: 'com.legalease.premium.monthly',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 2, 1),
          willRenew: true,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.id, equals('sub-123'));
        expect(subscription.userId, equals('user-456'));
        expect(subscription.tier, equals(SubscriptionTier.premium));
        expect(subscription.status, equals(SubscriptionStatus.active));
        expect(subscription.willRenew, isTrue);
      });

      test('isActive returns true for active subscription', () {
        final subscription = Subscription(
          id: 'sub-123',
          userId: 'user-456',
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.active,
          planId: 'monthly-premium',
          productId: 'com.legalease.premium.monthly',
          startDate: DateTime(2024, 1, 1),
          willRenew: true,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.isActive, isTrue);
      });

      test('isActive returns false for inactive subscription', () {
        final subscription = Subscription(
          id: 'sub-123',
          userId: 'user-456',
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.expired,
          planId: 'monthly-premium',
          productId: 'com.legalease.premium.monthly',
          startDate: DateTime(2024, 1, 1),
          willRenew: false,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(subscription.isActive, isFalse);
      });
    });

    group('SubscriptionPlan', () {
      test('creates plan with correct properties', () {
        final plan = SubscriptionPlan(
          id: 'monthly-premium',
          tier: SubscriptionTier.premium,
          name: 'Premium Monthly',
          description: 'Full access to all features',
          price: 9.99,
          currencyCode: 'USD',
          durationMonths: 1,
          productId: 'com.legalease.premium.monthly',
          features: ['Unlimited scans', 'Priority support'],
        );

        expect(plan.id, equals('monthly-premium'));
        expect(plan.tier, equals(SubscriptionTier.premium));
        expect(plan.price, equals(9.99));
        expect(plan.durationMonths, equals(1));
        expect(plan.features.length, equals(2));
      });

      test('identifies annual plans by duration', () {
        final plan = SubscriptionPlan(
          id: 'yearly-premium',
          tier: SubscriptionTier.premium,
          name: 'Premium Yearly',
          description: 'Full access - annual',
          price: 99.99,
          currencyCode: 'USD',
          durationMonths: 12,
          productId: 'com.legalease.premium.yearly',
          features: [],
        );

        expect(plan.durationMonths, equals(12));
      });

      test('identifies monthly plans by duration', () {
        final plan = SubscriptionPlan(
          id: 'monthly-premium',
          tier: SubscriptionTier.premium,
          name: 'Premium Monthly',
          description: 'Full access - monthly',
          price: 9.99,
          currencyCode: 'USD',
          durationMonths: 1,
          productId: 'com.legalease.premium.monthly',
          features: [],
        );

        expect(plan.durationMonths, equals(1));
      });
    });

    group('SubscriptionTier', () {
      test('has expected values', () {
        expect(SubscriptionTier.values.length, equals(2));
        expect(SubscriptionTier.values, contains(SubscriptionTier.free));
        expect(SubscriptionTier.values, contains(SubscriptionTier.premium));
      });
    });

    group('SubscriptionStatus', () {
      test('has expected values', () {
        expect(SubscriptionStatus.values.length, equals(5));
        expect(SubscriptionStatus.values, contains(SubscriptionStatus.active));
        expect(SubscriptionStatus.values, contains(SubscriptionStatus.inactive));
        expect(SubscriptionStatus.values, contains(SubscriptionStatus.expired));
        expect(SubscriptionStatus.values, contains(SubscriptionStatus.cancelled));
        expect(SubscriptionStatus.values, contains(SubscriptionStatus.inGracePeriod));
      });
    });

    group('SubscriptionOffering', () {
      test('creates offering with plans', () {
        final monthlyPlan = SubscriptionPlan(
          id: 'monthly',
          tier: SubscriptionTier.premium,
          name: 'Monthly',
          description: 'Monthly plan',
          price: 9.99,
          currencyCode: 'USD',
          durationMonths: 1,
          productId: 'monthly',
          features: [],
        );

        final offering = SubscriptionOffering(
          identifier: 'default',
          description: 'Default offering',
          monthlyPlan: monthlyPlan,
        );

        expect(offering.identifier, equals('default'));
        expect(offering.monthlyPlan, isNotNull);
        expect(offering.yearlyPlan, isNull);
      });
    });
  });
}
