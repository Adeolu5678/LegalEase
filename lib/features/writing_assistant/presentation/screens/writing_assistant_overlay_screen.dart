import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/writing_assistant/domain/models/writing_suggestion.dart';
import 'package:legalease/features/writing_assistant/domain/providers/writing_assistant_providers.dart';
import 'package:legalease/core/platform_channels/desktop_overlay_channel.dart';

class WritingAssistantOverlayScreen extends ConsumerStatefulWidget {
  const WritingAssistantOverlayScreen({super.key});

  @override
  ConsumerState<WritingAssistantOverlayScreen> createState() => _WritingAssistantOverlayScreenState();
}

class _WritingAssistantOverlayScreenState extends ConsumerState<WritingAssistantOverlayScreen> {
  final DesktopOverlayChannel _overlayChannel = DesktopOverlayChannel();
  final TextEditingController _textController = TextEditingController();
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _setupEventListeners();
  }

  void _setupEventListeners() {
    _overlayChannel.selectionEventStream.listen((event) {
      final text = event['text'] as String?;
      if (text != null && text.isNotEmpty) {
        _textController.text = text;
        ref.read(writingAssistantNotifierProvider.notifier).analyzeText(text);
      }
    });

    _overlayChannel.clipboardEventStream.listen((event) {
      final text = event['text'] as String?;
      if (text != null && text.isNotEmpty) {
        _textController.text = text;
        ref.read(writingAssistantNotifierProvider.notifier).analyzeText(text);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(isOverlayExpandedProvider);
    final suggestions = ref.watch(suggestionsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final position = ref.watch(overlayPositionProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onPanStart: (details) {
          _isDragging = true;
          _dragOffset = Offset(position.x, position.y) - details.globalPosition;
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            final newPosition = details.globalPosition + _dragOffset;
            ref.read(overlayPositionProvider.notifier).state = 
                OverlayPosition(x: newPosition.dx, y: newPosition.dy);
            _overlayChannel.setPosition(newPosition.dx, newPosition.dy);
          }
        },
        onPanEnd: (_) {
          _isDragging = false;
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isExpanded),
              if (isExpanded) ...[
                _buildTextInput(context),
                const Divider(height: 1),
                Expanded(
                  child: _buildContent(context, suggestions, isLoading, errorMessage),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(12),
          bottom: isExpanded ? Radius.zero : const Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_note,
            size: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Legal Writing Assistant',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isExpanded ? Icons.remove : Icons.add,
              size: 18,
            ),
            onPressed: () {
              ref.read(isOverlayExpandedProvider.notifier).state = !isExpanded;
              if (isExpanded) {
                _overlayChannel.minimize();
              } else {
                _overlayChannel.expand();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              _overlayChannel.hideOverlay();
              ref.read(isOverlayVisibleProvider.notifier).state = false;
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _textController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Paste or type text to analyze...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.all(12),
          suffixIcon: IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: () {
              ref.read(writingAssistantNotifierProvider.notifier).analyzeText(_textController.text);
            },
          ),
        ),
        onChanged: (text) {
          ref.read(currentTextProvider.notifier).state = text;
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<WritingSuggestion> suggestions,
    bool isLoading,
    String? errorMessage,
  ) {
    if (errorMessage != null) {
      return _buildErrorState(context, errorMessage);
    }
    if (isLoading) {
      return _buildLoadingState(context);
    }
    if (suggestions.isEmpty) {
      return _buildEmptyState(context);
    }
    return _buildSuggestionsList(context, suggestions);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Enter text to get suggestions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Analyzing text...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context, List<WritingSuggestion> suggestions) {
    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No suggestions found',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your text looks good!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _SuggestionCard(
          suggestion: suggestion,
          onAccept: () {
            ref.read(writingAssistantNotifierProvider.notifier).applySuggestion(suggestion);
          },
          onDismiss: () {
            ref.read(writingAssistantNotifierProvider.notifier).dismissSuggestion(suggestion.id);
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error analyzing text',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final WritingSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const _SuggestionCard({
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
  });

  Color _getTypeColor(BuildContext context) {
    return switch (suggestion.type) {
      SuggestionType.clarity => Colors.blue,
      SuggestionType.legalAccuracy => Colors.purple,
      SuggestionType.toneAdjustment => Colors.orange,
      SuggestionType.riskReduction => Colors.red,
    };
  }

  IconData _getTypeIcon() {
    return switch (suggestion.type) {
      SuggestionType.clarity => Icons.lightbulb_outline,
      SuggestionType.legalAccuracy => Icons.gavel,
      SuggestionType.toneAdjustment => Icons.tune,
      SuggestionType.riskReduction => Icons.shield_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(), size: 14, color: typeColor),
                      const SizedBox(width: 4),
                      Text(
                        suggestion.typeDisplayName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (suggestion.isHighConfidence)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'High',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'Original: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: suggestion.originalText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'Suggested: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: suggestion.suggestedText,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (suggestion.explanation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                suggestion.explanation,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Dismiss'),
                  onPressed: onDismiss,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Accept'),
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}