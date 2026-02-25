import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

enum ToastType {
  success,
  warning,
  error,
  info,
}

class ToastNotification {
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool hapticFeedback = true,
  }) {
    if (hapticFeedback) {
      switch (type) {
        case ToastType.success:
          HapticFeedback.mediumImpact();
          break;
        case ToastType.error:
          HapticFeedback.heavyImpact();
          break;
        case ToastType.warning:
          HapticFeedback.lightImpact();
          break;
        case ToastType.info:
          HapticFeedback.selectionClick();
          break;
      }
    }

    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.mdAll,
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.info;
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }
}

class ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const ToastWidget({
    super.key,
    required this.message,
    this.type = ToastType.info,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  Color get _color {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.error_outline_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: AppBorderRadius.mdAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 20, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onAction!();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                minimumSize: const Size(44, 32),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (onDismiss != null)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onDismiss!();
              },
              icon: const Icon(Icons.close_rounded, size: 18),
              color: Colors.white,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    ).animate().fadeIn(duration: AppAnimation.normal).slideY(begin: 0.5);
  }
}
