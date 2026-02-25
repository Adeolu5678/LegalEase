import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/export/domain/providers/export_providers.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';

enum ExportFormat { pdf, print, share }

class ExportButton extends ConsumerWidget {
  final AnalysisResult analysisResult;
  final bool showLabel;

  const ExportButton({
    super.key,
    required this.analysisResult,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExporting = ref.watch(isExportingProvider);

    return PopupMenuButton<ExportFormat>(
      icon: isExporting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_rounded),
      tooltip: 'Export',
      onSelected: (format) => _handleExport(context, ref, format),
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          value: ExportFormat.pdf,
          icon: Icons.picture_as_pdf_rounded,
          label: 'Export as PDF',
          subtitle: 'Save to device',
        ),
        _buildMenuItem(
          context,
          value: ExportFormat.share,
          icon: Icons.share_rounded,
          label: 'Share PDF',
          subtitle: 'Share via apps',
        ),
        _buildMenuItem(
          context,
          value: ExportFormat.print,
          icon: Icons.print_rounded,
          label: 'Print',
          subtitle: 'Send to printer',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          value: null,
          icon: Icons.email_outlined,
          label: 'Export to Counsel',
          subtitle: 'Email attorney',
          onTap: () => _navigateToCounselScreen(context),
        ),
      ],
    );
  }

  PopupMenuItem<ExportFormat> _buildMenuItem(
    BuildContext context, {
    required ExportFormat? value,
    required IconData icon,
    required String label,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return PopupMenuItem<ExportFormat>(
      value: value,
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    ref.read(isExportingProvider.notifier).state = true;
    ref.read(exportErrorProvider.notifier).state = null;

    try {
      final exportService = ref.read(exportServiceProvider);
      final pdfData = await exportService.generatePdf(analysisResult);
      final filename = 'LegalEase_${analysisResult.metadata.fileName ?? 'Analysis'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      switch (format) {
        case ExportFormat.pdf:
          final path = await exportService.saveToFile(pdfData, filename);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to: $path'),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'Open',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
          break;
        case ExportFormat.share:
          await exportService.shareDocument(pdfData, filename);
          break;
        case ExportFormat.print:
          await exportService.printDocument(pdfData);
          break;
      }
    } catch (e) {
      ref.read(exportErrorProvider.notifier).state = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      ref.read(isExportingProvider.notifier).state = false;
    }
  }

  void _navigateToCounselScreen(BuildContext context) {
    context.push('/export/counsel', extra: analysisResult);
  }
}

class QuickExportFAB extends ConsumerWidget {
  final AnalysisResult analysisResult;

  const QuickExportFAB({
    super.key,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () => _showExportOptions(context, ref),
      icon: const Icon(Icons.share_rounded),
      label: const Text('Share'),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3);
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Export Analysis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('Export as PDF'),
              subtitle: const Text('Save analysis as PDF document'),
              onTap: () {
                Navigator.pop(context);
                _handleQuickExport(context, ref, ExportFormat.pdf);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share'),
              subtitle: const Text('Share via messaging or other apps'),
              onTap: () {
                Navigator.pop(context);
                _handleQuickExport(context, ref, ExportFormat.share);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_rounded),
              title: const Text('Print'),
              subtitle: const Text('Send to printer'),
              onTap: () {
                Navigator.pop(context);
                _handleQuickExport(context, ref, ExportFormat.print);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Export to Counsel'),
              subtitle: const Text('Email analysis to your attorney'),
              onTap: () {
                Navigator.pop(context);
                context.push('/export/counsel', extra: analysisResult);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _handleQuickExport(
    BuildContext context,
    WidgetRef ref,
    ExportFormat format,
  ) async {
    ref.read(isExportingProvider.notifier).state = true;

    try {
      final exportService = ref.read(exportServiceProvider);
      final pdfData = await exportService.generatePdf(analysisResult);
      final filename = 'LegalEase_Analysis_${DateTime.now().millisecondsSinceEpoch}.pdf';

      switch (format) {
        case ExportFormat.pdf:
          final path = await exportService.saveToFile(pdfData, filename);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          break;
        case ExportFormat.share:
          await exportService.shareDocument(pdfData, filename);
          break;
        case ExportFormat.print:
          await exportService.printDocument(pdfData);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      ref.read(isExportingProvider.notifier).state = false;
    }
  }
}
