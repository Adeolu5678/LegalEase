import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/writing_assistant/domain/models/writing_suggestion.dart';
import 'package:legalease/features/writing_assistant/domain/services/writing_assistant_service.dart';
import 'package:legalease/shared/providers/ai_providers.dart';

final writingAssistantServiceProvider = Provider<WritingAssistantService?>((ref) {
  final aiServiceAsync = ref.watch(aiServiceNotifierProvider);
  
  return aiServiceAsync.when(
    data: (aiService) => WritingAssistantService(aiService: aiService),
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentTextProvider = StateProvider.autoDispose<String>((ref) => '');

final suggestionsProvider = StateProvider.autoDispose<List<WritingSuggestion>>((ref) => []);

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

final errorMessageProvider = StateProvider.autoDispose<String?>((ref) => null);

final overlayPositionProvider = StateProvider.autoDispose<OverlayPosition>((ref) => 
  const OverlayPosition(x: 100, y: 100),
);

final overlaySizeProvider = StateProvider.autoDispose<OverlaySize>((ref) => 
  const OverlaySize(width: 400, height: 500),
);

final isOverlayExpandedProvider = StateProvider.autoDispose<bool>((ref) => true);

final isOverlayVisibleProvider = StateProvider.autoDispose<bool>((ref) => false);

final writingAssistantNotifierProvider = StateNotifierProvider.autoDispose<WritingAssistantNotifier, WritingAssistantState>((ref) {
  return WritingAssistantNotifier(ref);
});

class WritingAssistantNotifier extends StateNotifier<WritingAssistantState> {
  final Ref _ref;
  CancelableOperation<void>? _currentOperation;

  WritingAssistantNotifier(this._ref) : super(const WritingAssistantState.initial());

  Future<void> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      state = const WritingAssistantState.initial();
      return;
    }

    _currentOperation?.cancel();

    state = const WritingAssistantState.loading();
    _ref.read(currentTextProvider.notifier).state = text;
    _ref.read(isLoadingProvider.notifier).state = true;
    _ref.read(errorMessageProvider.notifier).state = null;

    _currentOperation = CancelableOperation.fromFuture(
      _performAnalysis(text),
      onCancel: () {
        if (mounted) {
          state = const WritingAssistantState.initial();
          _ref.read(isLoadingProvider.notifier).state = false;
          _ref.read(errorMessageProvider.notifier).state = null;
        }
      },
    );

    try {
      await _currentOperation?.value;
    } catch (e) {
      if (mounted) {
        state = WritingAssistantState.error(message: e.toString());
        _ref.read(isLoadingProvider.notifier).state = false;
        _ref.read(errorMessageProvider.notifier).state = e.toString();
      }
    }
  }

  Future<void> _performAnalysis(String text) async {
    final service = _ref.read(writingAssistantServiceProvider);
    if (service == null) {
      if (mounted) {
        state = const WritingAssistantState.loaded(suggestions: []);
      }
      return;
    }
    
    final suggestions = await service.analyzeText(text);
    
    if (!mounted) return;
    
    _ref.read(suggestionsProvider.notifier).state = suggestions;
    state = WritingAssistantState.loaded(suggestions: suggestions);
    _ref.read(isLoadingProvider.notifier).state = false;
    _ref.read(errorMessageProvider.notifier).state = null;
  }

  void cancelAnalysis() {
    _currentOperation?.cancel();
  }

  String? applySuggestion(WritingSuggestion suggestion) {
    final currentText = _ref.read(currentTextProvider);
    final service = _ref.read(writingAssistantServiceProvider);
    if (service == null) return null;
    
    final newText = service.applySuggestion(currentText, suggestion);
    
    final currentSuggestions = _ref.read(suggestionsProvider);
    final updatedSuggestions = currentSuggestions.where((s) => s.id != suggestion.id).toList();
    _ref.read(suggestionsProvider.notifier).state = updatedSuggestions;
    _ref.read(currentTextProvider.notifier).state = newText;
    
    state = WritingAssistantState.loaded(suggestions: updatedSuggestions);
    
    return newText;
  }

  void dismissSuggestion(String suggestionId) {
    final currentSuggestions = _ref.read(suggestionsProvider);
    final updatedSuggestions = currentSuggestions.where((s) => s.id != suggestionId).toList();
    _ref.read(suggestionsProvider.notifier).state = updatedSuggestions;
    state = WritingAssistantState.loaded(suggestions: updatedSuggestions);
  }

  void dismissAllSuggestions() {
    _ref.read(suggestionsProvider.notifier).state = [];
    state = const WritingAssistantState.loaded(suggestions: []);
  }

  void clearAnalysis() {
    _currentOperation?.cancel();
    _ref.read(currentTextProvider.notifier).state = '';
    _ref.read(suggestionsProvider.notifier).state = [];
    _ref.read(errorMessageProvider.notifier).state = null;
    state = const WritingAssistantState.initial();
  }

  @override
  void dispose() {
    _currentOperation?.cancel();
    super.dispose();
  }
}

sealed class WritingAssistantState {
  const WritingAssistantState();

  const factory WritingAssistantState.initial() = WritingAssistantInitial;
  const factory WritingAssistantState.loading() = WritingAssistantLoading;
  const factory WritingAssistantState.loaded({required List<WritingSuggestion> suggestions}) = WritingAssistantLoaded;
  const factory WritingAssistantState.error({required String message}) = WritingAssistantError;
}

class WritingAssistantInitial extends WritingAssistantState {
  const WritingAssistantInitial();
}

class WritingAssistantLoading extends WritingAssistantState {
  const WritingAssistantLoading();
}

class WritingAssistantLoaded extends WritingAssistantState {
  final List<WritingSuggestion> suggestions;
  const WritingAssistantLoaded({required this.suggestions});
}

class WritingAssistantError extends WritingAssistantState {
  final String message;
  const WritingAssistantError({required this.message});
}

class OverlayPosition {
  final double x;
  final double y;
  const OverlayPosition({required this.x, required this.y});
}

class OverlaySize {
  final double width;
  final double height;
  const OverlaySize({required this.width, required this.height});
}
