import 'package:equatable/equatable.dart';

enum AnnotationType { comment, note, highlight, question }

enum AnnotationPriority { low, medium, high }

class Annotation extends Equatable {
  final String id;
  final String documentId;
  final String userId;
  final AnnotationType type;
  final String content;
  final int startIndex;
  final int endIndex;
  final String selectedText;
  final AnnotationPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isResolved;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const Annotation({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.type,
    required this.content,
    required this.startIndex,
    required this.endIndex,
    required this.selectedText,
    this.priority = AnnotationPriority.medium,
    required this.createdAt,
    this.updatedAt,
    this.isResolved = false,
    this.resolvedBy,
    this.resolvedAt,
  });

  bool get isComment => type == AnnotationType.comment;
  bool get isNote => type == AnnotationType.note;
  bool get isHighlight => type == AnnotationType.highlight;
  bool get isQuestion => type == AnnotationType.question;

  int get length => endIndex - startIndex;

  String get typeLabel {
    switch (type) {
      case AnnotationType.comment:
        return 'Comment';
      case AnnotationType.note:
        return 'Note';
      case AnnotationType.highlight:
        return 'Highlight';
      case AnnotationType.question:
        return 'Question';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case AnnotationPriority.low:
        return 'Low';
      case AnnotationPriority.medium:
        return 'Medium';
      case AnnotationPriority.high:
        return 'High';
    }
  }

  Annotation copyWith({
    String? id,
    String? documentId,
    String? userId,
    AnnotationType? type,
    String? content,
    int? startIndex,
    int? endIndex,
    String? selectedText,
    AnnotationPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isResolved,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      selectedText: selectedText ?? this.selectedText,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isResolved: isResolved ?? this.isResolved,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'userId': userId,
      'type': type.name,
      'content': content,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'selectedText': selectedText,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isResolved': isResolved,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory Annotation.fromJson(Map<String, dynamic> json) {
    return Annotation(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      userId: json['userId'] as String,
      type: AnnotationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AnnotationType.comment,
      ),
      content: json['content'] as String,
      startIndex: json['startIndex'] as int,
      endIndex: json['endIndex'] as int,
      selectedText: json['selectedText'] as String? ?? '',
      priority: AnnotationPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => AnnotationPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        userId,
        type,
        content,
        startIndex,
        endIndex,
        selectedText,
        priority,
        createdAt,
        updatedAt,
        isResolved,
        resolvedBy,
        resolvedAt,
      ];
}
