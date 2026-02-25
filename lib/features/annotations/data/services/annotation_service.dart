import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legalease/features/annotations/data/models/annotation.dart';

class AnnotationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _annotationsRef =>
      _firestore.collection('annotations');

  Future<List<Annotation>> getAnnotationsForDocument(String documentId) async {
    final snapshot = await _annotationsRef
        .where('documentId', isEqualTo: documentId)
        .orderBy('startIndex', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => Annotation.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<List<Annotation>> getAnnotationsForUser(String userId) async {
    final snapshot = await _annotationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Annotation.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  Future<Annotation> createAnnotation(Annotation annotation) async {
    final docRef = await _annotationsRef.add(annotation.toJson());
    return annotation.copyWith(id: docRef.id);
  }

  Future<Annotation> updateAnnotation(Annotation annotation) async {
    await _annotationsRef.doc(annotation.id).update({
      ...annotation.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return annotation.copyWith(updatedAt: DateTime.now());
  }

  Future<void> deleteAnnotation(String annotationId) async {
    await _annotationsRef.doc(annotationId).delete();
  }

  Future<Annotation> resolveAnnotation(
    String annotationId,
    String resolvedBy,
  ) async {
    await _annotationsRef.doc(annotationId).update({
      'isResolved': true,
      'resolvedBy': resolvedBy,
      'resolvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _annotationsRef.doc(annotationId).get();
    return Annotation.fromJson({'id': doc.id, ...doc.data()!});
  }

  Future<Annotation> unresolveAnnotation(String annotationId) async {
    await _annotationsRef.doc(annotationId).update({
      'isResolved': false,
      'resolvedBy': null,
      'resolvedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final doc = await _annotationsRef.doc(annotationId).get();
    return Annotation.fromJson({'id': doc.id, ...doc.data()!});
  }

  Stream<List<Annotation>> watchAnnotationsForDocument(String documentId) {
    return _annotationsRef
        .where('documentId', isEqualTo: documentId)
        .orderBy('startIndex', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Annotation.fromJson({'id': doc.id, ...doc.data()}))
            .toList());
  }

  Future<Map<String, dynamic>> exportAnnotations(String documentId) async {
    final annotations = await getAnnotationsForDocument(documentId);
    
    return {
      'documentId': documentId,
      'exportedAt': DateTime.now().toIso8601String(),
      'annotations': annotations.map((a) => a.toJson()).toList(),
      'summary': {
        'total': annotations.length,
        'comments': annotations.where((a) => a.isComment).length,
        'notes': annotations.where((a) => a.isNote).length,
        'highlights': annotations.where((a) => a.isHighlight).length,
        'questions': annotations.where((a) => a.isQuestion).length,
        'resolved': annotations.where((a) => a.isResolved).length,
        'open': annotations.where((a) => !a.isResolved).length,
      },
    };
  }
}
