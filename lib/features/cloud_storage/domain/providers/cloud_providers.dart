import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/cloud_storage/data/models/cloud_provider.dart';
import 'package:legalease/features/cloud_storage/data/services/google_drive_service.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

final dropboxServiceProvider = Provider<DropboxService>((ref) {
  return DropboxService();
});

final oneDriveServiceProvider = Provider<OneDriveService>((ref) {
  return OneDriveService();
});

final cloudAccountsProvider = FutureProvider<List<CloudAccount>>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('cloud_accounts')
      .where('userId', isEqualTo: user.uid)
      .where('isActive', isEqualTo: true)
      .get();

  return snapshot.docs
      .map((doc) => CloudAccount.fromJson({'id': doc.id, ...doc.data()}))
      .toList();
});

final isConnectedProvider = Provider.family<bool, CloudProvider>((ref, provider) {
  final accountsAsync = ref.watch(cloudAccountsProvider);
  return accountsAsync.when(
    data: (accounts) => accounts.any((a) => a.provider == provider),
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentCloudFolderProvider = StateProvider<String?>((ref) => null);

final cloudFilesProvider = FutureProvider.family<List<CloudFile>, CloudProvider>((ref, provider) async {
  final googleDrive = ref.watch(googleDriveServiceProvider);
  final dropbox = ref.watch(dropboxServiceProvider);
  final oneDrive = ref.watch(oneDriveServiceProvider);
  final folderId = ref.watch(currentCloudFolderProvider);

  switch (provider) {
    case CloudProvider.googleDrive:
      return googleDrive.listFiles(folderId: folderId);
    case CloudProvider.dropbox:
      return dropbox.listFiles(folderId: folderId);
    case CloudProvider.oneDrive:
      return oneDrive.listFiles(folderId: folderId);
  }
});

final cloudSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final cloudSearchResultsProvider = FutureProvider.family<List<CloudFile>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final googleDrive = ref.watch(googleDriveServiceProvider);
  return googleDrive.searchFiles(query);
});
