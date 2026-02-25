import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:legalease/features/cloud_storage/data/models/cloud_provider.dart' as models;

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<models.CloudAccount?> connect() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      
      final cloudAccount = models.CloudAccount(
        id: '',
        userId: account.id,
        provider: models.CloudProvider.googleDrive,
        displayName: account.displayName ?? 'Unknown',
        email: account.email,
        accessToken: auth.accessToken ?? '',
        refreshToken: null,
        connectedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final docRef = await _firestore
          .collection('cloud_accounts')
          .add(cloudAccount.toJson());
      
      return cloudAccount.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disconnect(String accountId) async {
    await _googleSignIn.signOut();
    await _firestore.collection('cloud_accounts').doc(accountId).delete();
  }

  Future<List<models.CloudFile>> listFiles({
    String? folderId,
    int pageSize = 50,
  }) async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      throw Exception('Not connected to Google Drive');
    }

    return _getMockFiles();
  }

  Future<List<models.CloudFile>> searchFiles(String query) async {
    return _getMockFiles().where((f) => 
        f.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<String?> downloadFile(String fileId) async {
    return 'mock_file_path_$fileId.pdf';
  }

  Future<void> uploadFile(String localPath, String? folderId) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  List<models.CloudFile> _getMockFiles() {
    return [
      const models.CloudFile(
        id: '1',
        name: 'Contract 2024.pdf',
        path: '/Documents/Contracts',
        size: 245760,
        mimeType: 'application/pdf',
      ),
      const models.CloudFile(
        id: '2',
        name: 'Employment Agreement.pdf',
        path: '/Documents/HR',
        size: 184320,
        mimeType: 'application/pdf',
      ),
      const models.CloudFile(
        id: '3',
        name: 'Documents',
        path: '/Documents',
        isFolder: true,
      ),
      const models.CloudFile(
        id: '4',
        name: 'Privacy Policy.docx',
        path: '/Documents/Legal',
        size: 102400,
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ),
      const models.CloudFile(
        id: '5',
        name: 'NDA Template.pdf',
        path: '/Documents/Templates',
        size: 51200,
        mimeType: 'application/pdf',
      ),
    ];
  }
}

class DropboxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<models.CloudAccount?> connect() async {
    final cloudAccount = models.CloudAccount(
      id: '',
      userId: 'mock_user_id',
      provider: models.CloudProvider.dropbox,
      displayName: 'Dropbox User',
      email: 'user@dropbox.com',
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      connectedAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('cloud_accounts')
        .add(cloudAccount.toJson());
    
    return cloudAccount.copyWith(id: docRef.id);
  }

  Future<void> disconnect(String accountId) async {
    await _firestore.collection('cloud_accounts').doc(accountId).delete();
  }

  Future<List<models.CloudFile>> listFiles({String? folderId}) async {
    return [
      const models.CloudFile(
        id: 'd1',
        name: 'Legal Documents',
        path: '/Legal Documents',
        isFolder: true,
      ),
      const models.CloudFile(
        id: 'd2',
        name: 'Service Agreement.pdf',
        path: '/Legal Documents',
        size: 327680,
        mimeType: 'application/pdf',
      ),
    ];
  }

  Future<List<models.CloudFile>> searchFiles(String query) async {
    return [];
  }

  Future<String?> downloadFile(String fileId) async {
    return 'mock_dropbox_file_$fileId.pdf';
  }

  Future<void> uploadFile(String localPath, String? folderId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}

class OneDriveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<models.CloudAccount?> connect() async {
    final cloudAccount = models.CloudAccount(
      id: '',
      userId: 'mock_user_id',
      provider: models.CloudProvider.oneDrive,
      displayName: 'OneDrive User',
      email: 'user@outlook.com',
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
      connectedAt: DateTime.now(),
    );

    final docRef = await _firestore
        .collection('cloud_accounts')
        .add(cloudAccount.toJson());
    
    return cloudAccount.copyWith(id: docRef.id);
  }

  Future<void> disconnect(String accountId) async {
    await _firestore.collection('cloud_accounts').doc(accountId).delete();
  }

  Future<List<models.CloudFile>> listFiles({String? folderId}) async {
    return [
      const models.CloudFile(
        id: 'o1',
        name: 'Work Documents',
        path: '/Work Documents',
        isFolder: true,
      ),
      const models.CloudFile(
        id: 'o2',
        name: 'Lease Agreement.pdf',
        path: '/Work Documents',
        size: 409600,
        mimeType: 'application/pdf',
      ),
    ];
  }

  Future<List<models.CloudFile>> searchFiles(String query) async {
    return [];
  }

  Future<String?> downloadFile(String fileId) async {
    return 'mock_onedrive_file_$fileId.pdf';
  }

  Future<void> uploadFile(String localPath, String? folderId) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
