import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/features/legal_dictionary/data/models/legal_term.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/core/theme/app_colors.dart';

class TermDefinitionCard extends StatelessWidget {
  final LegalTerm term;
  final bool isCompact;
  final VoidCallback? onTap;

  const TermDefinitionCard({
    super.key,
    required this.term,
    this.isCompact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: isCompact ? AppSpacing.sm : AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppBorderRadius.lgAll,
        side: BorderSide(
          color: term.isCommonTerm
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: term.isCommonTerm ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.lgAll,
        child: Padding(
          padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (term.isCommonTerm) ...[
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                            ],
                            Flexible(
                              child: Text(
                                term.term,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (!isCompact && term.phonetic != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            term.phonetic!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isCompact) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: AppBorderRadius.smAll,
                      ),
                      child: Text(
                        term.categoryLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isCompact ? AppSpacing.xs : AppSpacing.sm),
              Text(
                isCompact
                    ? (term.definition.length > 100
                        ? '${term.definition.substring(0, 100)}...'
                        : term.definition)
                    : term.definition,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              if (!isCompact && term.synonyms.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xxs,
                  runSpacing: AppSpacing.xxs,
                  children: term.synonyms.take(3).map((synonym) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: AppBorderRadius.xsAll,
                      ),
                      child: Text(
                        synonym,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (isCompact && onTap != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
