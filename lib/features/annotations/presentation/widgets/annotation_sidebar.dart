import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/annotations/data/models/annotation.dart';
import 'package:legalease/features/annotations/domain/providers/annotation_providers.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';
import 'package:intl/intl.dart';

class AnnotationSidebar extends ConsumerStatefulWidget {
  final String documentId;
  final Function(Annotation)? onAnnotationTap;

  const AnnotationSidebar({
    super.key,
    required this.documentId,
    this.onAnnotationTap,
  });

  @override
  ConsumerState<AnnotationSidebar> createState() => _AnnotationSidebarState();
}

class _AnnotationSidebarState extends ConsumerState<AnnotationSidebar> {
  @override
  Widget build(BuildContext context) {
    final annotationsAsync = ref.watch(documentAnnotationsProvider(widget.documentId));
    final filterType = ref.watch(annotationFilterTypeProvider);
    final filterResolved = ref.watch(annotationFilterResolvedProvider);
    final stats = ref.watch(annotationsStatsProvider(widget.documentId));

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, stats),
          _buildFilters(context, filterType, filterResolved),
          const Divider(height: 1),
          Expanded(
            child: annotationsAsync.when(
              data: (annotations) => _buildAnnotationsList(context, annotations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Annotations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              _buildStatChip(context, 'Total', stats['total'] ?? 0, AppColors.primary),
              _buildStatChip(context, 'Open', stats['open'] ?? 0, AppColors.warning),
              _buildStatChip(context, 'Resolved', stats['resolved'] ?? 0, AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AnnotationType? filterType, bool? filterResolved) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filterType == null,
                onSelected: (_) => ref.read(annotationFilterTypeProvider.notifier).state = null,
              ),
              ...AnnotationType.values.map((type) => ChoiceChip(
                    label: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                    selected: filterType == type,
                    onSelected: (_) => ref.read(annotationFilterTypeProvider.notifier).state = type,
                  )),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Filter by Status',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filterResolved == null,
                onSelected: (_) => ref.read(annotationFilterResolvedProvider.notifier).state = null,
              ),
              ChoiceChip(
                label: const Text('Open'),
                selected: filterResolved == false,
                onSelected: (_) => ref.read(annotationFilterResolvedProvider.notifier).state = false,
              ),
              ChoiceChip(
                label: const Text('Resolved'),
                selected: filterResolved == true,
                onSelected: (_) => ref.read(annotationFilterResolvedProvider.notifier).state = true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationsList(BuildContext context, List<Annotation> annotations) {
    final filterType = ref.watch(annotationFilterTypeProvider);
    final filterResolved = ref.watch(annotationFilterResolvedProvider);

    var filtered = annotations;
    if (filterType != null) {
      filtered = filtered.where((a) => a.type == filterType).toList();
    }
    if (filterResolved != null) {
      filtered = filtered.where((a) => a.isResolved == filterResolved).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No annotations yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select text in the document to add annotations',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildAnnotationCard(context, filtered[index]),
    );
  }

  Widget _buildAnnotationCard(BuildContext context, Annotation annotation) {
    final isSelected = ref.watch(selectedAnnotationProvider) == annotation;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: isSelected ? 2 : 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerLow,
      child: InkWell(
        onTap: () {
          ref.read(selectedAnnotationProvider.notifier).state = annotation;
          widget.onAnnotationTap?.call(annotation);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(annotation.type).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(annotation.type),
                          size: 12,
                          color: _getTypeColor(annotation.type),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          annotation.typeLabel,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: _getTypeColor(annotation.type),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (annotation.isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Resolved',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  annotation.selectedText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                annotation.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    _getPriorityIcon(annotation.priority),
                    size: 14,
                    color: _getPriorityColor(annotation.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    annotation.priorityLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPriorityColor(annotation.priority),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, h:mm a').format(annotation.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(AnnotationType type) {
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

  IconData _getTypeIcon(AnnotationType type) {
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

  Color _getPriorityColor(AnnotationPriority priority) {
    switch (priority) {
      case AnnotationPriority.low:
        return AppColors.success;
      case AnnotationPriority.medium:
        return AppColors.warning;
      case AnnotationPriority.high:
        return AppColors.error;
    }
  }

  IconData _getPriorityIcon(AnnotationPriority priority) {
    switch (priority) {
      case AnnotationPriority.low:
        return Icons.arrow_downward;
      case AnnotationPriority.medium:
        return Icons.remove;
      case AnnotationPriority.high:
        return Icons.arrow_upward;
    }
  }
}
