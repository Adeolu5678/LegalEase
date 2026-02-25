import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

enum LoadingSize { small, medium, large }

class BrandedLoadingIndicator extends StatefulWidget {
  final LoadingSize size;
  final Color? color;
  final double? progress;
  final String? message;
  final bool showPercentage;

  const BrandedLoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.color,
    this.progress,
    this.message,
    this.showPercentage = false,
  });

  @override
  State<BrandedLoadingIndicator> createState() => _BrandedLoadingIndicatorState();
}

class _BrandedLoadingIndicatorState extends State<BrandedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get _size {
    switch (widget.size) {
      case LoadingSize.small:
        return AppSizing.loadingIndicatorSm;
      case LoadingSize.medium:
        return AppSizing.loadingIndicatorMd;
      case LoadingSize.large:
        return AppSizing.loadingIndicatorLg;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case LoadingSize.small:
        return 10;
      case LoadingSize.medium:
        return 18;
      case LoadingSize.large:
        return 28;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Semantics(
      label: widget.message ?? 'Loading',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: _size,
                      height: _size,
                      child: CircularProgressIndicator(
                        value: widget.progress,
                        strokeWidth: widget.size == LoadingSize.small ? 2 : 3,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        backgroundColor: color.withValues(alpha: 0.2),
                      ),
                    ),
                    Transform.rotate(
                      angle: _controller.value * 2 * 3.14159,
                      child: Icon(
                        Icons.gavel_rounded,
                        size: _iconSize,
                        color: color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.showPercentage && widget.progress != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${(widget.progress! * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final IconData icon;

  const PulseLoadingIndicator({
    super.key,
    this.size = AppSizing.loadingIndicatorXl,
    this.color,
    this.icon = Icons.auto_awesome,
  });

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size + (_controller.value * 20),
                height: widget.size + (_controller.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primaryContainer.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.3,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const TypingIndicator({
    super.key,
    this.color,
    this.dotSize = 8,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.textTertiary;

    return Semantics(
      label: 'Typing',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
              final yOffset = -8 * (1 - (2 * value - 1).abs());

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.4 + value * 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class ButtonLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingIndicator({
    super.key,
    this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}

Future<void> showBrandedLoadingDialog(
  BuildContext context, {
  String? message,
  bool barrierDismissible = false,
}) {
  HapticFeedback.lightImpact();
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: AppColors.overlay,
    builder: (context) => PopScope(
      canPop: barrierDismissible,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BrandedLoadingIndicator(
              size: LoadingSize.large,
              message: message,
            ),
          ),
        ),
      ).animate().fadeIn(duration: AppAnimation.normal),
    ),
  );
}
