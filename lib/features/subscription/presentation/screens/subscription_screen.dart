import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/subscription/domain/models/subscription_models.dart';
import 'package:legalease/features/subscription/domain/providers/subscription_providers.dart';
import 'package:legalease/shared/widgets/branded_loading_indicator.dart';
import 'package:legalease/shared/widgets/error_state_widget.dart';
import 'package:legalease/shared/widgets/progress_overlay.dart';
import 'package:legalease/shared/widgets/toast_notification.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionScreenViewModelProvider.notifier).retry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.state));
    final offering = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.offering));
    final selectedPlan = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.selectedPlan));
    final isYearlySelected = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.isYearlySelected));
    final isPremiumUser = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.isPremiumUser));
    final errorMessage = ref.watch(subscriptionScreenViewModelProvider.select((s) => s.errorMessage));

    return Stack(
      children: [
        Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context, state, offering, selectedPlan, isYearlySelected, isPremiumUser, errorMessage),
        ),
        if (state == SubscriptionScreenState.purchasing ||
            state == SubscriptionScreenState.restoring)
          _buildLoadingOverlay(context),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('LegalEase Premium'),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, 
    SubscriptionScreenState state,
    dynamic offering,
    dynamic selectedPlan,
    bool isYearlySelected,
    bool isPremiumUser,
    String? errorMessage,
  ) {
    switch (state) {
      case SubscriptionScreenState.loading:
      case SubscriptionScreenState.initial:
        return _buildLoadingState(context);
      case SubscriptionScreenState.error:
        return _buildErrorState(context, errorMessage ?? 'Please check your connection and try again.');
      case SubscriptionScreenState.loaded:
      case SubscriptionScreenState.purchasing:
      case SubscriptionScreenState.restoring:
        return _buildContent(context, offering, selectedPlan, isYearlySelected, isPremiumUser);
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BrandedLoadingIndicator(size: LoadingSize.large),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Loading plans...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return ErrorStateWidget(
      type: ErrorType.server,
      message: errorMessage,
      onRetry: () {
        HapticFeedback.lightImpact();
        ref.read(subscriptionScreenViewModelProvider.notifier).retry();
      },
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return ProgressOverlay(
      isVisible: true,
      message: 'Processing purchase...',
    );
  }

  Widget _buildContent(
    BuildContext context, 
    dynamic offering,
    dynamic selectedPlan,
    bool isYearlySelected,
    bool isPremiumUser,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildHeroSection(context),
          const SizedBox(height: 24),
          _buildFeaturesList(context),
          const SizedBox(height: 24),
          _buildPlanToggle(context, isYearlySelected, offering, selectedPlan),
          const SizedBox(height: 16),
          _buildPlanCards(context, offering, selectedPlan, isYearlySelected),
          const SizedBox(height: 24),
          _buildCtaButton(context, selectedPlan),
          const SizedBox(height: 16),
          _buildFooter(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.workspace_premium,
            size: 40,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Unlock Premium Features',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Get unlimited access to all personas and advanced AI features',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final features = [
      {'icon': Icons.all_inclusive, 'text': 'Unlimited custom personas'},
      {'icon': Icons.folder_special, 'text': 'Access to all premium personas (Corporate Counsel, Assertive Advocate, Technical Analyst)'},
      {'icon': Icons.fast_forward, 'text': 'Priority AI processing'},
      {'icon': Icons.description, 'text': 'Advanced document analysis'},
      {'icon': Icons.share, 'text': 'Export and share features'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature['text'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlanToggle(
    BuildContext context, 
    bool isYearlySelected, 
    dynamic offering,
    dynamic selectedPlan,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleTab(
              context,
              label: 'Monthly',
              isSelected: !isYearlySelected,
              onTap: () {
                ref.read(subscriptionScreenViewModelProvider.notifier).togglePlanType(false);
              },
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildToggleTab(
                  context,
                  label: 'Yearly',
                  isSelected: isYearlySelected,
                  onTap: () {
                    ref.read(subscriptionScreenViewModelProvider.notifier).togglePlanType(true);
                  },
                ),
                if (offering?.yearlyPlan != null && offering?.monthlyPlan != null)
                  Positioned(
                    top: -8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Save 40%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildToggleTab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Widget _buildPlanCards(
    BuildContext context, 
    dynamic offering,
    dynamic selectedPlan,
    bool isYearlySelected,
  ) {
    if (offering == null) return const SizedBox.shrink();

    final plans = <SubscriptionPlan>[];
    if (isYearlySelected && offering.yearlyPlan != null) {
      plans.add(offering.yearlyPlan!);
    } else if (!isYearlySelected && offering.monthlyPlan != null) {
      plans.add(offering.monthlyPlan!);
    }

    if (plans.isEmpty) {
      return _buildNoPlansAvailable(context);
    }

    return Column(
      children: plans.map((plan) {
        final isSelected = selectedPlan?.id == plan.id;
        return _buildPlanCard(context, plan, isSelected);
      }).toList(),
    );
  }

  Widget _buildNoPlansAvailable(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No plans available at this time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, SubscriptionPlan plan, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(subscriptionScreenViewModelProvider.notifier).selectPlan(plan);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? colorScheme.onPrimaryContainer : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                          ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(plan.price, plan.currencyCode),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? colorScheme.onPrimaryContainer : null,
                      ),
                ),
                Text(
                  plan.durationMonths == 12 ? '/year' : '/month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                            : colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price, String currencyCode) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
    };
    final symbol = symbols[currencyCode] ?? currencyCode;
    return '$symbol${price.toStringAsFixed(2)}';
  }

  Widget _buildCtaButton(BuildContext context, dynamic selectedPlan) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: selectedPlan != null
            ? () async {
                HapticFeedback.mediumImpact();
                final success = await ref
                    .read(subscriptionScreenViewModelProvider.notifier)
                    .purchaseSubscription();
                if (success && mounted && context.mounted) {
                  HapticFeedback.heavyImpact();
                  ToastNotification.success(
                    context,
                    message: 'Welcome to Premium!',
                  );
                  context.pop(true);
                }
              }
            : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.mdAll,
          ),
        ),
        child: const Text(
          'Subscribe Now',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextButton(
          onPressed: () async {
            HapticFeedback.lightImpact();
            final success = await ref
                .read(subscriptionScreenViewModelProvider.notifier)
                .restorePurchases();
            if (mounted && context.mounted) {
              if (success) {
                ToastNotification.success(
                  context,
                  message: 'Purchases restored successfully!',
                );
              } else {
                ToastNotification.info(
                  context,
                  message: 'No purchases found to restore.',
                );
              }
            }
          },
          child: const Text('Restore Purchases'),
        ),
        const SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            children: [
              const TextSpan(text: 'By subscribing, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(color: colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // TODO: Navigate to terms
                  },
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(color: colorScheme.primary),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // TODO: Navigate to privacy policy
                  },
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Subscription auto-renews unless canceled at least 24 hours before the end of the current period.',
          textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
        ),
      ],
    );
  }
}
