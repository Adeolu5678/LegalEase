import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:legalease/features/document_scan/data/services/ocr_service.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/shared/providers/ai_providers.dart';

final documentScanOcrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

final currentDocumentFileProvider = StateProvider.autoDispose<File?>((ref) => null);

final analysisStateProvider = StateNotifierProvider.autoDispose<AnalysisStateNotifier, AnalysisState>((ref) {
  return AnalysisStateNotifier(ref);
});

final analysisHistoryProvider = StateProvider.autoDispose<List<AnalysisResult>>((ref) => []);

final currentAnalysisResultProvider = Provider<AnalysisResult?>((ref) {
  final state = ref.watch(analysisStateProvider);
  return state.result;
});

final processingStepProvider = StateProvider.autoDispose<ProcessingStep>((ref) => ProcessingStep.idle);

enum ProcessingStep {
  idle,
  extractingText,
  analyzingDocument,
  detectingRedFlags,
  generatingSummary,
  completed,
  error,
}

class AnalysisState {
  final AnalysisResult? result;
  final bool isProcessing;
  final String? errorMessage;
  final ProcessingStep currentStep;
  final double progress;

  const AnalysisState({
    this.result,
    this.isProcessing = false,
    this.errorMessage,
    this.currentStep = ProcessingStep.idle,
    this.progress = 0.0,
  });

  AnalysisState copyWith({
    AnalysisResult? result,
    bool? isProcessing,
    String? errorMessage,
    ProcessingStep? currentStep,
    double? progress,
  }) {
    return AnalysisState(
      result: result ?? this.result,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
    );
  }
}

class AnalysisStateNotifier extends StateNotifier<AnalysisState> {
  final Ref _ref;
  CancelableOperation<void>? _currentOperation;

  AnalysisStateNotifier(this._ref) : super(const AnalysisState());

  Future<void> analyzeDocument(File document) async {
    _currentOperation?.cancel();
    
    state = const AnalysisState(isProcessing: true, currentStep: ProcessingStep.extractingText);
    
    _currentOperation = CancelableOperation.fromFuture(
      _performAnalysis(document),
      onCancel: () {
        state = const AnalysisState(currentStep: ProcessingStep.idle);
      },
    );
    
    try {
      await _currentOperation?.value;
    } catch (e) {
      if (mounted) {
        state = AnalysisState(
          isProcessing: false,
          currentStep: ProcessingStep.error,
          errorMessage: e.toString(),
        );
      }
    }
  }
  
  Future<void> _performAnalysis(File document) async {
    _ref.read(processingStepProvider.notifier).state = ProcessingStep.extractingText;
    final ocrService = _ref.read(documentScanOcrServiceProvider);
    final ocrResult = await ocrService.extractTextFromImage(document);
    
    if (!mounted) return;
    
    state = state.copyWith(progress: 0.3, currentStep: ProcessingStep.analyzingDocument);
    
    final aiServiceAsync = _ref.read(aiServiceNotifierProvider);
    await aiServiceAsync.when(
      data: (aiService) async {
        _ref.read(processingStepProvider.notifier).state = ProcessingStep.generatingSummary;
        final summary = await aiService.provider.summarizeDocument(ocrResult.text);
        if (!mounted) return;
        state = state.copyWith(progress: 0.5);
        
        final translation = await aiService.provider.translateToPlainEnglish(ocrResult.text);
        if (!mounted) return;
        state = state.copyWith(progress: 0.7);
        
        _ref.read(processingStepProvider.notifier).state = ProcessingStep.detectingRedFlags;
        final redFlags = await aiService.provider.detectRedFlags(ocrResult.text);
        if (!mounted) return;
        state = state.copyWith(progress: 0.9);
        
        final result = AnalysisResult(
          documentId: DateTime.now().millisecondsSinceEpoch.toString(),
          originalText: ocrResult.text,
          plainEnglishTranslation: translation,
          summary: summary,
          redFlags: redFlags.map((rf) => RedFlagItem.fromRedFlag({
            'id': rf.id,
            'originalText': rf.originalText,
            'explanation': rf.explanation,
            'severity': rf.severity,
            'startPosition': rf.startPosition,
            'endPosition': rf.endPosition,
          })).toList(),
          metadata: DocumentMetadata(
            fileName: document.path.split('/').last,
            wordCount: ocrResult.text.split(' ').length,
            characterCount: ocrResult.text.length,
            confidence: ocrResult.confidence,
          ),
          status: AnalysisStatus.completed,
          analyzedAt: DateTime.now(),
        );
        
        state = state.copyWith(
          result: result,
          isProcessing: false,
          currentStep: ProcessingStep.completed,
          progress: 1.0,
        );
        
        _ref.read(analysisHistoryProvider.notifier).update((history) => [result, ...history]);
      },
      loading: () => throw Exception('AI service loading'),
      error: (e, _) => throw e,
    );
  }

  void cancelAnalysis() {
    _currentOperation?.cancel();
    state = const AnalysisState(currentStep: ProcessingStep.idle);
  }

  Future<void> analyzeFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await analyzeDocument(File(image.path));
    }
  }

  Future<void> analyzeFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      await analyzeDocument(File(images.first.path));
    }
  }

  void clearResult() {
    _currentOperation?.cancel();
    state = const AnalysisState();
  }

  void retry() {
    final lastFile = _ref.read(currentDocumentFileProvider);
    if (lastFile != null) {
      analyzeDocument(lastFile);
    }
  }

  @override
  void dispose() {
    _currentOperation?.cancel();
    super.dispose();
  }
}
