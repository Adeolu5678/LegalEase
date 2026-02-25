import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PendingOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OfflineCacheService {
  static const String _pendingOpsKey = 'pending_operations';
  static const String _cachePrefix = 'cache_';

  final SharedPreferences _prefs;

  OfflineCacheService(this._prefs);

  Future<void> cacheDocument(String documentId, Map<String, dynamic> data) async {
    await _prefs.setString('$_cachePrefix$documentId', jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getCachedDocument(String documentId) async {
    final data = _prefs.getString('$_cachePrefix$documentId');
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> removeCachedDocument(String documentId) async {
    await _prefs.remove('$_cachePrefix$documentId');
  }

  Future<void> addPendingOperation(PendingOperation operation) async {
    final ops = await getPendingOperations();
    ops.add(operation);
    await _prefs.setString(_pendingOpsKey, jsonEncode(ops.map((o) => o.toJson()).toList()));
  }

  Future<List<PendingOperation>> getPendingOperations() async {
    final data = _prefs.getString(_pendingOpsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List<dynamic>;
    return list.map((o) => PendingOperation.fromJson(o as Map<String, dynamic>)).toList();
  }

  Future<void> removePendingOperation(String operationId) async {
    final ops = await getPendingOperations();
    ops.removeWhere((o) => o.id == operationId);
    await _prefs.setString(_pendingOpsKey, jsonEncode(ops.map((o) => o.toJson()).toList()));
  }

  Future<void> clearPendingOperations() async {
    await _prefs.remove(_pendingOpsKey);
  }

  int getPendingOperationsCount() {
    final data = _prefs.getString(_pendingOpsKey);
    if (data == null) return 0;
    final list = jsonDecode(data) as List<dynamic>;
    return list.length;
  }

  Future<void> cacheAnalysisResult(String documentId, Map<String, dynamic> result) async {
    await cacheDocument('analysis_$documentId', result);
  }

  Future<Map<String, dynamic>?> getCachedAnalysisResult(String documentId) async {
    return getCachedDocument('analysis_$documentId');
  }

  DateTime? getLastSyncTime() {
    final timeStr = _prefs.getString('last_sync_time');
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _prefs.setString('last_sync_time', time.toIso8601String());
  }
}