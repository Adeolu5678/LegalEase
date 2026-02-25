import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';

enum SearchFilter {
  all,
  contracts,
  terms,
  privacy,
  other,
}

enum SeverityFilter {
  all,
  critical,
  warning,
  info,
}

class SearchResult {
  final String documentId;
  final String title;
  final String snippet;
  final DocumentType documentType;
  final DateTime analyzedAt;
  final int redFlagCount;
  final int criticalCount;
  final int warningCount;
  final double relevanceScore;

  const SearchResult({
    required this.documentId,
    required this.title,
    required this.snippet,
    required this.documentType,
    required this.analyzedAt,
    required this.redFlagCount,
    required this.criticalCount,
    required this.warningCount,
    required this.relevanceScore,
  });
}

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SearchResult>> searchDocuments(
    String query, {
    String? userId,
    SearchFilter documentTypeFilter = SearchFilter.all,
    SeverityFilter severityFilter = SeverityFilter.all,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) {
      return _getRecentDocuments(userId: userId, limit: limit);
    }

    final normalizedQuery = query.toLowerCase().trim();
    final searchTerms = normalizedQuery.split(RegExp(r'\s+'));

    Query<Map<String, dynamic>> queryRef = _firestore.collection('documents');

    if (userId != null) {
      queryRef = queryRef.where('userId', isEqualTo: userId);
    }

    final snapshot = await queryRef.get();
    final results = <SearchResult>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final title = (data['title'] as String?) ?? 'Untitled';
      final originalText = (data['originalText'] as String?) ?? '';
      final summary = (data['summary'] as String?) ?? '';
      final documentType = _parseDocumentType(data['type'] as String?);
      final analyzedAt = (data['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final redFlags = (data['redFlags'] as List<dynamic>?) ?? [];

      if (!_matchesDocumentTypeFilter(documentType, documentTypeFilter)) {
        continue;
      }

      if (!_matchesSeverityFilter(redFlags, severityFilter)) {
        continue;
      }

      if (!_matchesDateRange(analyzedAt, startDate, endDate)) {
        continue;
      }

      final searchableText = '$title $originalText $summary'.toLowerCase();
      double relevanceScore = 0;
      bool hasMatch = false;

      for (final term in searchTerms) {
        if (searchableText.contains(term)) {
          hasMatch = true;
          if (title.toLowerCase().contains(term)) {
            relevanceScore += 3;
          }
          if (summary.toLowerCase().contains(term)) {
            relevanceScore += 2;
          }
          if (originalText.toLowerCase().contains(term)) {
            relevanceScore += 1;
          }
        }
      }

      if (hasMatch) {
        String snippet = _generateSnippet(originalText, searchTerms);

        results.add(SearchResult(
          documentId: doc.id,
          title: title,
          snippet: snippet,
          documentType: documentType,
          analyzedAt: analyzedAt,
          redFlagCount: redFlags.length,
          criticalCount: redFlags.where((f) => (f as Map<String, dynamic>)['severity'] == 'critical').length,
          warningCount: redFlags.where((f) => (f as Map<String, dynamic>)['severity'] == 'warning').length,
          relevanceScore: relevanceScore,
        ));
      }
    }

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results.take(limit).toList();
  }

  Future<List<SearchResult>> _getRecentDocuments({
    String? userId,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> queryRef = _firestore
        .collection('documents')
        .orderBy('analyzedAt', descending: true)
        .limit(limit);

    if (userId != null) {
      queryRef = _firestore
          .collection('documents')
          .where('userId', isEqualTo: userId)
          .orderBy('analyzedAt', descending: true)
          .limit(limit);
    }

    final snapshot = await queryRef.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final title = (data['title'] as String?) ?? 'Untitled';
      final originalText = (data['originalText'] as String?) ?? '';
      final documentType = _parseDocumentType(data['type'] as String?);
      final analyzedAt = (data['analyzedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final redFlags = (data['redFlags'] as List<dynamic>?) ?? [];

      return SearchResult(
        documentId: doc.id,
        title: title,
        snippet: originalText.length > 150
            ? '${originalText.substring(0, 150)}...'
            : originalText,
        documentType: documentType,
        analyzedAt: analyzedAt,
        redFlagCount: redFlags.length,
        criticalCount: redFlags.where((f) => (f as Map<String, dynamic>)['severity'] == 'critical').length,
        warningCount: redFlags.where((f) => (f as Map<String, dynamic>)['severity'] == 'warning').length,
        relevanceScore: 0,
      );
    }).toList();
  }

  String _generateSnippet(String text, List<String> searchTerms) {
    final lowerText = text.toLowerCase();
    int? bestIndex;

    for (final term in searchTerms) {
      final index = lowerText.indexOf(term);
      if (index != -1) {
        if (bestIndex == null || index < bestIndex) {
          bestIndex = index;
        }
      }
    }

    if (bestIndex == null) {
      return text.length > 150 ? '${text.substring(0, 150)}...' : text;
    }

    final start = (bestIndex - 50).clamp(0, text.length);
    final end = (bestIndex + 150).clamp(0, text.length);

    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';

    return snippet;
  }

  DocumentType _parseDocumentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'contract':
        return DocumentType.contract;
      case 'lease':
        return DocumentType.lease;
      case 'termsconditions':
      case 'terms_conditions':
        return DocumentType.termsConditions;
      case 'privacypolicy':
      case 'privacy_policy':
        return DocumentType.privacyPolicy;
      case 'eula':
        return DocumentType.eula;
      case 'nda':
        return DocumentType.nda;
      case 'employment':
        return DocumentType.employment;
      default:
        return DocumentType.other;
    }
  }

  bool _matchesDocumentTypeFilter(DocumentType type, SearchFilter filter) {
    switch (filter) {
      case SearchFilter.all:
        return true;
      case SearchFilter.contracts:
        return type == DocumentType.contract || type == DocumentType.nda || type == DocumentType.employment;
      case SearchFilter.terms:
        return type == DocumentType.termsConditions || type == DocumentType.eula;
      case SearchFilter.privacy:
        return type == DocumentType.privacyPolicy;
      case SearchFilter.other:
        return type == DocumentType.other || type == DocumentType.lease;
    }
  }

  bool _matchesSeverityFilter(List<dynamic> redFlags, SeverityFilter filter) {
    if (filter == SeverityFilter.all) return true;

    final hasCritical = redFlags.any((f) => (f as Map<String, dynamic>)['severity'] == 'critical');
    final hasWarning = redFlags.any((f) => (f as Map<String, dynamic>)['severity'] == 'warning');
    final hasInfo = redFlags.any((f) => (f as Map<String, dynamic>)['severity'] == 'info');

    switch (filter) {
      case SeverityFilter.all:
        return true;
      case SeverityFilter.critical:
        return hasCritical;
      case SeverityFilter.warning:
        return hasWarning;
      case SeverityFilter.info:
        return hasInfo;
    }
  }

  bool _matchesDateRange(DateTime date, DateTime? start, DateTime? end) {
    if (start != null && date.isBefore(start)) return false;
    if (end != null && date.isAfter(end)) return false;
    return true;
  }

  Future<void> saveSearchQuery(String query, {String? userId}) async {
    if (query.trim().isEmpty || userId == null) return;

    await _firestore.collection('search_history').add({
      'userId': userId,
      'query': query,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getSearchHistory({String? userId, int limit = 10}) async {
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('search_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['query'] as String)
        .toSet()
        .toList();
  }

  Future<void> clearSearchHistory({String? userId}) async {
    if (userId == null) return;

    final snapshot = await _firestore
        .collection('search_history')
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
