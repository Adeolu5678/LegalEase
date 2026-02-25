import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/core/platform_channels/accessibility_channel.dart';
import 'package:legalease/features/tc_scanner/data/services/tc_detector_service.dart';
import 'package:legalease/shared/providers/ai_providers.dart';

final tcDetectorServiceProvider = Provider<TcDetectorService>((ref) {
  final accessibilityService = NativeAccessibilityService();
  return TcDetectorService(accessibilityService);
});

final isMonitoringProvider = StateProvider<bool>((ref) => false);

final tcDetectedProvider = StateProvider<TcDetectionResult?>((ref) => null);

final hasAccessibilityPermissionProvider = FutureProvider<bool>((ref) async {
  final detector = ref.watch(tcDetectorServiceProvider);
  return await detector.hasAccessibilityPermission();
});

final hasOverlayPermissionProvider = FutureProvider<bool>((ref) async {
  final detector = ref.watch(tcDetectorServiceProvider);
  return await detector.hasOverlayPermission();
});

final tcScannerNotifierProvider = StateNotifierProvider<TcScannerNotifier, TcScannerState>((ref) {
  return TcScannerNotifier(ref);
});

class TcScannerState {
  final bool isScanning;
  final TcDetectionResult? detectedContent;
  final bool isAnalyzing;
  final String? analysisResult;
  final List<String> redFlags;
  final String? errorMessage;

  const TcScannerState({
    this.isScanning = false,
    this.detectedContent,
    this.isAnalyzing = false,
    this.analysisResult,
    this.redFlags = const [],
    this.errorMessage,
  });

  TcScannerState copyWith({
    bool? isScanning,
    TcDetectionResult? detectedContent,
    bool? isAnalyzing,
    String? analysisResult,
    List<String>? redFlags,
    String? errorMessage,
    bool clearDetectedContent = false,
    bool clearError = false,
  }) {
    return TcScannerState(
      isScanning: isScanning ?? this.isScanning,
      detectedContent: clearDetectedContent ? null : (detectedContent ?? this.detectedContent),
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      analysisResult: clearDetectedContent ? null : (analysisResult ?? this.analysisResult),
      redFlags: clearDetectedContent ? const [] : (redFlags ?? this.redFlags),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class TcScannerNotifier extends StateNotifier<TcScannerState> {
  final Ref _ref;

  TcScannerNotifier(this._ref) : super(const TcScannerState());

  Future<void> startScanning() async {
    state = state.copyWith(isScanning: true, clearError: true);
    
    final detector = _ref.read(tcDetectorServiceProvider);
    await detector.startMonitoring();
    
    detector.onTcDetected.listen((detection) {
      state = state.copyWith(detectedContent: detection);
      _handleTcDetected(detection);
    });
    
    _ref.read(isMonitoringProvider.notifier).state = true;
  }

  Future<void> stopScanning() async {
    state = state.copyWith(isScanning: false);
    final detector = _ref.read(tcDetectorServiceProvider);
    await detector.stopMonitoring();
    _ref.read(isMonitoringProvider.notifier).state = false;
  }

  void _handleTcDetected(TcDetectionResult detection) {
    _ref.read(tcDetectedProvider.notifier).state = detection;
  }

  Future<void> analyzeDetectedContent() async {
    final content = state.detectedContent?.content;
    if (content == null) return;

    state = state.copyWith(isAnalyzing: true, clearError: true);

    try {
      final aiServiceAsync = _ref.read(aiServiceNotifierProvider);
      await aiServiceAsync.when(
        data: (aiService) async {
          final summary = await aiService.provider.summarizeDocument(content);
          final redFlags = await aiService.provider.detectRedFlags(content);
          
          state = state.copyWith(
            isAnalyzing: false,
            analysisResult: summary,
            redFlags: redFlags.map((rf) => rf.originalText).toList(),
          );
        },
        loading: () {
          state = state.copyWith(
            isAnalyzing: false,
            errorMessage: 'AI service loading',
          );
        },
        error: (e, _) {
          state = state.copyWith(
            isAnalyzing: false,
            errorMessage: e.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> showOverlay() async {
    final detector = _ref.read(tcDetectorServiceProvider);
    await detector.showOverlay();
  }

  Future<void> hideOverlay() async {
    final detector = _ref.read(tcDetectorServiceProvider);
    await detector.hideOverlay();
  }

  void clearDetectedContent() {
    state = state.copyWith(
      clearDetectedContent: true,
    );
    _ref.read(tcDetectedProvider.notifier).state = null;
  }
  
  void dismissError() {
    state = state.copyWith(clearError: true);
  }
}
