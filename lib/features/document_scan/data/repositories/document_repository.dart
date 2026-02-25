import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/document_scan/data/models/ocr_result_model.dart';
import 'package:legalease/features/document_scan/data/services/document_processor.dart';
import 'package:legalease/features/document_scan/data/services/ocr_service.dart';
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/providers/ocr_provider.dart';

abstract class DocumentRepository {
  Future<DocumentModel?> processDocument(File file, String userId);
  Future<DocumentModel?> processImages(List<File> images, String userId, {String? title});
  Future<StructuredDocument?> analyzeDocument(String text);
  Future<String> extractTextFromFile(File file);
}

class DocumentRepositoryImpl implements DocumentRepository {
  final OcrService _ocrService;
  final DocumentProcessor _processor;

  DocumentRepositoryImpl(this._ocrService, this._processor);

  @override
  Future<DocumentModel?> processDocument(File file, String userId) async {
    try {
      String extractedText;
      List<OcrResultModel> ocrResults = [];

      if (_processor.isPdfFile(file)) {
        final images = await _processor.pdfToImages(file);
        ocrResults = await _ocrService.extractTextFromImages(images);
        extractedText = ocrResults.map((r) => r.text).join('\n\n');
      } else if (_processor.isImageFile(file)) {
        final result = await _ocrService.extractTextFromImage(file);
        extractedText = result.text;
        ocrResults = [result];
      } else {
        extractedText = await _processor.extractTextFromPdf(file);
      }

      if (extractedText.trim().isEmpty) {
        return null;
      }

      final structured = await _processor.structureDocument(extractedText);

      return DocumentModel(
        id: _generateId(),
        userId: userId,
        title: structured.title,
        type: structured.type,
        originalText: extractedText,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DocumentModel?> processImages(
    List<File> images,
    String userId, {
    String? title,
  }) async {
    try {
      final multiPageResult = await _ocrService.extractTextFromImagesCombined(images);

      if (multiPageResult.isEmpty) {
        return null;
      }

      final extractedText = multiPageResult.combinedText;
      final structured = await _processor.structureDocument(extractedText);

      return DocumentModel(
        id: _generateId(),
        userId: userId,
        title: title ?? structured.title,
        type: structured.type,
        originalText: extractedText,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<StructuredDocument?> analyzeDocument(String text) async {
    if (text.trim().isEmpty) return null;

    try {
      return await _processor.structureDocument(text);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> extractTextFromFile(File file) async {
    try {
      if (_processor.isPdfFile(file)) {
        return await _processor.extractTextFromPdf(file);
      } else if (_processor.isImageFile(file)) {
        final result = await _ocrService.extractTextFromImage(file);
        return result.text;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(
    ref.watch(ocrServiceProvider),
    ref.watch(documentProcessorProvider),
  );
});

final processedDocumentProvider =
    FutureProvider.family<DocumentModel?, ProcessDocumentParams>((ref, params) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.processDocument(params.file, params.userId);
});

class ProcessDocumentParams {
  final File file;
  final String userId;

  const ProcessDocumentParams({
    required this.file,
    required this.userId,
  });
}

final multiImageDocumentProvider =
    FutureProvider.family<DocumentModel?, MultiImageParams>((ref, params) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.processImages(params.images, params.userId, title: params.title);
});

class MultiImageParams {
  final List<File> images;
  final String userId;
  final String? title;

  const MultiImageParams({
    required this.images,
    required this.userId,
    this.title,
  });
}

final documentAnalysisProvider =
    FutureProvider.family<StructuredDocument?, String>((ref, text) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.analyzeDocument(text);
});
