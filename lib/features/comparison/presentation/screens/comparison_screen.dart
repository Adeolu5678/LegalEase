import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/comparison/data/services/comparison_service.dart';
import 'package:legalease/features/comparison/domain/providers/comparison_providers.dart';
import 'package:intl/intl.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc1 = ref.watch(document1Provider);
    final doc2 = ref.watch(document2Provider);
    final comparisonResult = ref.watch(comparisonResultProvider);
    final userDocs = ref.watch(userDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Documents'),
        bottom: doc1.value != null && doc2.value != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Diff View'),
                  Tab(text: 'Side by Side'),
                  Tab(text: 'Summary'),
                ],
              )
            : null,
      ),
      body: doc1.value == null || doc2.value == null
          ? _buildDocumentSelection(context, userDocs)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDiffView(context, comparisonResult),
                _buildSideBySideView(context, doc1, doc2),
                _buildSummaryView(context),
              ],
            ),
    );
  }

  Widget _buildDocumentSelection(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> userDocs,
  ) {
    return userDocs.when(
      data: (documents) {
        if (documents.isEmpty) {
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
                  'No documents to compare',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Documents to Compare',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDocumentSelector(
                context,
                'Document 1',
                documents,
                ref.watch(document1IdProvider),
                (id) => ref.read(document1IdProvider.notifier).state = id,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDocumentSelector(
                context,
                'Document 2',
                documents,
                ref.watch(document2IdProvider),
                (id) => ref.read(document2IdProvider.notifier).state = id,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (ref.watch(document1IdProvider) != null &&
                  ref.watch(document2IdProvider) != null)
                Center(
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.compare),
                    label: const Text('Compare Documents'),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildDocumentSelector(
    BuildContext context,
    String label,
    List<Map<String, dynamic>> documents,
    String? selectedId,
    Function(String?) onSelect,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: selectedId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a document',
              ),
              items: documents.map((doc) {
                return DropdownMenuItem(
                  value: doc['id'] as String,
                  child: Text(
                    (doc['title'] as String?) ?? 'Untitled',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onSelect,
            ),
            if (selectedId != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildDocumentPreview(context, documents.firstWhere(
                (d) => d['id'] == selectedId,
                orElse: () => <String, dynamic>{},
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context, Map<String, dynamic> doc) {
    if (doc.isEmpty) return const SizedBox.shrink();

    final redFlags = (doc['redFlags'] as List<dynamic>?) ?? [];
    final analyzedAt = doc['analyzedAt'] != null
        ? DateTime.tryParse(doc['analyzedAt'].toString())
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Type: ${doc['type'] ?? 'Unknown'}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.flag,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${redFlags.length} red flags',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(width: AppSpacing.md),
              if (analyzedAt != null) ...[
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  DateFormat('MMM d, y').format(analyzedAt),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffView(
    BuildContext context,
    AsyncValue<DiffResult?> result,
  ) {
    return result.when(
      data: (diffResult) {
        if (diffResult == null) {
          return const Center(child: Text('Select documents to compare'));
        }

        return Column(
          children: [
            _buildStatsBar(context, diffResult),
            Expanded(
              child: ListView.builder(
                itemCount: diffResult.lines.length,
                itemBuilder: (context, index) {
                  final line = diffResult.lines[index];
                  return _buildDiffLine(context, line);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildStatsBar(BuildContext context, DiffResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Similarity',
            '${(result.similarityScore * 100).toStringAsFixed(1)}%',
            AppColors.success,
          ),
          _buildStatItem(
            context,
            'Additions',
            result.additions.toString(),
            AppColors.success,
          ),
          _buildStatItem(
            context,
            'Deletions',
            result.deletions.toString(),
            AppColors.error,
          ),
          _buildStatItem(
            context,
            'Modifications',
            result.modifications.toString(),
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildDiffLine(BuildContext context, DiffLine line) {
    Color backgroundColor;
    Color borderColor;
    IconData? icon;

    switch (line.type) {
      case DiffType.insertion:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        borderColor = AppColors.success;
        icon = Icons.add;
        break;
      case DiffType.deletion:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        borderColor = AppColors.error;
        icon = Icons.remove;
        break;
      case DiffType.modification:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        borderColor = AppColors.warning;
        icon = Icons.edit;
        break;
      case DiffType.equal:
        backgroundColor = Colors.transparent;
        borderColor = Colors.transparent;
        icon = null;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: borderColor)
          else
            const SizedBox(width: 14),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 40,
            child: Text(
              '${line.lineNumber1}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              line.content,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    decoration: line.type == DiffType.deletion
                        ? TextDecoration.lineThrough
                        : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideBySideView(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> doc1,
    AsyncValue<Map<String, dynamic>?> doc2,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildDocumentPanel(context, 'Document 1', doc1.value),
        ),
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          child: _buildDocumentPanel(context, 'Document 2', doc2.value),
        ),
      ],
    );
  }

  Widget _buildDocumentPanel(
    BuildContext context,
    String title,
    Map<String, dynamic>? doc,
  ) {
    if (doc == null) {
      return Center(
        child: Text(title),
      );
    }

    final text = (doc['originalText'] as String?) ?? '';
    final lines = text.split('\n');

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Icon(
                Icons.description,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  doc['title'] as String? ?? 'Untitled',
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: lines.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: index.isEven
                      ? null
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        lines[index],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(BuildContext context) {
    final summary = ref.watch(comparisonSummaryProvider);
    final redFlagDiffs = ref.watch(redFlagDifferencesProvider);

    if (summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Red Flag Differences',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          redFlagDiffs.when(
            data: (diffs) {
              if (diffs.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No red flag differences found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                  ),
                );
              }

              return Column(
                children: diffs.map((diff) => _buildRedFlagDiffCard(context, diff)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildRedFlagDiffCard(BuildContext context, Map<String, dynamic> diff) {
    final type = diff['type'] as String;
    final flag = diff['flag'] as Map<String, dynamic>? ?? {};

    Color color;
    String label;
    IconData icon;

    switch (type) {
      case 'added':
        color = AppColors.success;
        label = 'Added in Document 2';
        icon = Icons.add_circle;
        break;
      case 'removed':
        color = AppColors.error;
        label = 'Removed in Document 2';
        icon = Icons.remove_circle;
        break;
      case 'severity_changed':
        color = AppColors.warning;
        label = 'Severity Changed';
        icon = Icons.change_circle;
        break;
      default:
        color = AppColors.info;
        label = 'Changed';
        icon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (type == 'severity_changed') ...[
              Text(
                '${diff['oldSeverity']} → ${diff['newSeverity']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                flag['originalClause'] as String? ?? flag['originalText'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
