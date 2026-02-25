import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/core/theme/app_colors.dart';

export 'package:legalease/features/document_scan/domain/models/analysis_result.dart' show RedFlagSeverity, ConfidenceLevel;

class RedFlagCard extends StatefulWidget {
  final String id;
  final String originalText;
  final String explanation;
  final RedFlagSeverity severity;
  final double confidenceScore;
  final VoidCallback? onTap;
  final VoidCallback? onViewInDocument;

  const RedFlagCard({
    super.key,
    required this.id,
    required this.originalText,
    required this.explanation,
    required this.severity,
    this.confidenceScore = 0.8,
    this.onTap,
    this.onViewInDocument,
  });

  factory RedFlagCard.fromSeverityString({
    required String id,
    required String originalText,
    required String explanation,
    required String severity,
    double confidenceScore = 0.8,
    VoidCallback? onTap,
    VoidCallback? onViewInDocument,
  }) {
    final severityEnum = switch (severity.toLowerCase()) {
      'critical' || 'high' => RedFlagSeverity.critical,
      'warning' || 'medium' => RedFlagSeverity.warning,
      _ => RedFlagSeverity.info,
    };
    return RedFlagCard(
      id: id,
      originalText: originalText,
      explanation: explanation,
      severity: severityEnum,
      confidenceScore: confidenceScore,
      onTap: onTap,
      onViewInDocument: onViewInDocument,
    );
  }

  @override
  State<RedFlagCard> createState() => _RedFlagCardState();
}

class _RedFlagCardState extends State<RedFlagCard> {
  bool _isExpanded = false;

  Color _getSeverityColor(ColorScheme colorScheme) {
    return switch (widget.severity) {
      RedFlagSeverity.critical => colorScheme.error,
      RedFlagSeverity.warning => Colors.orange,
      RedFlagSeverity.info => colorScheme.primary,
    };
  }

  String _getSeverityLabel() {
    return switch (widget.severity) {
      RedFlagSeverity.critical => 'Critical',
      RedFlagSeverity.warning => 'Warning',
      RedFlagSeverity.info => 'Info',
    };
  }

  IconData _getSeverityIcon() {
    return switch (widget.severity) {
      RedFlagSeverity.critical => Icons.dangerous_rounded,
      RedFlagSeverity.warning => Icons.warning_amber_rounded,
      RedFlagSeverity.info => Icons.info_outline_rounded,
    };
  }

  ConfidenceLevel get _confidenceLevel {
    if (widget.confidenceScore >= 0.8) return ConfidenceLevel.high;
    if (widget.confidenceScore >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  Color _getConfidenceColor() {
    return switch (_confidenceLevel) {
      ConfidenceLevel.high => AppColors.success,
      ConfidenceLevel.medium => AppColors.warning,
      ConfidenceLevel.low => AppColors.error,
    };
  }

  String _getConfidenceLabel() {
    return '${(widget.confidenceScore * 100).toInt()}% confidence';
  }

  Widget _buildConfidenceBar(ColorScheme colorScheme) {
    final confidenceColor = _getConfidenceColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.confidenceScore,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = _getSeverityColor(colorScheme);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSeverityIcon(),
                          size: 14,
                          color: severityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getSeverityLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: severityColor,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 200.ms),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _confidenceLevel == ConfidenceLevel.high
                              ? Icons.verified_rounded
                              : _confidenceLevel == ConfidenceLevel.medium
                                  ? Icons.help_outline_rounded
                                  : Icons.error_outline_rounded,
                          size: 14,
                          color: _getConfidenceColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getConfidenceLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getConfidenceColor(),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
                  const Spacer(),
                  AnimatedRotation(
                    duration: 300.ms,
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildConfidenceBar(colorScheme),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${widget.originalText.length > 150 ? '${widget.originalText.substring(0, 150)}...' : widget.originalText}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ).animate().fadeIn(delay: 100.ms),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'Explanation',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                ).animate().fadeIn(duration: 200.ms),
                const SizedBox(height: 8),
                Text(
                  widget.explanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(duration: 200.ms, delay: 100.ms),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: widget.onViewInDocument,
                      icon: const Icon(Icons.visibility_rounded, size: 18),
                      label: const Text('View in Document'),
                    ),
                  ],
                ).animate().fadeIn(duration: 200.ms, delay: 200.ms),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }
}
