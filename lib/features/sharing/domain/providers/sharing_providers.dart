import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/sharing/data/models/shared_analysis.dart';
import 'package:legalease/features/sharing/data/services/sharing_service.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';

final sharingServiceProvider = Provider<SharingService>((ref) {
  return SharingService();
});

final shareCodeProvider = StateProvider.autoDispose<String>((ref) => '');

final sharePasswordProvider = StateProvider.autoDispose<String>((ref) => '');

final shareExpirationProvider = StateProvider.autoDispose<ShareExpiration>((ref) => ShareExpiration.sevenDays);

final sharedAnalysisProvider = FutureProvider.family<SharedAnalysis?, String>((ref, shareCode) async {
  final service = ref.watch(sharingServiceProvider);
  return service.getSharedAnalysis(shareCode);
});

final userSharesProvider = FutureProvider<List<SharedAnalysis>>((ref) async {
  final service = ref.watch(sharingServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];
  return service.getUserShares(user.uid);
});

final createShareProvider = FutureProvider.family<SharedAnalysis?, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(sharingServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return null;

  return service.createShareLink(
    documentId: params['documentId'] as String,
    ownerId: user.uid,
    ownerName: user.displayName ?? 'Unknown',
    ownerEmail: user.email ?? '',
    documentTitle: params['documentTitle'] as String,
    expiration: ref.watch(shareExpirationProvider),
    password: ref.watch(sharePasswordProvider).isNotEmpty 
        ? ref.watch(sharePasswordProvider) 
        : null,
  );
});
