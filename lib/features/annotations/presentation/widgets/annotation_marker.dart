import 'package:flutter/material.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/features/annotations/data/models/annotation.dart';

class AnnotationMarker extends StatelessWidget {
  final Annotation annotation;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showIcon;

  const AnnotationMarker({
    super.key,
    required this.annotation,
    this.onTap,
    this.isSelected = false,
    this.showIcon = true,
  });

  Color get _backgroundColor {
    switch (annotation.type) {
      case AnnotationType.comment:
        return AppColors.info.withValues(alpha: 0.2);
      case AnnotationType.note:
        return AppColors.success.withValues(alpha: 0.2);
      case AnnotationType.highlight:
        return AppColors.warning.withValues(alpha: 0.3);
      case AnnotationType.question:
        return AppColors.secondary.withValues(alpha: 0.2);
    }
  }

  Color get _borderColor {
    switch (annotation.type) {
      case AnnotationType.comment:
        return AppColors.info;
      case AnnotationType.note:
        return AppColors.success;
      case AnnotationType.highlight:
        return AppColors.warning;
      case AnnotationType.question:
        return AppColors.secondary;
    }
  }

  IconData get _icon {
    switch (annotation.type) {
      case AnnotationType.comment:
        return Icons.comment_outlined;
      case AnnotationType.note:
        return Icons.note_outlined;
      case AnnotationType.highlight:
        return Icons.highlight_outlined;
      case AnnotationType.question:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: isSelected
              ? Border.all(color: _borderColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(2),
        ),
        child: showIcon
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(
                    annotation.selectedText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _borderColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _icon,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                annotation.selectedText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      backgroundColor: _backgroundColor,
                    ),
              ),
      ),
    );
  }
}

class AnnotationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const AnnotationBadge({
    super.key,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.comment_outlined,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnotationTypeChip extends StatelessWidget {
  final AnnotationType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const AnnotationTypeChip({
    super.key,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  Color get _color {
    switch (type) {
      case AnnotationType.comment:
        return AppColors.info;
      case AnnotationType.note:
        return AppColors.success;
      case AnnotationType.highlight:
        return AppColors.warning;
      case AnnotationType.question:
        return AppColors.secondary;
    }
  }

  IconData get _icon {
    switch (type) {
      case AnnotationType.comment:
        return Icons.comment_outlined;
      case AnnotationType.note:
        return Icons.note_outlined;
      case AnnotationType.highlight:
        return Icons.highlight_outlined;
      case AnnotationType.question:
        return Icons.help_outline;
    }
  }

  String get _label {
    switch (type) {
      case AnnotationType.comment:
        return 'Comment';
      case AnnotationType.note:
        return 'Note';
      case AnnotationType.highlight:
        return 'Highlight';
      case AnnotationType.question:
        return 'Question';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap?.call(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: isSelected ? Colors.white : _color),
          const SizedBox(width: 4),
          Text(_label),
        ],
      ),
      selectedColor: _color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}
