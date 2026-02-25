import 'package:async/async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/chat/domain/models/chat_message.dart';
import 'package:legalease/shared/providers/ai_providers.dart';

final chatSessionProvider = StateNotifierProvider.autoDispose<ChatSessionNotifier, ChatSession>((ref) {
  return ChatSessionNotifier(ref);
});

final chatHistoryProvider = StateProvider.autoDispose<List<ChatSession>>((ref) => []);

final isAssistantTypingProvider = StateProvider.autoDispose<bool>((ref) => false);

class ChatSessionNotifier extends StateNotifier<ChatSession> {
  final Ref _ref;
  CancelableOperation<void>? _currentOperation;

  ChatSessionNotifier(this._ref) : super(ChatSession(
    id: '',
    documentId: '',
    documentContext: '',
    createdAt: DateTime.now(),
  ));

  void initializeSession({
    required String documentId,
    required String documentContext,
  }) {
    state = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: documentId,
      documentContext: documentContext,
      createdAt: DateTime.now(),
    );
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    _currentOperation?.cancel();

    final userMsg = ChatMessage.user(userMessage.trim());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      lastMessageAt: DateTime.now(),
    );

    final loadingMsg = ChatMessage.loading();
    state = state.copyWith(messages: [...state.messages, loadingMsg]);
    _ref.read(isAssistantTypingProvider.notifier).state = true;

    _currentOperation = CancelableOperation.fromFuture(
      _getAiResponse(userMessage.trim()),
      onCancel: () {
        if (mounted) {
          final updatedMessages = state.messages.where((m) => !m.isLoading).toList();
          state = state.copyWith(messages: updatedMessages);
          _ref.read(isAssistantTypingProvider.notifier).state = false;
        }
      },
    );

    try {
      await _currentOperation?.value;
    } catch (e) {
      if (mounted) {
        final errorMsg = ChatMessage.assistant(
          'Sorry, I encountered an error. Please try again.',
        ).copyWith(isError: true);
        final updatedMessages = state.messages.where((m) => !m.isLoading).toList();
        state = state.copyWith(messages: [...updatedMessages, errorMsg]);
      }
    } finally {
      if (mounted) {
        _ref.read(isAssistantTypingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _getAiResponse(String userMessage) async {
    final aiServiceAsync = _ref.read(aiServiceNotifierProvider);
    await aiServiceAsync.when(
      data: (aiService) async {
        final history = state.messages
            .where((m) => !m.isLoading)
            .map((m) => {
                  'role': m.role.name,
                  'content': m.content,
                })
            .toList();

        final response = await aiService.provider.chatWithContext(
          documentText: state.documentContext,
          userQuery: userMessage,
          conversationHistory: history.cast<Map<String, String>>(),
        );

        if (!mounted) return;

        final assistantMsg = ChatMessage.assistant(response);
        final updatedMessages = state.messages.where((m) => !m.isLoading).toList();
        
        state = state.copyWith(
          messages: [...updatedMessages, assistantMsg],
          lastMessageAt: DateTime.now(),
        );
      },
      loading: () => throw Exception('AI service loading'),
      error: (e, _) => throw e,
    );
  }

  void cancelCurrentOperation() {
    _currentOperation?.cancel();
  }

  void clearSession() {
    _currentOperation?.cancel();
    state = ChatSession(
      id: '',
      documentId: '',
      documentContext: '',
      createdAt: DateTime.now(),
    );
  }

  void saveToHistory() {
    if (state.isNotEmpty) {
      _ref.read(chatHistoryProvider.notifier).update((history) => [state, ...history]);
    }
  }

  @override
  void dispose() {
    _currentOperation?.cancel();
    super.dispose();
  }
}
