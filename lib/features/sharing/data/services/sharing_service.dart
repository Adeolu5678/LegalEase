import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legalease/features/sharing/data/models/shared_analysis.dart';

class SharingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _sharedRef =>
      _firestore.collection('shared_analyses');

  String _generateShareCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  DateTime? _calculateExpiration(ShareExpiration expiration) {
    switch (expiration) {
      case ShareExpiration.oneHour:
        return DateTime.now().add(const Duration(hours: 1));
      case ShareExpiration.twentyFourHours:
        return DateTime.now().add(const Duration(hours: 24));
      case ShareExpiration.sevenDays:
        return DateTime.now().add(const Duration(days: 7));
      case ShareExpiration.thirtyDays:
        return DateTime.now().add(const Duration(days: 30));
      case ShareExpiration.never:
        return null;
    }
  }

  Future<SharedAnalysis> createShareLink({
    required String documentId,
    required String ownerId,
    required String ownerName,
    required String ownerEmail,
    required String documentTitle,
    ShareExpiration expiration = ShareExpiration.sevenDays,
    String? password,
    List<String>? allowedEmails,
  }) async {
    final shareCode = _generateShareCode();
    final expiresAt = _calculateExpiration(expiration);

    final sharedAnalysis = SharedAnalysis(
      id: '',
      documentId: documentId,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      documentTitle: documentTitle,
      shareCode: shareCode,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      password: password,
      isPasswordProtected: password != null && password.isNotEmpty,
      allowedEmails: allowedEmails,
    );

    final docRef = await _sharedRef.add(sharedAnalysis.toJson());
    return sharedAnalysis.copyWith(id: docRef.id);
  }

  Future<SharedAnalysis?> getSharedAnalysis(String shareCode) async {
    final snapshot = await _sharedRef
        .where('shareCode', isEqualTo: shareCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final shared = SharedAnalysis.fromJson({'id': doc.id, ...doc.data()});

    if (shared.isExpired) {
      await _sharedRef.doc(doc.id).delete();
      return null;
    }

    return shared;
  }

  Future<void> incrementViewCount(String shareId) async {
    await _sharedRef.doc(shareId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<bool> verifyPassword(String shareCode, String password) async {
    final shared = await getSharedAnalysis(shareCode);
    if (shared == null) return false;
    return shared.password == password;
  }

  Future<List<SharedAnalysis>> getUserShares(String userId) async {
    final snapshot = await _sharedRef
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SharedAnalysis.fromJson({'id': doc.id, ...doc.data()}))
        .where((s) => !s.isExpired)
        .toList();
  }

  Future<void> deleteShare(String shareId) async {
    await _sharedRef.doc(shareId).delete();
  }

  Future<void> extendExpiration(String shareId, ShareExpiration expiration) async {
    final expiresAt = _calculateExpiration(expiration);
    await _sharedRef.doc(shareId).update({
      'expiresAt': expiresAt?.toIso8601String(),
    });
  }

  String generateShareUrl(String shareCode) {
    return 'https://legalease.app/share/$shareCode';
  }

  String generateQrCodeData(String shareCode) {
    return generateShareUrl(shareCode);
  }
}
