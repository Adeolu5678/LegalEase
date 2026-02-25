import 'package:equatable/equatable.dart';

enum ReminderType {
  contractRenewal,
  deadline,
  expiration,
  paymentDue,
  terminationNotice,
  custom,
}

enum ReminderStatus {
  pending,
  completed,
  dismissed,
  snoozed,
}

enum ReminderPriority {
  low,
  medium,
  high,
  urgent,
}

class Reminder extends Equatable {
  final String id;
  final String documentId;
  final String documentName;
  final String title;
  final String? description;
  final DateTime reminderDate;
  final ReminderType type;
  final ReminderStatus status;
  final ReminderPriority priority;
  final bool isRecurring;
  final int? recurringDays;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dismissedAt;
  final String? notes;

  const Reminder({
    required this.id,
    required this.documentId,
    required this.documentName,
    required this.title,
    this.description,
    required this.reminderDate,
    required this.type,
    this.status = ReminderStatus.pending,
    this.priority = ReminderPriority.medium,
    this.isRecurring = false,
    this.recurringDays,
    required this.createdAt,
    this.completedAt,
    this.dismissedAt,
    this.notes,
  });

  bool get isOverdue => reminderDate.isBefore(DateTime.now()) && status == ReminderStatus.pending;
  
  bool get isDueToday {
    final now = DateTime.now();
    return reminderDate.year == now.year &&
        reminderDate.month == now.month &&
        reminderDate.day == now.day;
  }
  
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return reminderDate.year == tomorrow.year &&
        reminderDate.month == tomorrow.month &&
        reminderDate.day == tomorrow.day;
  }
  
  bool get isDueWithinWeek {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    return reminderDate.isAfter(now) && reminderDate.isBefore(weekFromNow);
  }

  String get typeLabel {
    return switch (type) {
      ReminderType.contractRenewal => 'Contract Renewal',
      ReminderType.deadline => 'Deadline',
      ReminderType.expiration => 'Expiration',
      ReminderType.paymentDue => 'Payment Due',
      ReminderType.terminationNotice => 'Termination Notice',
      ReminderType.custom => 'Custom',
    };
  }

  String get priorityLabel {
    return switch (priority) {
      ReminderPriority.low => 'Low',
      ReminderPriority.medium => 'Medium',
      ReminderPriority.high => 'High',
      ReminderPriority.urgent => 'Urgent',
    };
  }

  Reminder copyWith({
    String? id,
    String? documentId,
    String? documentName,
    String? title,
    String? description,
    DateTime? reminderDate,
    ReminderType? type,
    ReminderStatus? status,
    ReminderPriority? priority,
    bool? isRecurring,
    int? recurringDays,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dismissedAt,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      documentName: documentName ?? this.documentName,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDate: reminderDate ?? this.reminderDate,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'documentName': documentName,
      'title': title,
      'description': description,
      'reminderDate': reminderDate.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'isRecurring': isRecurring,
      'recurringDays': recurringDays,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dismissedAt': dismissedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      documentName: json['documentName'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      reminderDate: DateTime.parse(json['reminderDate'] as String),
      type: ReminderType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ReminderType.custom,
      ),
      status: ReminderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ReminderStatus.pending,
      ),
      priority: ReminderPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringDays: json['recurringDays'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      dismissedAt: json['dismissedAt'] != null
          ? DateTime.parse(json['dismissedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        documentId,
        documentName,
        title,
        description,
        reminderDate,
        type,
        status,
        priority,
        isRecurring,
        recurringDays,
        createdAt,
        completedAt,
        dismissedAt,
        notes,
      ];
}
