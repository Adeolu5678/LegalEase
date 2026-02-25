import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/presentation/providers/subscription_management_providers.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() => _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState extends ConsumerState<SubscriptionManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionManagementViewModelProvider.notifier).loadSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SubscriptionManagementState state) {
    switch (state.status) {
      case SubscriptionManagementStatus.initial:
      case SubscriptionManagementStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SubscriptionManagementStatus.error:
        return _buildErrorState(state.errorMessage ?? 'An error occurred');
      case SubscriptionManagementStatus.loaded:
        if (state.subscription == null || !state.subscription!.isActive) {
          if (state.subscription?.status == SubscriptionStatus.inGracePeriod) {
            return _buildGracePeriodContent(state);
          }
          return _buildNoSubscriptionContent();
        }
        return _buildActiveSubscriptionContent(state);
    }
  }

  Widget _buildErrorState(String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(subscriptionManagementViewModelProvider.notifier).loadSubscription();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSubscriptionContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscription',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'You don\'t have an active subscription. Subscribe to unlock premium features.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/subscription'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View Plans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGracePeriodContent(SubscriptionManagementState state) {
    final subscription = state.subscription!;
    final endDate = subscription.endDate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGracePeriodBanner(endDate),
          const SizedBox(height: 16),
          _buildCurrentPlanCard(subscription, state.plan),
          const SizedBox(height: 24),
          _buildResubscribeSection(),
        ],
      ),
    );
  }

  Widget _buildGracePeriodBanner(DateTime? endDate) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = endDate != null ? DateFormat('MMMM d, yyyy').format(endDate) : 'soon';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your subscription ends on $formattedDate',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionContent(SubscriptionManagementState state) {
    final subscription = state.subscription!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPlanCard(subscription, state.plan),
          const SizedBox(height: 24),
          _buildBenefitsSection(),
          const SizedBox(height: 24),
          _buildManagementOptions(state),
          const SizedBox(height: 24),
          _buildRestorePurchasesSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanCard(Subscription subscription, SubscriptionPlan? plan) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 16,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan?.name ?? 'Premium Plan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _getBillingPeriod(plan),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              subscription.willRenew ? 'Next billing date' : 'Expires on',
              _formatDate(subscription.endDate),
            ),
            if (plan != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.attach_money,
                'Price',
                '${plan.currencyCode} ${plan.price.toStringAsFixed(2)}/${plan.durationMonths == 12 ? 'year' : 'month'}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final benefits = [
      'Unlimited document scans',
      'Advanced AI analysis',
      'Priority support',
      'Custom personas',
      'Export to PDF',
      'No ads',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Benefits',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            benefit,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                Text(
                  'You have access to all premium features',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementOptions(SubscriptionManagementState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Subscription',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: state.isLoading ? null : () => _handleChangePlan(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.swap_horiz),
              SizedBox(width: 8),
              Text('Change Plan'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: state.isLoading ? null : () => _showCancelDialog(state),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_outlined),
              SizedBox(width: 8),
              Text('Cancel Subscription'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResubscribeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton(
          onPressed: () => context.push('/subscription'),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh),
              SizedBox(width: 8),
              Text('Resubscribe'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestorePurchasesSection() {
    final state = ref.watch(subscriptionManagementViewModelProvider);

    return Column(
      children: [
        TextButton.icon(
          onPressed: state.isLoading ? null : () => _handleRestorePurchases(),
          icon: const Icon(Icons.restore),
          label: const Text('Restore Purchases'),
        ),
      ],
    );
  }

  void _handleChangePlan() {
    context.push('/subscription');
  }

  Future<void> _handleRestorePurchases() async {
    final result = await ref.read(subscriptionManagementViewModelProvider.notifier).restorePurchases();

    if (!mounted) return;

    if (result.success) {
      if (result.hasRestoredPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No previous purchases found'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to restore purchases'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCancelDialog(SubscriptionManagementState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final subscription = state.subscription;
    final endDate = subscription?.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.error,
          size: 48,
        ),
        title: const Text('Cancel Subscription?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to cancel your subscription?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'You will lose access to:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Unlimited document scans\n• Advanced AI analysis\n• Custom personas\n• Priority support',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                  ),
                  if (endDate != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Access ends on ${DateFormat('MMMM d, yyyy').format(endDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCancelSubscription();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCancelSubscription() async {
    final success = await ref.read(subscriptionManagementViewModelProvider.notifier).cancelSubscription();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subscription cancelled successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to cancel subscription'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getBillingPeriod(SubscriptionPlan? plan) {
    if (plan == null) return 'Subscription';
    if (plan.durationMonths == 12) return 'Billed annually';
    if (plan.durationMonths == 1) return 'Billed monthly';
    return 'Billed every ${plan.durationMonths} months';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
