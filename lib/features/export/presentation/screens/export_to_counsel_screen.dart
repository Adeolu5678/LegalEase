import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/export/domain/providers/export_providers.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/core/theme/app_colors.dart';

class ExportToCounselScreen extends ConsumerStatefulWidget {
  final AnalysisResult analysisResult;

  const ExportToCounselScreen({
    super.key,
    required this.analysisResult,
  });

  @override
  ConsumerState<ExportToCounselScreen> createState() => _ExportToCounselScreenState();
}

class _ExportToCounselScreenState extends ConsumerState<ExportToCounselScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _includeFullDocument = true;
  bool _includeRedFlags = true;
  bool _includeTranslation = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExporting = ref.watch(isExportingProvider);
    final exportError = ref.watch(exportErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export to Counsel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(colorScheme),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Attorney Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Attorney Name (Optional)',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Attorney Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Message',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Add a personal message (Optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Include in Report',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildIncludeOptions(),
              if (exportError != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: AppBorderRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          exportError,
                          style: TextStyle(color: AppColors.error, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isExporting ? null : _handleExport,
                  icon: isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(isExporting ? 'Sending...' : 'Send to Counsel'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppBorderRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.mdAll,
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.analysisResult.metadata.fileName ?? 'Document',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.analysisResult.redFlags.length} red flags detected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncludeOptions() {
    return Column(
      children: [
        _buildCheckboxTile(
          title: 'Full Document Analysis',
          subtitle: 'Include summary, metadata, and processing details',
          value: _includeFullDocument,
          onChanged: (value) => setState(() => _includeFullDocument = value ?? true),
        ),
        _buildCheckboxTile(
          title: 'Red Flags Report',
          subtitle: 'Include all detected issues with explanations',
          value: _includeRedFlags,
          onChanged: (value) => setState(() => _includeRedFlags = value ?? true),
        ),
        _buildCheckboxTile(
          title: 'Plain English Translation',
          subtitle: 'Include the simplified translation of legal terms',
          value: _includeTranslation,
          onChanged: (value) => setState(() => _includeTranslation = value ?? true),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: CheckboxListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(isExportingProvider.notifier).state = true;
    ref.read(exportErrorProvider.notifier).state = null;

    try {
      final exportService = ref.read(exportServiceProvider);
      await exportService.exportToCounsel(
        result: widget.analysisResult,
        attorneyEmail: _emailController.text.trim(),
        attorneyName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
        customMessage: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email client opened successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      ref.read(exportErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(isExportingProvider.notifier).state = false;
    }
  }
}
