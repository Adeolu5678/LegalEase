import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/comparison/data/services/comparison_service.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';

final comparisonServiceProvider = Provider<ComparisonService>((ref) {
  return ComparisonService();
});

final document1IdProvider = StateProvider<String?>((ref) => null);
final document2IdProvider = StateProvider<String?>((ref) => null);

final document1Provider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final docId = ref.watch(document1IdProvider);
  if (docId == null) return null;
  
  final service = ref.watch(comparisonServiceProvider);
  return service.getDocument(docId);
});

final document2Provider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final docId = ref.watch(document2IdProvider);
  if (docId == null) return null;
  
  final service = ref.watch(comparisonServiceProvider);
  return service.getDocument(docId);
});

final userDocumentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(comparisonServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];
  
  return service.getUserDocuments(user.uid);
});

final comparisonResultProvider = FutureProvider<DiffResult?>((ref) async {
  final doc1Async = ref.watch(document1Provider);
  final doc2Async = ref.watch(document2Provider);
  
  if (doc1Async.value == null || doc2Async.value == null) return null;
  
  final text1 = doc1Async.value!['originalText'] as String? ?? '';
  final text2 = doc2Async.value!['originalText'] as String? ?? '';
  
  final service = ref.watch(comparisonServiceProvider);
  return service.compareTexts(text1, text2);
});

final redFlagDifferencesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final doc1Async = ref.watch(document1Provider);
  final doc2Async = ref.watch(document2Provider);
  
  if (doc1Async.value == null || doc2Async.value == null) return [];
  
  final redFlags1 = doc1Async.value!['redFlags'] as List<dynamic>? ?? [];
  final redFlags2 = doc2Async.value!['redFlags'] as List<dynamic>? ?? [];
  
  final service = ref.watch(comparisonServiceProvider);
  return service.findRedFlagDifferences(redFlags1, redFlags2);
});

final comparisonSummaryProvider = Provider<String?>((ref) {
  final doc1Async = ref.watch(document1Provider);
  final doc2Async = ref.watch(document2Provider);
  final resultAsync = ref.watch(comparisonResultProvider);
  
  if (doc1Async.value == null || doc2Async.value == null) return null;
  if (resultAsync.value == null) return null;
  
  final title1 = doc1Async.value!['title'] as String? ?? 'Document 1';
  final title2 = doc2Async.value!['title'] as String? ?? 'Document 2';
  
  final service = ref.watch(comparisonServiceProvider);
  return service.generateComparisonSummary(resultAsync.value!, title1, title2);
});
