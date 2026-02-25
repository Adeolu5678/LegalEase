import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;
  final bool isLoading;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isError = false,
    this.isLoading = false,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isError,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere((r) => r.name == json['role']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isError: json['isError'] as bool? ?? false,
    );
  }

  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading',
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, isError, isLoading];
}

class ChatSession extends Equatable {
  final String id;
  final String documentId;
  final String documentContext;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastMessageAt;

  const ChatSession({
    required this.id,
    required this.documentId,
    required this.documentContext,
    this.messages = const [],
    required this.createdAt,
    this.lastMessageAt,
  });

  int get messageCount => messages.length;
  bool get isEmpty => messages.isEmpty;
  bool get isNotEmpty => messages.isNotEmpty;

  ChatSession copyWith({
    String? id,
    String? documentId,
    String? documentContext,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastMessageAt,
  }) {
    return ChatSession(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentContext: documentContext ?? this.documentContext,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }

  @override
  List<Object?> get props => [id, documentId, documentContext, messages, createdAt, lastMessageAt];
}
