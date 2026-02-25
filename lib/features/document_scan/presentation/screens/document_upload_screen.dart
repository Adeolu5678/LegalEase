import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';
import 'package:legalease/features/document_scan/presentation/widgets/document_source_selector.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  int _currentIndex = 0;

  void _handleSourceSelected(DocumentSource source, dynamic file) {
    ref.read(analysisNotifierProvider.notifier).startAnalysis();
    context.push('/analysis/processing');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recentAnalyses = ref.watch(recentAnalysesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {},
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gavel_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'LegalEase',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(context),
              const SizedBox(height: 32),
              _buildUploadOptions(context),
              if (recentAnalyses.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildRecentAnalyses(context, recentAnalyses),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.document_scanner_rounded,
            size: 48,
            color: colorScheme.onPrimaryContainer,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),
          const SizedBox(height: 16),
          Text(
            'Understand any legal document in seconds',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Upload a contract, agreement, or legal document and get instant AI-powered analysis with plain English explanations.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: -0.2),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildUploadOptions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Document',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _UploadOptionCard(
                icon: Icons.camera_alt_rounded,
                title: 'Camera',
                subtitle: 'Scan document',
                color: colorScheme.primaryContainer,
                iconColor: colorScheme.onPrimaryContainer,
                onTap: () => _handleSourceSelected(DocumentSource.camera, null),
              ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideX(begin: -0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UploadOptionCard(
                icon: Icons.photo_library_rounded,
                title: 'Gallery',
                subtitle: 'Select photo',
                color: colorScheme.secondaryContainer,
                iconColor: colorScheme.onSecondaryContainer,
                onTap: () => _handleSourceSelected(DocumentSource.gallery, null),
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms).slideY(begin: 0.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UploadOptionCard(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Files',
                subtitle: 'PDF documents',
                color: colorScheme.tertiaryContainer,
                iconColor: colorScheme.onTertiaryContainer,
                onTap: () => _handleSourceSelected(DocumentSource.file, null),
              ).animate().fadeIn(duration: 400.ms, delay: 550.ms).slideX(begin: 0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAnalyses(BuildContext context, List<AnalysisResult> analyses) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Analyses',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(delay: 600.ms),
            TextButton(
              onPressed: () => context.push('/history'),
              child: const Text('View All'),
            ).animate().fadeIn(delay: 650.ms),
          ],
        ),
        const SizedBox(height: 12),
        ...analyses.take(3).map((analysis) => _RecentAnalysisCard(
              analysis: analysis,
              onTap: () => context.push('/analysis/result/${analysis.documentId}'),
            )),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms);
  }

  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            context.push('/chat');
            break;
          case 2:
            context.push('/history');
            break;
          case 3:
            context.push('/settings');
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}

class _UploadOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _UploadOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: iconColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: iconColor.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentAnalysisCard extends StatelessWidget {
  final AnalysisResult analysis;
  final VoidCallback? onTap;

  const _RecentAnalysisCard({
    required this.analysis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.metadata.fileName ?? 'Untitled Document',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      analysis.metadata.typeName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (analysis.hasRedFlags) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: analysis.hasCriticalFlags
                        ? colorScheme.errorContainer
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        analysis.hasCriticalFlags
                            ? Icons.error_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: analysis.hasCriticalFlags
                            ? colorScheme.onErrorContainer
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${analysis.redFlags.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: analysis.hasCriticalFlags
                                  ? colorScheme.onErrorContainer
                                  : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1);
  }
}
