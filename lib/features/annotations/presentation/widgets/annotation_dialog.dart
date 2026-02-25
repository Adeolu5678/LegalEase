import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/annotations/data/models/annotation.dart';
import 'package:legalease/features/annotations/domain/providers/annotation_providers.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';

class AnnotationDialog extends ConsumerStatefulWidget {
  final String documentId;
  final String selectedText;
  final int startIndex;
  final int endIndex;
  final Annotation? existingAnnotation;

  const AnnotationDialog({
    super.key,
    required this.documentId,
    required this.selectedText,
    required this.startIndex,
    required this.endIndex,
    this.existingAnnotation,
  });

  @override
  ConsumerState<AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends ConsumerState<AnnotationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  AnnotationType _selectedType = AnnotationType.comment;
  AnnotationPriority _selectedPriority = AnnotationPriority.medium;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.existingAnnotation?.content ?? '',
    );
    if (widget.existingAnnotation != null) {
      _selectedType = widget.existingAnnotation!.type;
      _selectedPriority = widget.existingAnnotation!.priority;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingAnnotation != null ? 'Edit Annotation' : 'Add Annotation'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Text:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.selectedText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Annotation Type',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: AnnotationType.values.map((type) => ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(type),
                            size: 14,
                            color: _selectedType == type ? Colors.white : _getTypeColor(type),
                          ),
                          const SizedBox(width: 4),
                          Text(type.name[0].toUpperCase() + type.name.substring(1)),
                        ],
                      ),
                      selected: _selectedType == type,
                      selectedColor: _getTypeColor(type),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedType = type);
                        }
                      },
                    )).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Priority',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: AnnotationPriority.values.map((priority) => ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(priority),
                            size: 14,
                            color: _selectedPriority == priority ? Colors.white : _getPriorityColor(priority),
                          ),
                          const SizedBox(width: 4),
                          Text(priority.name[0].toUpperCase() + priority.name.substring(1)),
                        ],
                      ),
                      selected: _selectedPriority == priority,
                      selectedColor: _getPriorityColor(priority),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPriority = priority);
                        }
                      },
                    )).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter your annotation...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter content for the annotation';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (widget.existingAnnotation != null)
          TextButton(
            onPressed: _isLoading ? null : _deleteAnnotation,
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        FilledButton(
          onPressed: _isLoading ? null : _saveAnnotation,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingAnnotation != null ? 'Update' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _saveAnnotation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(annotationServiceProvider);
      final user = ref.read(authStateChangesProvider).value;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to add annotations')),
          );
        }
        return;
      }

      final annotation = Annotation(
        id: widget.existingAnnotation?.id ?? '',
        documentId: widget.documentId,
        userId: user.uid,
        type: _selectedType,
        content: _contentController.text.trim(),
        startIndex: widget.startIndex,
        endIndex: widget.endIndex,
        selectedText: widget.selectedText,
        priority: _selectedPriority,
        createdAt: widget.existingAnnotation?.createdAt ?? DateTime.now(),
        isResolved: widget.existingAnnotation?.isResolved ?? false,
      );

      if (widget.existingAnnotation != null) {
        await service.updateAnnotation(annotation);
      } else {
        await service.createAnnotation(annotation);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingAnnotation != null
                ? 'Annotation updated'
                : 'Annotation added'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving annotation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAnnotation() async {
    if (widget.existingAnnotation == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Annotation'),
        content: const Text('Are you sure you want to delete this annotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(annotationServiceProvider);
      await service.deleteAnnotation(widget.existingAnnotation!.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Annotation deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting annotation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
