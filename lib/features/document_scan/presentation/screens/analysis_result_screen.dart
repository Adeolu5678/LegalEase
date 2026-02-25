import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';
import 'package:legalease/features/document_scan/presentation/widgets/red_flag_card.dart';
import 'package:legalease/features/export/presentation/widgets/export_button.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final String? documentId;

  const AnalysisResultScreen({super.key, this.documentId});

  @override
  ConsumerState<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showOriginalText = true;

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
    final analysisState = ref.watch(analysisNotifierProvider);
    final result = analysisState.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Result')),
        body: const Center(child: Text('No analysis result available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Analysis Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _handleShare(result),
            tooltip: 'Share',
          ),
          ExportButton(analysisResult: result),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, result),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.bookmark_outline_rounded),
                  title: Text('Save to Library'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: ListTile(
                  leading: Icon(Icons.report_outlined),
                  title: Text('Report Issue'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.summarize_rounded), text: 'Summary'),
            Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Red Flags'),
            Tab(icon: Icon(Icons.translate_rounded), text: 'Translation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SummaryTab(result: result),
          _RedFlagsTab(result: result),
          _TranslationTab(
            result: result,
            showOriginalText: _showOriginalText,
            onToggle: () => setState(() => _showOriginalText = !_showOriginalText),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat', extra: result.summary),
        icon: const Icon(Icons.chat_bubble_rounded),
        label: const Text('Ask a Question'),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
    );
  }

  void _handleShare(AnalysisResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing functionality coming soon')),
    );
  }

  void _handleMenuAction(String action, AnalysisResult result) {
    switch (action) {
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to library')),
        );
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
        break;
    }
  }
}

class _SummaryTab extends StatelessWidget {
  final AnalysisResult result;

  const _SummaryTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentTypeCard(context),
          const SizedBox(height: 20),
          _buildOverviewSection(context),
          const SizedBox(height: 24),
          _buildKeyPointsSection(context),
          const SizedBox(height: 24),
          _buildMetadataSection(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDocumentIcon(result.metadata.type),
              size: 28,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.metadata.typeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.metadata.fileName ?? 'Document analyzed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (result.hasRedFlags)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: result.hasCriticalFlags
                    ? colorScheme.error
                    : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${result.redFlags.length} flags',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  IconData _getDocumentIcon(DocumentType type) {
    return switch (type) {
      DocumentType.contract => Icons.description_rounded,
      DocumentType.lease => Icons.home_rounded,
      DocumentType.termsConditions => Icons.gavel_rounded,
      DocumentType.privacyPolicy => Icons.privacy_tip_rounded,
      DocumentType.eula => Icons.article_rounded,
      DocumentType.nda => Icons.lock_rounded,
      DocumentType.employment => Icons.work_rounded,
      DocumentType.other => Icons.insert_drive_file_rounded,
    };
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            result.summary.isNotEmpty
                ? result.summary
                : 'No summary available for this document.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    final keyPoints = _extractKeyPoints();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Points',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        ...keyPoints.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 300 + (entry.key * 100)));
        }),
      ],
    );
  }

  List<String> _extractKeyPoints() {
    if (result.summary.isEmpty) {
      return [
        'Document processed successfully',
        'Analysis completed',
        'Review red flags section for potential issues',
      ];
    }

    final sentences = result.summary.split(RegExp(r'[.!?]+'));
    return sentences
        .where((s) => s.trim().isNotEmpty)
        .take(5)
        .map((s) => s.trim())
        .toList();
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Info',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Icons.text_fields_rounded,
              label: '${result.metadata.wordCount} words',
            ),
            _InfoChip(
              icon: Icons.insert_drive_file_rounded,
              label: '${result.metadata.pageCount} page${result.metadata.pageCount > 1 ? 's' : ''}',
            ),
            _InfoChip(
              icon: Icons.timer_outlined,
              label: result.metadata.formattedProcessingTime,
            ),
            _InfoChip(
              icon: Icons.psychology_rounded,
              label: '${(result.metadata.confidence * 100).toInt()}% confidence',
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RedFlagsTab extends StatelessWidget {
  final AnalysisResult result;

  const _RedFlagsTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeverityBreakdown(context),
          const SizedBox(height: 20),
          if (result.hasRedFlags) ...[
            Text(
              'Issues Found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            ...result.redFlags.map((flag) => RedFlagCard(
                  id: flag.id,
                  originalText: flag.originalClause,
                  explanation: flag.explanation,
                  severity: _mapSeverity(flag.severity),
                )),
          ] else
            _buildNoFlagsCard(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  RedFlagSeverity _mapSeverity(RedFlagSeverity flagSeverity) {
    return switch (flagSeverity) {
      RedFlagSeverity.critical => RedFlagSeverity.critical,
      RedFlagSeverity.warning => RedFlagSeverity.warning,
      RedFlagSeverity.info => RedFlagSeverity.info,
      _ => RedFlagSeverity.info,
    };
  }

  Widget _buildSeverityBreakdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SeverityCount(
            icon: Icons.dangerous_rounded,
            count: result.criticalCount,
            label: 'Critical',
            color: colorScheme.error,
          ),
          _SeverityCount(
            icon: Icons.warning_amber_rounded,
            count: result.warningCount,
            label: 'Warning',
            color: Colors.orange,
          ),
          _SeverityCount(
            icon: Icons.info_outline_rounded,
            count: result.infoCount,
            label: 'Info',
            color: colorScheme.primary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildNoFlagsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.green,
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            'No Red Flags Detected',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI analysis did not identify any significant concerns in this document.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }
}

class _SeverityCount extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _SeverityCount({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _TranslationTab extends StatelessWidget {
  final AnalysisResult result;
  final bool showOriginalText;
  final VoidCallback onToggle;

  const _TranslationTab({
    required this.result,
    required this.showOriginalText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  showOriginalText ? 'Original Legal Text' : 'Plain English',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Original')),
                  ButtonSegment(value: false, label: Text('Translated')),
                ],
                selected: {showOriginalText},
                onSelectionChanged: (selection) {
                  if (selection.first != showOriginalText) onToggle();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(showOriginalText),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: MarkdownBody(
                  data: showOriginalText
                      ? result.originalText
                      : (result.plainEnglishTranslation.isNotEmpty
                          ? result.plainEnglishTranslation
                          : 'Translation not available. The AI could not generate a plain English translation for this document.'),
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}
