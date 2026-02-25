import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/sharing/data/models/shared_analysis.dart';
import 'package:legalease/features/sharing/domain/providers/sharing_providers.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';
import 'package:intl/intl.dart';

class ShareAnalysisScreen extends ConsumerStatefulWidget {
  final AnalysisResult analysisResult;

  const ShareAnalysisScreen({super.key, required this.analysisResult});

  @override
  ConsumerState<ShareAnalysisScreen> createState() => _ShareAnalysisScreenState();
}

class _ShareAnalysisScreenState extends ConsumerState<ShareAnalysisScreen> {
  final _passwordController = TextEditingController();
  ShareExpiration _selectedExpiration = ShareExpiration.sevenDays;
  bool _passwordProtection = false;
  SharedAnalysis? _createdShare;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Analysis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: _createdShare != null
            ? _buildShareResult(context, _createdShare!)
            : _buildCreateShareForm(context),
      ),
    );
  }

  Widget _buildCreateShareForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.analysisResult.metadata.fileName ?? 'Document',
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${widget.analysisResult.redFlags.length} red flags • ${widget.analysisResult.metadata.wordCount} words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Expiration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          children: ShareExpiration.values.map((exp) => ChoiceChip(
                label: Text(_getExpirationLabel(exp)),
                selected: _selectedExpiration == exp,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedExpiration = exp);
                  }
                },
              )).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Switch(
              value: _passwordProtection,
              onChanged: (value) {
                setState(() => _passwordProtection = value);
              },
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Password Protection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (_passwordProtection) ...[
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              hintText: 'Enter a password for the share link',
            ),
            obscureText: true,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _createShare,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link),
            label: Text(_isLoading ? 'Creating...' : 'Create Share Link'),
          ),
        ),
      ],
    );
  }

  Widget _buildShareResult(BuildContext context, SharedAnalysis share) {
    final shareUrl = 'https://legalease.app/share/${share.shareCode}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Share link created successfully!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.success,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  share.shareCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Share Code',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                share.shareCode,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: share.shareCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Share Link',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: TextEditingController(text: shareUrl),
          readOnly: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildShareDetails(context, share),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _createdShare = null);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Create New'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShareDetails(BuildContext context, SharedAnalysis share) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildDetailRow(
              context,
              Icons.access_time,
              'Created',
              DateFormat('MMM d, y h:mm a').format(share.createdAt),
            ),
            if (share.expiresAt != null)
              _buildDetailRow(
                context,
                Icons.timer_outlined,
                'Expires',
                DateFormat('MMM d, y h:mm a').format(share.expiresAt!),
              ),
            if (share.isPasswordProtected)
              _buildDetailRow(
                context,
                Icons.lock,
                'Protected',
                'Yes',
              ),
            _buildDetailRow(
              context,
              Icons.visibility,
              'Views',
              share.viewCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).disabledColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getExpirationLabel(ShareExpiration exp) {
    switch (exp) {
      case ShareExpiration.oneHour:
        return '1 Hour';
      case ShareExpiration.twentyFourHours:
        return '24 Hours';
      case ShareExpiration.sevenDays:
        return '7 Days';
      case ShareExpiration.thirtyDays:
        return '30 Days';
      case ShareExpiration.never:
        return 'Never';
    }
  }

  Future<void> _createShare() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(sharingServiceProvider);
      final user = ref.read(authStateChangesProvider).value;
      
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to share')),
          );
        }
        return;
      }

      final share = await service.createShareLink(
        documentId: widget.analysisResult.documentId,
        ownerId: user.uid,
        ownerName: user.displayName ?? 'Unknown',
        ownerEmail: user.email ?? '',
        documentTitle: widget.analysisResult.metadata.fileName ?? 'Document',
        expiration: _selectedExpiration,
        password: _passwordProtection && _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
      );

      if (mounted) {
        setState(() => _createdShare = share);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating share: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
