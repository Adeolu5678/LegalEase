import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/search/data/services/search_service.dart';
import 'package:legalease/features/search/domain/providers/search_providers.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchHistory = ref.watch(searchHistoryProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          if (_showFilters) _buildFilters(context),
          Expanded(
            child: query.isEmpty
                ? _buildSearchHistory(context, searchHistory)
                : searchResults.when(
                    data: (results) => _buildSearchResults(context, results),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
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
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            ref.read(saveSearchQueryProvider(value));
          }
        },
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final documentFilter = ref.watch(searchFilterProvider);
    final severityFilter = ref.watch(severityFilterProvider);
    final startDate = ref.watch(startDateFilterProvider);
    final endDate = ref.watch(endDateFilterProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Type',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: SearchFilter.values.map((filter) => ChoiceChip(
                  label: Text(_getFilterLabel(filter)),
                  selected: documentFilter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(searchFilterProvider.notifier).state = filter;
                    }
                  },
                )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Severity',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: SeverityFilter.values.map((filter) => ChoiceChip(
                  label: Text(_getSeverityLabel(filter)),
                  selected: severityFilter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(severityFilterProvider.notifier).state = filter;
                    }
                  },
                )).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    startDate != null ? DateFormat('MMM d, y').format(startDate) : 'Start Date',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      ref.read(startDateFilterProvider.notifier).state = date;
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    endDate != null ? DateFormat('MMM d, y').format(endDate) : 'End Date',
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      ref.read(endDateFilterProvider.notifier).state = date;
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref.read(startDateFilterProvider.notifier).state = null;
                  ref.read(endDateFilterProvider.notifier).state = null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(BuildContext context, AsyncValue<List<String>> history) {
    return history.when(
      data: (queries) {
        if (queries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Search your documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Find documents by title, content, or red flags',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () async {
                      final service = ref.read(searchServiceProvider);
                      final user = ref.read(authStateChangesProvider).value;
                      await service.clearSearchHistory(userId: user?.uid);
                      ref.invalidate(searchHistoryProvider);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: queries.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(queries[index]),
                  onTap: () {
                    _searchController.text = queries[index];
                    ref.read(searchQueryProvider.notifier).state = queries[index];
                  },
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<SearchResult> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try different search terms or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) => _SearchResultCard(result: results[index]),
    );
  }

  String _getFilterLabel(SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return 'All';
      case SearchFilter.contracts:
        return 'Contracts';
      case SearchFilter.terms:
        return 'Terms';
      case SearchFilter.privacy:
        return 'Privacy';
      case SearchFilter.other:
        return 'Other';
    }
  }

  String _getSeverityLabel(SeverityFilter filter) {
    switch (filter) {
      case SeverityFilter.all:
        return 'All';
      case SeverityFilter.critical:
        return 'Critical';
      case SeverityFilter.warning:
        return 'Warning';
      case SeverityFilter.info:
        return 'Info';
    }
  }
}

class _SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const _SearchResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          context.push('/analysis/result', extra: {'documentId': result.documentId});
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
                      color: _getTypeColor(result.documentType).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getTypeLabel(result.documentType),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getTypeColor(result.documentType),
                          ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(result.analyzedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).disabledColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                result.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                result.snippet,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (result.criticalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error, size: 12, color: AppColors.error),
                          const SizedBox(width: 2),
                          Text(
                            '${result.criticalCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ],
                      ),
                    ),
                  if (result.warningCount > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 12, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(
                            '${result.warningCount}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.warning,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.contract:
        return AppColors.primary;
      case DocumentType.lease:
        return AppColors.secondary;
      case DocumentType.termsConditions:
        return AppColors.info;
      case DocumentType.privacyPolicy:
        return AppColors.success;
      case DocumentType.eula:
        return AppColors.warning;
      case DocumentType.nda:
        return AppColors.error;
      case DocumentType.employment:
        return const Color(0xFF9C27B0);
      case DocumentType.other:
        return AppColors.textSecondary;
    }
  }

  String _getTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.lease:
        return 'Lease';
      case DocumentType.termsConditions:
        return 'Terms';
      case DocumentType.privacyPolicy:
        return 'Privacy';
      case DocumentType.eula:
        return 'EULA';
      case DocumentType.nda:
        return 'NDA';
      case DocumentType.employment:
        return 'Employment';
      case DocumentType.other:
        return 'Other';
    }
  }
}
