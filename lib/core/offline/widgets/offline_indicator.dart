import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/theme/app_colors.dart';
import 'package:legalease/core/offline/providers/connectivity_providers.dart';

class OfflineIndicator extends ConsumerWidget {
  final Widget child;

  const OfflineIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    return Column(
      children: [
        if (isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.9),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'You are offline. Some features may be limited.',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final connectionStatus = ref.watch(connectionStatusProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline ? AppColors.success : AppColors.warning,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isOnline ? AppColors.success : AppColors.warning,
              ),
        ),
      ],
    );
  }
}