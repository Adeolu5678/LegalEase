import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/annotations/data/models/annotation.dart';
import 'package:legalease/features/annotations/data/services/annotation_service.dart';
import 'package:legalease/features/auth/domain/providers/auth_providers.dart';

final annotationServiceProvider = Provider<AnnotationService>((ref) {
  return AnnotationService();
});

final documentAnnotationsProvider =
    StreamProvider.family<List<Annotation>, String>((ref, documentId) {
  final service = ref.watch(annotationServiceProvider);
  return service.watchAnnotationsForDocument(documentId);
});

final userAnnotationsProvider =
    FutureProvider.family<List<Annotation>, String>((ref, userId) async {
  final service = ref.watch(annotationServiceProvider);
  return service.getAnnotationsForUser(userId);
});

final currentUserAnnotationsProvider = FutureProvider<List<Annotation>>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return [];
  final service = ref.watch(annotationServiceProvider);
  return service.getAnnotationsForUser(user.uid);
});

final annotationFilterTypeProvider =
    StateProvider.autoDispose<AnnotationType?>((ref) => null);

final annotationFilterResolvedProvider =
    StateProvider.autoDispose<bool?>((ref) => null);

final filteredAnnotationsProvider =
    Provider.family<List<Annotation>, String>((ref, documentId) {
  final annotationsAsync = ref.watch(documentAnnotationsProvider(documentId));
  final filterType = ref.watch(annotationFilterTypeProvider);
  final filterResolved = ref.watch(annotationFilterResolvedProvider);

  return annotationsAsync.when(
    data: (annotations) {
      var filtered = annotations;
      
      if (filterType != null) {
        filtered = filtered.where((a) => a.type == filterType).toList();
      }
      
      if (filterResolved != null) {
        filtered = filtered.where((a) => a.isResolved == filterResolved).toList();
      }
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final selectedAnnotationProvider =
    StateProvider.autoDispose<Annotation?>((ref) => null);

final annotationDraftProvider =
    StateProvider.autoDispose<Annotation?>((ref) => null);

final annotationsStatsProvider =
    Provider.family<Map<String, int>, String>((ref, documentId) {
  final annotationsAsync = ref.watch(documentAnnotationsProvider(documentId));

  return annotationsAsync.when(
    data: (annotations) {
      return {
        'total': annotations.length,
        'comments': annotations.where((a) => a.isComment).length,
        'notes': annotations.where((a) => a.isNote).length,
        'highlights': annotations.where((a) => a.isHighlight).length,
        'questions': annotations.where((a) => a.isQuestion).length,
        'resolved': annotations.where((a) => a.isResolved).length,
        'open': annotations.where((a) => !a.isResolved).length,
        'high': annotations.where((a) => a.priority == AnnotationPriority.high).length,
      };
    },
    loading: () => {'total': 0, 'comments': 0, 'notes': 0, 'highlights': 0, 'questions': 0, 'resolved': 0, 'open': 0, 'high': 0},
    error: (_, __) => {'total': 0, 'comments': 0, 'notes': 0, 'highlights': 0, 'questions': 0, 'resolved': 0, 'open': 0, 'high': 0},
  );
});
