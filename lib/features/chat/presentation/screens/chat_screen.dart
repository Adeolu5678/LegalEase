import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:legalease/features/chat/domain/providers/chat_providers.dart';
import 'package:legalease/features/chat/presentation/widgets/chat_input.dart';
import 'package:legalease/features/chat/presentation/widgets/message_bubble.dart';
import 'package:legalease/features/chat/presentation/widgets/suggested_questions.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';
import 'package:legalease/shared/widgets/branded_loading_indicator.dart';
import 'package:legalease/core/theme/app_spacing.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? documentId;
  final String? documentTitle;

  const ChatScreen({
    super.key,
    this.documentId,
    this.documentTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final analysisResult = ref.read(currentAnalysisResultProvider);
    final documentId = widget.documentId ?? 
        analysisResult?.documentId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final documentContext = analysisResult?.originalText ?? '';

    ref.read(chatSessionProvider.notifier).initializeSession(
      documentId: documentId,
      documentContext: documentContext,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String message) async {
    if (_showSuggestions) {
      setState(() => _showSuggestions = false);
    }

    await ref.read(chatSessionProvider.notifier).sendMessage(message);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _handleClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(chatSessionProvider.notifier).clearSession();
              setState(() => _showSuggestions = true);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messages = ref.watch(chatSessionProvider.select((s) => s.messages));
    final isNotEmpty = ref.watch(chatSessionProvider.select((s) => s.isNotEmpty));
    final documentId = ref.watch(chatSessionProvider.select((s) => s.documentId));
    final isTyping = ref.watch(isAssistantTypingProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            Text(
              widget.documentTitle ?? 
                  (documentId.isNotEmpty ? 'Document Analysis' : 'Ask about your document'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _handleClearChat,
              tooltip: 'Clear chat',
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showExportDialog();
                  break;
                case 'help':
                  _showHelpDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Export Chat'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  leading: Icon(Icons.help_outline_rounded),
                  title: Text('Help'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSuggestions && messages.isEmpty)
            SuggestedQuestions(
              onQuestionSelected: _handleSendMessage,
            ),
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context)
                : _buildMessageList(messages, isTyping),
          ),
          ChatInput(
            onSendMessage: _handleSendMessage,
            isEnabled: !isTyping,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: colorScheme.onPrimaryContainer,
              ),
            ).animate().scale(duration: 400.ms),
            const SizedBox(height: 24),
            Text(
              'Ask me anything',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'I can help you understand your document, explain complex terms, '
              'and identify potential concerns.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<dynamic> messages, bool isTyping) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isTyping) {
          return _buildTypingIndicator(context);
        }
        return MessageBubble(message: messages[index])
            .animate()
            .fadeIn(duration: 200.ms)
            .slideX(begin: messages[index].isUser ? 0.1 : -0.1);
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppBorderRadius.md),
                topRight: Radius.circular(AppBorderRadius.md),
                bottomRight: Radius.circular(AppBorderRadius.md),
                bottomLeft: Radius.circular(AppBorderRadius.xs),
              ),
            ),
            child: const TypingIndicator(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  void _showExportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You can ask questions about:'),
            SizedBox(height: 12),
            _HelpItem(icon: Icons.gavel, text: 'Key legal terms'),
            _HelpItem(icon: Icons.warning_amber, text: 'Potential red flags'),
            _HelpItem(icon: Icons.attach_money, text: 'Fees and payments'),
            _HelpItem(icon: Icons.event, text: 'Dates and deadlines'),
            _HelpItem(icon: Icons.lock, text: 'Confidentiality clauses'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}
