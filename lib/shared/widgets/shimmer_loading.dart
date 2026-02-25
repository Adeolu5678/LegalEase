import 'package:flutter/material.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: borderRadius ?? AppBorderRadius.smAll,
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius ?? AppBorderRadius.xsAll,
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

class ShimmerListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int titleLines;
  final int subtitleLines;

  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.titleLines = 1,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.listItemPadding,
      child: Row(
        children: [
          if (hasLeading) ...[
            const ShimmerCircle(size: 48),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: titleLines > 1 ? double.infinity : 150),
                if (titleLines > 1) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerText(width: 120),
                ],
                if (subtitleLines > 0) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ShimmerText(
                    width: double.infinity,
                    height: 12,
                  ),
                ],
                if (subtitleLines > 1) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  const ShimmerText(
                    width: 200,
                    height: 12,
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: AppSpacing.sm),
            const ShimmerBox(width: 24, height: 24),
          ],
        ],
      ),
    );
  }
}

class ShimmerMessageBubble extends StatelessWidget {
  final bool isUser;

  const ShimmerMessageBubble({
    super.key,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppBorderRadius.md),
            topRight: const Radius.circular(AppBorderRadius.md),
            bottomLeft: Radius.circular(isUser ? AppBorderRadius.md : AppBorderRadius.xs),
            bottomRight: Radius.circular(isUser ? AppBorderRadius.xs : AppBorderRadius.md),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerText(width: double.infinity),
            const SizedBox(height: AppSpacing.xs),
            const ShimmerText(width: 200),
          ],
        ),
      ),
    );
  }
}

class ShimmerDocumentCard extends StatelessWidget {
  const ShimmerDocumentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            const ShimmerCircle(size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerText(width: 180),
                  const SizedBox(height: AppSpacing.xs),
                  const ShimmerText(width: 100, height: 12),
                ],
              ),
            ),
            const ShimmerBox(width: 60, height: 24),
          ],
        ),
      ),
    );
  }
}

class ShimmerChatList extends StatelessWidget {
  final int itemCount;

  const ShimmerChatList({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          return ShimmerMessageBubble(isUser: index % 3 == 0);
        },
      ),
    );
  }
}
