import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';

enum AnalysisStep {
  idle,
  extractingText,
  analyzing,
  detectingRedFlags,
  generatingSummary,
  completed,
  error,
}

class AnalysisState {
  final AnalysisStep currentStep;
  final double progress;
  final String? errorMessage;
  final AnalysisResult? result;
  final List<AnalysisResult> recentAnalyses;

  const AnalysisState({
    this.currentStep = AnalysisStep.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.result,
    this.recentAnalyses = const [],
  });

  bool get isProcessing => currentStep != AnalysisStep.idle &&
      currentStep != AnalysisStep.completed &&
      currentStep != AnalysisStep.error;
  bool get isCompleted => currentStep == AnalysisStep.completed;
  bool get hasError => currentStep == AnalysisStep.error;
  bool get hasRecentAnalyses => recentAnalyses.isNotEmpty;

  AnalysisState copyWith({
    AnalysisStep? currentStep,
    double? progress,
    String? errorMessage,
    AnalysisResult? result,
    List<AnalysisResult>? recentAnalyses,
  }) {
    return AnalysisState(
      currentStep: currentStep ?? this.currentStep,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
      recentAnalyses: recentAnalyses ?? this.recentAnalyses,
    );
  }
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  AnalysisNotifier() : super(const AnalysisState());

  void startAnalysis() {
    state = const AnalysisState(
      currentStep: AnalysisStep.extractingText,
      progress: 0.0,
    );
  }

  void updateStep(AnalysisStep step, {double? progress}) {
    state = state.copyWith(
      currentStep: step,
      progress: progress ?? state.progress,
    );
  }

  void updateProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void completeAnalysis(AnalysisResult result) {
    state = state.copyWith(
      currentStep: AnalysisStep.completed,
      progress: 1.0,
      result: result,
      recentAnalyses: [result, ...state.recentAnalyses.take(9)],
    );
  }

  void setError(String error) {
    state = state.copyWith(
      currentStep: AnalysisStep.error,
      errorMessage: error,
    );
  }

  void reset() {
    state = const AnalysisState();
  }

  void cancelAnalysis() {
    state = state.copyWith(
      currentStep: AnalysisStep.idle,
      progress: 0.0,
    );
  }
}

final analysisNotifierProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(),
);

final recentAnalysesProvider = Provider<List<AnalysisResult>>((ref) {
  return ref.watch(analysisNotifierProvider).recentAnalyses;
});

final currentAnalysisResultProvider = Provider<AnalysisResult?>((ref) {
  return ref.watch(analysisNotifierProvider).result;
});
