import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/legal_dictionary/data/models/legal_term.dart';
import 'package:legalease/features/legal_dictionary/domain/providers/dictionary_providers.dart';
import 'package:legalease/features/legal_dictionary/presentation/widgets/term_definition_card.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/core/theme/app_colors.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchResults = ref.watch(dictionarySearchResultsProvider);
    final selectedCategory = ref.watch(dictionarySelectedCategoryProvider);
    final selectedTerm = ref.watch(dictionarySelectedTermProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Dictionary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              selectedCategory == null ? Icons.filter_list_rounded : Icons.filter_list,
              color: selectedCategory != null ? colorScheme.primary : null,
            ),
            onPressed: () => _showCategoryFilter(context),
            tooltip: 'Filter by category',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          if (selectedCategory != null) _buildCategoryChip(context),
          Expanded(
            child: selectedTerm != null
                ? _buildTermDetail(context, selectedTerm)
                : _buildTermList(context, searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          ref.read(dictionarySearchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Search legal terms...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(dictionarySearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.lgAll,
            borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.lgAll,
            borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.lgAll,
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }

  Widget _buildCategoryChip(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCategory = ref.watch(dictionarySelectedCategoryProvider);

    if (selectedCategory == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Wrap(
        children: [
          Chip(
            label: Text(selectedCategory.label),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              ref.read(dictionarySelectedCategoryProvider.notifier).state = null;
            },
            backgroundColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }

  Widget _buildTermList(BuildContext context, List<LegalTerm> terms) {
    if (terms.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final term = terms[index];
        return TermDefinitionCard(
          term: term,
          isCompact: true,
          onTap: () {
            ref.read(dictionarySelectedTermProvider.notifier).state = term;
          },
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No terms found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Try a different search term or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildTermDetail(BuildContext context, LegalTerm term) {
    final colorScheme = Theme.of(context).colorScheme;
    final relatedTerms = ref.watch(dictionaryRelatedTermsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  ref.read(dictionarySelectedTermProvider.notifier).state = null;
                },
              ),
              Expanded(
                child: Text(
                  term.term,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          if (term.phonetic != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              term.phonetic!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: AppBorderRadius.smAll,
            ),
            child: Text(
              term.categoryLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TermDefinitionCard(
            term: term,
            isCompact: false,
          ),
          if (term.synonyms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Synonyms',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: term.synonyms.map((synonym) {
                return Chip(
                  label: Text(synonym),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  labelStyle: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                );
              }).toList(),
            ),
          ],
          if (term.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Examples',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...term.examples.map((example) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: AppBorderRadius.mdAll,
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        example,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (relatedTerms.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Related Terms',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...relatedTerms.map((relatedTerm) {
              return ListTile(
                leading: Icon(Icons.arrow_forward_rounded, color: colorScheme.primary, size: 20),
                title: Text(relatedTerm.term),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  ref.read(dictionarySelectedTermProvider.notifier).state = relatedTerm;
                },
              );
            }),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),
    );
  }

  void _showCategoryFilter(BuildContext context) {
    final categories = LegalTermCategory.values;
    final selectedCategory = ref.read(dictionarySelectedCategoryProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Filter by Category',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return RadioListTile<LegalTermCategory?>(
                      title: const Text('All Categories'),
                      value: null,
                      groupValue: selectedCategory,
                      onChanged: (value) {
                        ref.read(dictionarySelectedCategoryProvider.notifier).state = value;
                        Navigator.pop(context);
                      },
                    );
                  }
                  final category = categories[index - 1];
                  return RadioListTile<LegalTermCategory?>(
                    title: Text(category.label),
                    value: category,
                    groupValue: selectedCategory,
                    onChanged: (value) {
                      ref.read(dictionarySelectedCategoryProvider.notifier).state = value;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
