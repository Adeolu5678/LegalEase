import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/document_scan/data/models/ocr_result_model.dart';
import 'package:legalease/features/document_scan/data/services/document_processor.dart';
import 'package:legalease/features/document_scan/data/services/ocr_service.dart';
import 'package:legalease/shared/models/document_model.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

final documentProcessorProvider = Provider<DocumentProcessor>((ref) {
  return DocumentProcessor();
});

final ocrStateProvider = StateNotifierProvider<OcrStateNotifier, OcrState>((ref) {
  return OcrStateNotifier(ref.watch(ocrServiceProvider));
});

class OcrState {
  final ProcessingStatus status;
  final OcrResultModel? currentResult;
  final MultiPageOcrResult? multiPageResult;
  final StructuredDocument? structuredDocument;
  final String? error;
  final double progress;

  const OcrState({
    this.status = ProcessingStatus.idle,
    this.currentResult,
    this.multiPageResult,
    this.structuredDocument,
    this.error,
    this.progress = 0.0,
  });

  bool get isProcessing => status == ProcessingStatus.processing || status == ProcessingStatus.loading;
  bool get hasResult => currentResult != null || multiPageResult != null;
  bool get hasError => status == ProcessingStatus.error;
  bool get isCompleted => status == ProcessingStatus.completed;

  OcrState copyWith({
    ProcessingStatus? status,
    OcrResultModel? currentResult,
    MultiPageOcrResult? multiPageResult,
    StructuredDocument? structuredDocument,
    String? error,
    double? progress,
  }) {
    return OcrState(
      status: status ?? this.status,
      currentResult: currentResult ?? this.currentResult,
      multiPageResult: multiPageResult ?? this.multiPageResult,
      structuredDocument: structuredDocument ?? this.structuredDocument,
      error: error,
      progress: progress ?? this.progress,
    );
  }
}

class OcrStateNotifier extends StateNotifier<OcrState> {
  final OcrService _ocrService;

  OcrStateNotifier(this._ocrService) : super(const OcrState());

  Future<OcrResultModel?> processImage(File imageFile) async {
    state = state.copyWith(status: ProcessingStatus.processing, error: null);

    try {
      final result = await _ocrService.extractTextFromImage(imageFile);
      state = state.copyWith(
        status: ProcessingStatus.completed,
        currentResult: result,
        progress: 1.0,
      );
      return result;
    } catch (e) {
      state = state.copyWith(
        status: ProcessingStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<MultiPageOcrResult?> processImages(List<File> images) async {
    state = state.copyWith(status: ProcessingStatus.processing, error: null);

    try {
      final results = <OcrResultModel>[];
      
      for (var i = 0; i < images.length; i++) {
        state = state.copyWith(
          progress: (i + 1) / images.length,
        );
        
        final result = await _ocrService.extractTextFromImage(images[i]);
        results.add(result);
      }

      final validResults = results.where((r) => r.isNotEmpty).toList();
      final avgConfidence = validResults.isEmpty
          ? 0.0
          : validResults.map((r) => r.confidence).reduce((a, b) => a + b) / validResults.length;

      final totalTime = results.fold<Duration>(
        Duration.zero,
        (sum, r) => sum + r.processingTime,
      );

      final multiPageResult = MultiPageOcrResult(
        pages: results,
        totalProcessingTime: totalTime,
        averageConfidence: avgConfidence,
      );

      state = state.copyWith(
        status: ProcessingStatus.completed,
        multiPageResult: multiPageResult,
        progress: 1.0,
      );

      return multiPageResult;
    } catch (e) {
      state = state.copyWith(
        status: ProcessingStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  Future<StructuredDocument?> structureText(String text) async {
    state = state.copyWith(status: ProcessingStatus.processing);

    try {
      final processor = DocumentProcessor();
      final structured = await processor.structureDocument(text);
      state = state.copyWith(
        status: ProcessingStatus.completed,
        structuredDocument: structured,
      );
      return structured;
    } catch (e) {
      state = state.copyWith(
        status: ProcessingStatus.error,
        error: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const OcrState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final documentTypeDetectionProvider = Provider<DocumentTypeDetector>((ref) {
  return DocumentTypeDetector();
});

class DocumentTypeDetector {
  DocumentType detect(String text) {
    final processor = DocumentProcessor();
    return processor.detectDocumentType(text);
  }

  String getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.lease:
        return 'Lease Agreement';
      case DocumentType.termsConditions:
        return 'Terms & Conditions';
      case DocumentType.privacyPolicy:
        return 'Privacy Policy';
      case DocumentType.eula:
        return 'End User License Agreement';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  String getDocumentTypeDescription(DocumentType type) {
    switch (type) {
      case DocumentType.contract:
        return 'A legally binding agreement between parties';
      case DocumentType.lease:
        return 'A rental agreement for property or equipment';
      case DocumentType.termsConditions:
        return 'Rules and guidelines for using a service';
      case DocumentType.privacyPolicy:
        return 'How personal data is collected and used';
      case DocumentType.eula:
        return 'Software license agreement';
      case DocumentType.other:
        return 'General legal document';
    }
  }
}
