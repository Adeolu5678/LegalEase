import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/templates/data/models/legal_template.dart';
import 'package:legalease/features/templates/domain/providers/template_providers.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(filteredTemplatesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          _buildCategoryFilters(context),
          Expanded(
            child: templates.isEmpty
                ? _buildEmptyState(context)
                : _buildTemplatesList(context, templates),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(templateSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: (value) {
          ref.read(templateSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (_) {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                },
              ),
            );
          }

          final category = categories[index - 1];
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: FilterChip(
              label: Text(_getCategoryLabel(category)),
              selected: selectedCategory == category,
              onSelected: (_) {
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No templates found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesList(BuildContext context, List<LegalTemplate> templates) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: templates.length,
      itemBuilder: (context, index) => _TemplateCard(template: templates[index]),
    );
  }

  String _getCategoryLabel(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.contracts:
        return 'Contracts';
      case TemplateCategory.employment:
        return 'Employment';
      case TemplateCategory.intellectualProperty:
        return 'IP';
      case TemplateCategory.realEstate:
        return 'Real Estate';
      case TemplateCategory.corporate:
        return 'Corporate';
      case TemplateCategory.privacy:
        return 'Privacy';
      case TemplateCategory.general:
        return 'General';
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final LegalTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          context.push('/templates/preview', extra: template);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(template.category).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      template.categoryName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getCategoryColor(template.category),
                          ),
                    ),
                  ),
                  const Spacer(),
                  if (template.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.warning,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                template.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    size: 16,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${template.fields.length} fields',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: template.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.contracts:
        return AppColors.primary;
      case TemplateCategory.employment:
        return AppColors.success;
      case TemplateCategory.intellectualProperty:
        return AppColors.info;
      case TemplateCategory.realEstate:
        return AppColors.warning;
      case TemplateCategory.corporate:
        return AppColors.secondary;
      case TemplateCategory.privacy:
        return AppColors.error;
      case TemplateCategory.general:
        return AppColors.textSecondary;
    }
  }
}
