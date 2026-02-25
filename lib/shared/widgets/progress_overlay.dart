import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/shared/widgets/branded_loading_indicator.dart';

class ProgressOverlay extends StatelessWidget {
  final bool isVisible;
  final String? message;
  final double? progress;
  final bool showProgress;
  final bool barrierDismissible;
  final VoidCallback? onCancel;

  const ProgressOverlay({
    super.key,
    required this.isVisible,
    this.message,
    this.progress,
    this.showProgress = false,
    this.barrierDismissible = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        GestureDetector(
          onTap: barrierDismissible ? () => _dismiss(context) : null,
          child: Container(
            color: AppColors.overlay,
          ),
        ),
        Center(
          child: _ProgressOverlayContent(
            message: message,
            progress: progress,
            showProgress: showProgress,
            onCancel: onCancel,
          ),
        ).animate().fadeIn(duration: AppAnimation.normal).scale(
              begin: const Offset(0.9, 0.9),
              duration: AppAnimation.normal,
              curve: AppAnimation.easeOutCubic,
            ),
      ],
    );
  }

  void _dismiss(BuildContext context) {
    if (barrierDismissible && onCancel != null) {
      onCancel!();
    }
  }
}

class _ProgressOverlayContent extends StatelessWidget {
  final String? message;
  final double? progress;
  final bool showProgress;
  final VoidCallback? onCancel;

  const _ProgressOverlayContent({
    this.message,
    this.progress,
    this.showProgress = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgAll,
      ),
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandedLoadingIndicator(
              size: LoadingSize.large,
              progress: showProgress ? progress : null,
              showPercentage: showProgress,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (showProgress && progress != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ProgressBar(progress: progress!),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onCancel!();
                },
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: AppAnimation.medium,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 6,
              borderRadius: AppBorderRadius.fullAll,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            );
          },
        ),
      ],
    );
  }
}

Future<T?> showProgressOverlay<T>(
  BuildContext context, {
  required Future<T> Function() future,
  String? message,
  bool showProgress = false,
  bool barrierDismissible = false,
}) async {
  HapticFeedback.lightImpact();

  late OverlayEntry overlayEntry;
  T? result;
  Object? error;

  overlayEntry = OverlayEntry(
    builder: (context) => ProgressOverlay(
      isVisible: true,
      message: message,
      showProgress: showProgress,
      barrierDismissible: barrierDismissible,
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  try {
    result = await future();
  } catch (e) {
    error = e;
  } finally {
    overlayEntry.remove();
  }

  if (error != null) {
    throw error;
  }

  return result;
}

class InlineLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const InlineLoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: AppColors.overlay,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: BrandedLoadingIndicator(
                      message: message,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: AppAnimation.fast),
            ),
          ),
      ],
    );
  }
}
