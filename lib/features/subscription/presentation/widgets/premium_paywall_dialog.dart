import 'package:flutter/material.dart';

class PremiumPaywallDialog extends StatelessWidget {
  final String featureName;
  final List<String> benefits;
  final VoidCallback onUpgrade;
  final VoidCallback? onDismiss;

  const PremiumPaywallDialog({
    super.key,
    required this.featureName,
    required this.benefits,
    required this.onUpgrade,
    this.onDismiss,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String featureName,
    required List<String> benefits,
    required VoidCallback onUpgrade,
    VoidCallback? onDismiss,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PremiumPaywallDialog(
        featureName: featureName,
        benefits: benefits,
        onUpgrade: onUpgrade,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Premium Feature',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$featureName is available for premium subscribers',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitsList(colorScheme, textTheme),
                  const SizedBox(height: 24),
                  _buildUpgradeButton(colorScheme),
                  const SizedBox(height: 12),
                  _buildDismissButton(context, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 36,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                size: 20,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'PREMIUM',
                style: TextStyle(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: benefits
            .map((benefit) => _buildBenefitItem(benefit, colorScheme, textTheme))
            .toList(),
      ),
    );
  }

  Widget _buildBenefitItem(
    String benefit,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isFirst = benefits.indexOf(benefit) == 0;
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : 12),
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
              benefit,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onUpgrade,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.tertiary,
          foregroundColor: colorScheme.onTertiary,
        ),
        icon: const Icon(Icons.workspace_premium),
        label: const Text(
          'Upgrade to Premium',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context, ColorScheme colorScheme) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop(false);
        onDismiss?.call();
      },
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
      ),
      child: const Text('Maybe Later'),
    );
  }
}
