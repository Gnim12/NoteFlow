import 'package:uuid/uuid.dart';

import '../models/note_model.dart';
import '../models/reminder_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../services/sqlite_service.dart';

class ReminderController {
  ReminderController._();

  static final ReminderController instance = ReminderController._();

  final SqliteService _service = SqliteService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  static const _uuid = Uuid();

  /// `flutter_local_notifications` attend un id 32 bits sur Android.
  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
  }

  Future<List<Reminder>> getReminders(String noteId) {
    return _service.getReminders(noteId);
  }

  Future<List<Reminder>> getAllReminders(String userId) {
    return _service.getAllReminders(userId);
  }

  Future<Reminder> createReminder({
    required Note note,
    required DateTime dateTime,
    required RecurrenceType recurrence,
    int? customIntervalDays,
  }) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      noteId: note.id!,
      userId: note.userId,
      dateTime: dateTime,
      recurrence: recurrence,
      customIntervalDays: customIntervalDays,
      notificationId: _generateNotificationId(),
      createdAt: DateTime.now(),
    );

    await _service.insertReminder(reminder);
    await _scheduleAndMirror(reminder, note);

    return reminder;
  }

  Future<void> updateReminder({
    required Reminder reminder,
    required Note note,
  }) async {
    await _service.updateReminder(reminder);
    await _notificationService.cancel(reminder.notificationId);

    if (reminder.enabled) {
      await _scheduleAndMirror(reminder, note);
    } else {
      _mirrorToCloud(() => _firestoreService.setReminder(reminder));
    }
  }

  Future<void> deleteReminder(Reminder reminder) async {
    await _notificationService.cancel(reminder.notificationId);
    await _service.deleteReminder(reminder.id!);

    _mirrorToCloud(
      () => _firestoreService.deleteReminder(
        userId: reminder.userId,
        noteId: reminder.noteId,
        reminderId: reminder.id!,
      ),
    );
  }

  Future<void> _scheduleAndMirror(Reminder reminder, Note note) async {
    await _notificationService.scheduleReminder(
      reminder: reminder,
      title: note.title,
      body: note.description.isEmpty
          ? "Rappel NoteFlow"
          : note.description,
    );

    _mirrorToCloud(() => _firestoreService.setReminder(reminder));
  }

  void _mirrorToCloud(Future<void> Function() action) {
    action().catchError((_) {});
  }

  /// Reprogramme tous les rappels actifs de l'utilisateur. Nécessaire au
  /// démarrage de l'application car Android annule les alarmes programmées
  /// après un redémarrage de l'appareil. Fait aussi avancer les rappels
  /// "personnalisés" dont l'échéance est déjà passée.
  Future<void> rescheduleAll(String userId) async {
    final reminders = await _service.getAllReminders(userId);

    for (final reminder in reminders.where((r) => r.enabled)) {
      var current = reminder;

      if (current.recurrence == RecurrenceType.custom &&
          current.customIntervalDays != null &&
          current.customIntervalDays! > 0) {
        final now = DateTime.now();
        var next = current.dateTime;

        while (next.isBefore(now)) {
          next = next.add(Duration(days: current.customIntervalDays!));
        }

        if (next != current.dateTime) {
          current = current.copyWith(dateTime: next);
          await _service.updateReminder(current);
        }
      }

      final note = await _service.getNoteById(current.noteId, current.userId);
      if (note == null) continue;

      await _notificationService.scheduleReminder(
        reminder: current,
        title: note.title,
        body: note.description.isEmpty ? "Rappel NoteFlow" : note.description,
      );
    }
  }
}
