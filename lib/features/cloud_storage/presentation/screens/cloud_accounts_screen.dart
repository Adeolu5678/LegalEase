import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/theme/app_spacing.dart';
import 'package:legalease/features/cloud_storage/data/models/cloud_provider.dart';
import 'package:legalease/features/cloud_storage/domain/providers/cloud_providers.dart';
import 'package:intl/intl.dart';

class CloudAccountsScreen extends ConsumerStatefulWidget {
  const CloudAccountsScreen({super.key});

  @override
  ConsumerState<CloudAccountsScreen> createState() => _CloudAccountsScreenState();
}

class _CloudAccountsScreenState extends ConsumerState<CloudAccountsScreen> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(cloudAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Storage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connected Accounts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            accounts.when(
              data: (accountList) => _buildAccountsList(context, accountList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Available Services',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildProviderCard(
              context,
              CloudProvider.googleDrive,
              'Google Drive',
              Colors.blue,
              Icons.cloud,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildProviderCard(
              context,
              CloudProvider.dropbox,
              'Dropbox',
              Colors.lightBlue,
              Icons.folder_shared,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildProviderCard(
              context,
              CloudProvider.oneDrive,
              'OneDrive',
              Colors.blueAccent,
              Icons.cloud_queue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, List<CloudAccount> accounts) {
    if (accounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No cloud accounts connected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: accounts.map((account) => Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getProviderColor(account.provider).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getProviderIcon(account.provider),
              color: _getProviderColor(account.provider),
            ),
          ),
          title: Text(account.providerName),
          subtitle: Text(account.email),
          trailing: TextButton(
            onPressed: () => _disconnectAccount(account),
            child: Text(
              'Disconnect',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    CloudProvider provider,
    String name,
    Color color,
    IconData icon,
  ) {
    final isConnected = ref.watch(isConnectedProvider(provider));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isConnected ? 'Connected' : 'Not connected',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isConnected ? AppColors.success : Theme.of(context).disabledColor,
                        ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              Icon(Icons.check_circle, color: AppColors.success)
            else
              FilledButton.tonal(
                onPressed: _isConnecting ? null : () => _connectProvider(provider),
                child: _isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Color _getProviderColor(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.googleDrive:
        return Colors.blue;
      case CloudProvider.dropbox:
        return Colors.lightBlue;
      case CloudProvider.oneDrive:
        return Colors.blueAccent;
    }
  }

  IconData _getProviderIcon(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.googleDrive:
        return Icons.cloud;
      case CloudProvider.dropbox:
        return Icons.folder_shared;
      case CloudProvider.oneDrive:
        return Icons.cloud_queue;
    }
  }

  Future<void> _connectProvider(CloudProvider provider) async {
    setState(() => _isConnecting = true);

    try {
      switch (provider) {
        case CloudProvider.googleDrive:
          await ref.read(googleDriveServiceProvider).connect();
          break;
        case CloudProvider.dropbox:
          await ref.read(dropboxServiceProvider).connect();
          break;
        case CloudProvider.oneDrive:
          await ref.read(oneDriveServiceProvider).connect();
          break;
      }

      ref.invalidate(cloudAccountsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connected to ${_getProviderName(provider)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  Future<void> _disconnectAccount(CloudAccount account) async {
    try {
      switch (account.provider) {
        case CloudProvider.googleDrive:
          await ref.read(googleDriveServiceProvider).disconnect(account.id);
          break;
        case CloudProvider.dropbox:
          await ref.read(dropboxServiceProvider).disconnect(account.id);
          break;
        case CloudProvider.oneDrive:
          await ref.read(oneDriveServiceProvider).disconnect(account.id);
          break;
      }

      ref.invalidate(cloudAccountsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account disconnected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disconnect: $e')),
        );
      }
    }
  }

  String _getProviderName(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.googleDrive:
        return 'Google Drive';
      case CloudProvider.dropbox:
        return 'Dropbox';
      case CloudProvider.oneDrive:
        return 'OneDrive';
    }
  }
}
