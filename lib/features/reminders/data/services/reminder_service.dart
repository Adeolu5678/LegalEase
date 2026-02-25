import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:legalease/features/reminders/data/models/reminder.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin _notifications;
  static const String _remindersKey = 'reminders';
  bool _initialized = false;

  ReminderService() : _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) return;
    
    tz_data.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _initialized = true;
  }

  void Function(NotificationResponse)? _onNotificationTapped;

  void setNotificationHandler(void Function(NotificationResponse) handler) {
    _onNotificationTapped = handler;
  }

  Future<List<Reminder>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList(_remindersKey) ?? [];
    return remindersJson
        .map((json) => Reminder.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = reminders.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_remindersKey, remindersJson);
  }

  Future<Reminder> createReminder({
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
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      documentId: documentId,
      documentName: documentName,
      title: title,
      description: description,
      reminderDate: reminderDate,
      type: type,
      priority: priority,
      isRecurring: isRecurring,
      recurringDays: recurringDays,
      createdAt: DateTime.now(),
      notes: notes,
    );

    final reminders = await getAllReminders();
    reminders.add(reminder);
    await saveReminders(reminders);

    await _scheduleNotification(reminder);

    return reminder;
  }

  Future<void> updateReminder(Reminder reminder) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await saveReminders(reminders);

      await _cancelNotification(reminder.id);
      if (reminder.status == ReminderStatus.pending) {
        await _scheduleNotification(reminder);
      }
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    final reminders = await getAllReminders();
    reminders.removeWhere((r) => r.id == reminderId);
    await saveReminders(reminders);
    await _cancelNotification(reminderId);
  }

  Future<void> markAsCompleted(String reminderId) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = reminders[index].copyWith(
        status: ReminderStatus.completed,
        completedAt: DateTime.now(),
      );
      reminders[index] = reminder;
      await saveReminders(reminders);
      await _cancelNotification(reminderId);

      if (reminder.isRecurring && reminder.recurringDays != null) {
        final nextDate = reminder.reminderDate.add(Duration(days: reminder.recurringDays!));
        await createReminder(
          documentId: reminder.documentId,
          documentName: reminder.documentName,
          title: reminder.title,
          description: reminder.description,
          reminderDate: nextDate,
          type: reminder.type,
          priority: reminder.priority,
          isRecurring: true,
          recurringDays: reminder.recurringDays,
          notes: reminder.notes,
        );
      }
    }
  }

  Future<void> markAsDismissed(String reminderId) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      reminders[index] = reminders[index].copyWith(
        status: ReminderStatus.dismissed,
        dismissedAt: DateTime.now(),
      );
      await saveReminders(reminders);
      await _cancelNotification(reminderId);
    }
  }

  Future<void> snoozeReminder(String reminderId, Duration duration) async {
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      final reminder = reminders[index].copyWith(
        reminderDate: DateTime.now().add(duration),
        status: ReminderStatus.snoozed,
      );
      reminders[index] = reminder;
      await saveReminders(reminders);
      await _cancelNotification(reminderId);
      await _scheduleNotification(reminder);
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Contract and deadline reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Reminder for: ${reminder.documentName}',
      tz.TZDateTime.from(reminder.reminderDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id,
    );
  }

  Future<void> _cancelNotification(String reminderId) async {
    await _notifications.cancel(reminderId.hashCode);
  }

  Future<List<Reminder>> getUpcomingReminders({int days = 7}) async {
    final reminders = await getAllReminders();
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return reminders
        .where((r) => 
            r.status == ReminderStatus.pending &&
            r.reminderDate.isAfter(now) &&
            r.reminderDate.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
  }

  Future<List<Reminder>> getOverdueReminders() async {
    final reminders = await getAllReminders();
    final now = DateTime.now();
    
    return reminders
        .where((r) => r.status == ReminderStatus.pending && r.reminderDate.isBefore(now))
        .toList()
      ..sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
  }

  Future<void> checkAndNotifyReminders() async {
    final upcoming = await getUpcomingReminders(days: 1);
    for (final reminder in upcoming) {
      if (reminder.isDueToday) {
        await _showImmediateNotification(reminder);
      }
    }
  }

  Future<void> _showImmediateNotification(Reminder reminder) async {
    final androidDetails = AndroidNotificationDetails(
      'reminders_immediate',
      'Immediate Reminders',
      channelDescription: 'Immediate reminder notifications',
      importance: Importance.max,
      priority: Priority.max,
    );
    const iOSDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _notifications.show(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Reminder for: ${reminder.documentName}',
      details,
      payload: reminder.id,
    );
  }
}
