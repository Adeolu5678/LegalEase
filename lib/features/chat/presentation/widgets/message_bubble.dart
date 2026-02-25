import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:legalease/features/chat/domain/models/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showAvatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (message.isLoading) {
      return _buildLoadingMessage(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser && showAvatar) ...[
            _buildAvatar(context, isUser: false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? colorScheme.primary
                        : message.isError
                            ? colorScheme.errorContainer
                            : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: message.isError
                        ? Border.all(color: colorScheme.error.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: message.isUser
                      ? Text(
                          message.content,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 15,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: message.isError
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            listBullet: TextStyle(
                              color: message.isError
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: message.isUser ? 0 : 4,
                    right: message.isUser ? 4 : 0,
                  ),
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser && showAvatar) ...[
            const SizedBox(width: 8),
            _buildAvatar(context, isUser: true),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildLoadingMessage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(context, isUser: false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn(duration: 300.ms, delay: (index * 200).ms)
                    .then(delay: 300.ms)
                    .fadeOut(duration: 300.ms);
              }),
            ),
          ).animate().fadeIn(duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, {required bool isUser}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? colorScheme.primaryContainer : colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
        size: 18,
        color: isUser
            ? colorScheme.onPrimaryContainer
            : colorScheme.onTertiaryContainer,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
