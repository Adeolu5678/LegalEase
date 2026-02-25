import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/reminders/data/models/reminder.dart';
import 'package:legalease/features/reminders/data/services/reminder_service.dart';

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService();
});

final remindersProvider = StateNotifierProvider.autoDispose<RemindersNotifier, AsyncValue<List<Reminder>>>((ref) {
  return RemindersNotifier(ref);
});

final upcomingRemindersProvider = Provider.autoDispose<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      final now = DateTime.now();
      final weekFromNow = now.add(const Duration(days: 7));
      return reminders
          .where((r) => 
              r.status == ReminderStatus.pending &&
              r.reminderDate.isAfter(now) &&
              r.reminderDate.isBefore(weekFromNow))
          .toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    },
    orElse: () => [],
  );
});

final overdueRemindersProvider = Provider.autoDispose<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      final now = DateTime.now();
      return reminders
          .where((r) => r.status == ReminderStatus.pending && r.reminderDate.isBefore(now))
          .toList()
        ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    },
    orElse: () => [],
  );
});

final completedRemindersProvider = Provider.autoDispose<List<Reminder>>((ref) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      return reminders
          .where((r) => r.status == ReminderStatus.completed)
          .toList()
        ..sort((a, b) => (b.completedAt ?? DateTime.now()).compareTo(a.completedAt ?? DateTime.now()));
    },
    orElse: () => [],
  );
});

final remindersByDocumentProvider = Provider.autoDispose.family<List<Reminder>, String>((ref, documentId) {
  final remindersAsync = ref.watch(remindersProvider);
  return remindersAsync.maybeWhen(
    data: (reminders) {
      return reminders.where((r) => r.documentId == documentId).toList();
    },
    orElse: () => [],
  );
});

class RemindersNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final Ref _ref;

  RemindersNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.initialize();
      final reminders = await service.getAllReminders();
      state = AsyncValue.data(reminders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Reminder?> createReminder({
    required String documentId,
    required String documentName,
    required String title,
    String? description,
    required DateTime reminderDate,
    ReminderType type = ReminderType.custom,
    ReminderPriority priority = ReminderPriority.medium,
    bool isRecurring = false,
    int? recurringDays,
    String? notes,
  }) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      final reminder = await service.createReminder(
        documentId: documentId,
        documentName: documentName,
        title: title,
        description: description,
        reminderDate: reminderDate,
        type: type,
        priority: priority,
        isRecurring: isRecurring,
        recurringDays: recurringDays,
        notes: notes,
      );
      
      state = AsyncValue.data([...state.value ?? [], reminder]);
      return reminder;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.updateReminder(reminder);
      
      final reminders = state.value ?? [];
      final index = reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        reminders[index] = reminder;
        state = AsyncValue.data([...reminders]);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.deleteReminder(reminderId);
      
      final reminders = state.value ?? [];
      reminders.removeWhere((r) => r.id == reminderId);
      state = AsyncValue.data([...reminders]);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsCompleted(String reminderId) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.markAsCompleted(reminderId);
      await _loadReminders();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAsDismissed(String reminderId) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.markAsDismissed(reminderId);
      await _loadReminders();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    try {
      final service = _ref.read(reminderServiceProvider);
      await service.snoozeReminder(reminderId, duration);
      await _loadReminders();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refresh() async {
    await _loadReminders();
  }
}
