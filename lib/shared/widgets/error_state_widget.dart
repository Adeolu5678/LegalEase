import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

enum ErrorType {
  network,
  server,
  notFound,
  unauthorized,
  permission,
  unknown,
}

class ErrorStateWidget extends StatelessWidget {
  final ErrorType type;
  final String? title;
  final String? message;
  final String? retryText;
  final VoidCallback? onRetry;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final Widget? customIllustration;

  const ErrorStateWidget({
    super.key,
    this.type = ErrorType.unknown,
    this.title,
    this.message,
    this.retryText,
    this.onRetry,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.customIllustration,
  });

  IconData get _icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.notFound:
        return Icons.search_off_rounded;
      case ErrorType.unauthorized:
        return Icons.lock_outline_rounded;
      case ErrorType.permission:
        return Icons.no_accounts_rounded;
      case ErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.notFound:
        return 'Not Found';
      case ErrorType.unauthorized:
        return 'Unauthorized';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  String get _defaultMessage {
    switch (type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.server:
        return 'Our servers are having issues. Please try again later.';
      case ErrorType.notFound:
        return 'The content you\'re looking for doesn\'t exist or has been moved.';
      case ErrorType.unauthorized:
        return 'You don\'t have access to this content. Please sign in.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  Color get _color {
    switch (type) {
      case ErrorType.network:
        return AppColors.info;
      case ErrorType.server:
        return AppColors.warning;
      case ErrorType.notFound:
        return AppColors.textTertiary;
      case ErrorType.unauthorized:
        return AppColors.secondary;
      case ErrorType.permission:
        return AppColors.warning;
      case ErrorType.unknown:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${title ?? _defaultTitle}. ${message ?? _defaultMessage}',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customIllustration ??
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _icon,
                      size: 56,
                      color: _color,
                    ),
                  ).animate().scale(
                        duration: AppAnimation.medium,
                        curve: AppAnimation.easeOutCubic,
                      ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title ?? _defaultTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message ?? _defaultMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: AppSpacing.xl),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onRetry!();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(retryText ?? 'Try Again'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              if (onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSecondaryAction!();
                  },
                  child: Text(
                    secondaryActionText ?? 'Contact Support',
                    style: TextStyle(color: _color),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const InlineError({
    super.key,
    required this.message,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppBorderRadius.mdAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(44, 36),
              ),
              child: Text(
                'Retry',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.error,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimation.fast);
  }
}

class FormFieldError extends StatelessWidget {
  final String? message;

  const FormFieldError({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(
              message!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimation.fast).slideY(begin: -0.5);
  }
}
