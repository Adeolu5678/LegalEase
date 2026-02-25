import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum AnalysisStep {
  idle,
  extractingText,
  analyzingDocument,
  detectingRedFlags,
  generatingSummary,
  completed,
  error,
}

class AnalysisProgressIndicator extends StatelessWidget {
  final AnalysisStep currentStep;
  final String? errorMessage;
  final double progress;

  const AnalysisProgressIndicator({
    super.key,
    required this.currentStep,
    this.errorMessage,
    this.progress = 0.0,
  });

  int _getStepIndex(AnalysisStep step) {
    switch (step) {
      case AnalysisStep.idle:
        return -1;
      case AnalysisStep.extractingText:
        return 0;
      case AnalysisStep.analyzingDocument:
        return 1;
      case AnalysisStep.detectingRedFlags:
        return 2;
      case AnalysisStep.generatingSummary:
        return 3;
      case AnalysisStep.completed:
        return 4;
      case AnalysisStep.error:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStep == AnalysisStep.error) {
      return _buildErrorState(context);
    }

    return _buildSteps(context);
  }

  Widget _buildSteps(BuildContext context) {
    final steps = [
      (AnalysisStep.extractingText, 'Extracting text...', Icons.text_fields_rounded),
      (AnalysisStep.analyzingDocument, 'Analyzing document...', Icons.analytics_rounded),
      (AnalysisStep.detectingRedFlags, 'Detecting red flags...', Icons.warning_amber_rounded),
      (AnalysisStep.generatingSummary, 'Generating summary...', Icons.summarize_rounded),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final (step, label, icon) = entry.value;
        final isActive = _getStepIndex(currentStep) >= index;
        final isCurrent = currentStep == step;

        return _StepItem(
          icon: icon,
          label: label,
          isActive: isActive,
          isCurrent: isCurrent,
          isLast: index == steps.length - 1,
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
      }).toList(),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage ?? 'An error occurred during analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCurrent;
  final bool isLast;

  const _StepItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: 300.ms,
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? (isCurrent ? colorScheme.primary : colorScheme.primaryContainer)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive && !isCurrent ? Icons.check_rounded : icon,
              size: 18,
              color: isActive
                  ? (isCurrent ? colorScheme.onPrimary : colorScheme.onPrimaryContainer)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ),
          if (isCurrent)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}
