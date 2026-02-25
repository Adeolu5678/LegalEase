import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/core/theme/app_colors.dart';

final voiceInputEnabledProvider = StateProvider.autoDispose<bool>((ref) => true);

final isListeningProvider = StateProvider.autoDispose<bool>((ref) => false);

class ChatInput extends ConsumerStatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;
  final VoidCallback? onAttachmentPressed;
  final bool enableVoiceInput;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
    this.onAttachmentPressed,
    this.enableVoiceInput = true,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _speech = stt.SpeechToText();
  bool _hasText = false;
  bool _speechInitialized = false;
  String _lastRecognizedWords = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          ref.read(isListeningProvider.notifier).state = false;
        },
        onStatus: (status) {
          debugPrint('Speech recognition status: $status');
          if (status == 'done' || status == 'notListening') {
            ref.read(isListeningProvider.notifier).state = false;
          }
        },
      );
      setState(() {});
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _speech.stop();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;
    
    widget.onSendMessage(_textController.text.trim());
    _textController.clear();
    _focusNode.requestFocus();
  }

  Future<void> _toggleListening() async {
    if (!_speechInitialized) {
      await _initSpeech();
      if (!_speechInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
          ),
        );
        return;
      }
    }

    final isListening = ref.read(isListeningProvider);
    
    if (isListening) {
      await _speech.stop();
      ref.read(isListeningProvider.notifier).state = false;
    } else {
      ref.read(isListeningProvider.notifier).state = true;
      _lastRecognizedWords = '';
      
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          if (words.isNotEmpty && words != _lastRecognizedWords) {
            _lastRecognizedWords = words;
            setState(() {
              if (result.finalResult) {
                final currentText = _textController.text;
                _textController.text = currentText.isEmpty 
                    ? words 
                    : '$currentText $words';
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _textController.text.length),
                );
              } else {
                _textController.text = words;
              }
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isListening = ref.watch(isListeningProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (widget.onAttachmentPressed != null)
            IconButton(
              onPressed: widget.isEnabled ? widget.onAttachmentPressed : null,
              icon: Icon(
                Icons.attach_file_rounded,
                color: widget.isEnabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              tooltip: 'Attach file',
            ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: isListening
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.isEnabled && !isListening,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: isListening 
                            ? 'Listening...' 
                            : 'Ask a question about this document...',
                        hintStyle: TextStyle(
                          color: isListening 
                              ? AppColors.primary 
                              : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (isListening)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildListeningIndicator(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.enableVoiceInput && _speechInitialized) ...[
            _buildVoiceButton(colorScheme, isListening),
            const SizedBox(width: 4),
          ],
          _buildSendButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 500.ms).then().fadeOut(duration: 500.ms),
          const SizedBox(width: 6),
          Text(
            'REC',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(ColorScheme colorScheme, bool isListening) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: isListening ? AppColors.error : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: widget.isEnabled ? _toggleListening : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              isListening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 22,
              color: isListening 
                  ? Colors.white 
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    ).animate(target: isListening ? 1 : 0).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: 300.ms,
    );
  }

  Widget _buildSendButton(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: _hasText && widget.isEnabled
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: _hasText && widget.isEnabled ? _handleSend : null,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              Icons.send_rounded,
              size: 20,
              color: _hasText && widget.isEnabled
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
