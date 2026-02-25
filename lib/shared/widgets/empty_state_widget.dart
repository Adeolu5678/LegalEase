import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? customIllustration;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. ${description ?? ''}',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customIllustration ??
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ).animate().scale(
                        duration: AppAnimation.medium,
                        curve: AppAnimation.easeOutCubic,
                      ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ],
              if (onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAction!();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel ?? 'Get Started'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              ],
              if (onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSecondaryAction!();
                  },
                  child: Text(secondaryActionLabel ?? 'Learn More'),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyDocumentsState extends StatelessWidget {
  final VoidCallback? onScanDocument;

  const EmptyDocumentsState({
    super.key,
    this.onScanDocument,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.description_outlined,
      title: 'No Documents Yet',
      description: 'Scan your first legal document to get started with AI-powered analysis.',
      actionLabel: 'Scan Document',
      onAction: onScanDocument,
    );
  }
}

class EmptyChatState extends StatelessWidget {
  final VoidCallback? onStartChat;

  const EmptyChatState({
    super.key,
    this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Start a Conversation',
      description: 'Ask questions about your legal documents and get instant, accurate answers.',
      actionLabel: 'Start Chat',
      onAction: onStartChat,
    );
  }
}

class EmptyPersonasState extends StatelessWidget {
  final VoidCallback? onCreatePersona;

  const EmptyPersonasState({
    super.key,
    this.onCreatePersona,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.person_outline_rounded,
      title: 'No Custom Personas',
      description: 'Create custom AI personas tailored to your specific legal needs and preferences.',
      actionLabel: 'Create Persona',
      onAction: onCreatePersona,
    );
  }
}

class EmptyHistoryState extends StatelessWidget {
  final VoidCallback? onStartAnalysis;

  const EmptyHistoryState({
    super.key,
    this.onStartAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.history_rounded,
      title: 'No Analysis History',
      description: 'Your analyzed documents will appear here for easy access.',
      actionLabel: 'Analyze Document',
      onAction: onStartAnalysis,
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String? searchTerm;
  final VoidCallback? onClearSearch;

  const EmptySearchState({
    super.key,
    this.searchTerm,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_rounded,
      title: 'No Results Found',
      description: searchTerm != null
          ? 'No documents found for "$searchTerm"'
          : 'Try adjusting your search terms.',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
    );
  }
}
