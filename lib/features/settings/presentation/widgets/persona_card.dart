import 'package:flutter/material.dart';
import 'package:legalease/shared/models/persona_model.dart';

class PersonaCard extends StatelessWidget {
  final Persona persona;
  final bool isActive;
  final bool isPremiumUser;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PersonaCard({
    super.key,
    required this.persona,
    this.isActive = false,
    this.isPremiumUser = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLocked = persona.isPremium && !isPremiumUser;

    return Card(
      elevation: isActive ? 2 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      color: isActive
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(context, isLocked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            persona.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (persona.isPremium) _buildPremiumBadge(context),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      persona.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildBadges(context),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailing(context, isLocked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, bool isLocked) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isLocked ? Icons.lock_outline : _getToneIcon(),
        color: isActive
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildPremiumBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            size: 12,
            color: colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildBadge(
          context,
          label: _toneLabel(persona.tone),
          icon: _getToneIcon(),
        ),
        _buildBadge(
          context,
          label: _styleLabel(persona.style),
          icon: _getStyleIcon(),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context, {required String label, required IconData icon}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, bool isLocked) {
    if (isLocked) {
      return Icon(
        Icons.lock,
        color: Theme.of(context).colorScheme.outline,
      );
    }

    if (isActive) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    if (!persona.isDefault && onEdit != null) {
      return PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit?.call();
          } else if (value == 'delete') {
            onDelete?.call();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        icon: Icon(
          Icons.more_vert,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  IconData _getToneIcon() {
    switch (persona.tone) {
      case PersonaTone.formal:
        return Icons.business_center_outlined;
      case PersonaTone.casual:
        return Icons.sentiment_satisfied_outlined;
      case PersonaTone.professional:
        return Icons.work_outline;
      case PersonaTone.friendly:
        return Icons.sentiment_very_satisfied_outlined;
      case PersonaTone.assertive:
        return Icons.campaign_outlined;
      case PersonaTone.diplomatic:
        return Icons.handshake_outlined;
    }
  }

  IconData _getStyleIcon() {
    switch (persona.style) {
      case PersonaStyle.concise:
        return Icons.short_text_outlined;
      case PersonaStyle.detailed:
        return Icons.article_outlined;
      case PersonaStyle.technical:
        return Icons.code_outlined;
      case PersonaStyle.plainEnglish:
        return Icons.translate_outlined;
    }
  }

  String _toneLabel(PersonaTone tone) {
    switch (tone) {
      case PersonaTone.formal:
        return 'Formal';
      case PersonaTone.casual:
        return 'Casual';
      case PersonaTone.professional:
        return 'Professional';
      case PersonaTone.friendly:
        return 'Friendly';
      case PersonaTone.assertive:
        return 'Assertive';
      case PersonaTone.diplomatic:
        return 'Diplomatic';
    }
  }

  String _styleLabel(PersonaStyle style) {
    switch (style) {
      case PersonaStyle.concise:
        return 'Concise';
      case PersonaStyle.detailed:
        return 'Detailed';
      case PersonaStyle.technical:
        return 'Technical';
      case PersonaStyle.plainEnglish:
        return 'Plain English';
    }
  }
}
