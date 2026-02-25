import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

enum BannerType {
  success,
  warning,
  error,
  info,
}

class ErrorBanner extends StatefulWidget {
  final String message;
  final BannerType type;
  final Duration autoDismissDuration;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ErrorBanner({
    super.key,
    required this.message,
    this.type = BannerType.error,
    this.autoDismissDuration = const Duration(seconds: 5),
    this.onDismiss,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<ErrorBanner> {
  bool _isVisible = true;

  Color get _backgroundColor {
    switch (widget.type) {
      case BannerType.success:
        return AppColors.success;
      case BannerType.warning:
        return AppColors.warning;
      case BannerType.error:
        return AppColors.error;
      case BannerType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case BannerType.success:
        return Icons.check_circle_outline_rounded;
      case BannerType.warning:
        return Icons.warning_amber_rounded;
      case BannerType.error:
        return Icons.error_outline_rounded;
      case BannerType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoDismissDuration > Duration.zero) {
      Future.delayed(widget.autoDismissDuration, _dismiss);
    }
  }

  void _dismiss() {
    if (mounted && _isVisible) {
      HapticFeedback.lightImpact();
      setState(() => _isVisible = false);
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _icon,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                if (widget.actionLabel != null && widget.onAction != null)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onAction!();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      minimumSize: const Size(44, 32),
                    ),
                    child: Text(
                      widget.actionLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: _dismiss,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppAnimation.normal).slideY(begin: -1);
  }
}

class SlidingBanner extends StatefulWidget {
  final String message;
  final BannerType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SlidingBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  static void show(
    BuildContext context, {
    required String message,
    BannerType type = BannerType.info,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _SlidingBannerOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          entry.remove();
        },
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );

    overlay.insert(entry);
  }

  @override
  State<SlidingBanner> createState() => _SlidingBannerState();
}

class _SlidingBannerState extends State<SlidingBanner> {
  @override
  Widget build(BuildContext context) {
    return ErrorBanner(
      message: widget.message,
      type: widget.type,
      autoDismissDuration: widget.duration,
      onDismiss: widget.onDismiss,
      actionLabel: widget.actionLabel,
      onAction: widget.onAction,
    );
  }
}

class _SlidingBannerOverlay extends StatefulWidget {
  final String message;
  final BannerType type;
  final Duration duration;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SlidingBannerOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_SlidingBannerOverlay> createState() => _SlidingBannerOverlayState();
}

class _SlidingBannerOverlayState extends State<_SlidingBannerOverlay> {
  bool _visible = true;

  Color get _backgroundColor {
    switch (widget.type) {
      case BannerType.success:
        return AppColors.success;
      case BannerType.warning:
        return AppColors.warning;
      case BannerType.error:
        return AppColors.error;
      case BannerType.info:
        return AppColors.info;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case BannerType.success:
        return Icons.check_circle_outline_rounded;
      case BannerType.warning:
        return Icons.warning_amber_rounded;
      case BannerType.error:
        return Icons.error_outline_rounded;
      case BannerType.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      HapticFeedback.lightImpact();
      setState(() => _visible = false);
      Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, -1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: SafeArea(
          child: Material(
            color: _backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(_icon, size: 20, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (widget.actionLabel != null)
                    TextButton(
                      onPressed: widget.onAction,
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  IconButton(
                    onPressed: _dismiss,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Colors.white,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
