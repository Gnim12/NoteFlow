import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder_model.dart';

/// Couche technique pure autour de `flutter_local_notifications`.
///
/// Limite connue : sur Android, les notifications programmées via
/// `AlarmManager` sont annulées par le système au redémarrage de l'appareil.
/// Comme ce projet n'embarque pas de récepteur natif dédié, les rappels sont
/// reprogrammés automatiquement à la prochaine ouverture de l'application
/// (cf. [ReminderController.rescheduleAll]), mais pas immédiatement après un
/// redémarrage tant que l'app n'a pas été relancée.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'note_reminders';
  static const _channelName = 'Rappels de notes';

  /// Appelé lorsqu'une notification est sélectionnée pendant que le
  /// processus de l'application est déjà lancé. Le payload contient
  /// l'identifiant de la note concernée.
  void Function(String noteId)? onNotificationTap;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      // On reste sur la timezone par défaut (UTC) si elle n'a pu être
      // déterminée : les rappels resteront fonctionnels mais leur heure
      // pourrait être décalée.
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final noteId = response.payload;
        if (noteId != null) {
          onNotificationTap?.call(noteId);
        }
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<NotificationAppLaunchDetails?> getLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  Future<void> scheduleReminder({
    required Reminder reminder,
    required String title,
    required String body,
  }) async {
    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    await _plugin.zonedSchedule(
      id: reminder.notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Notifications de rappel programmées pour vos notes',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: _matchComponentsFor(reminder.recurrence),
      payload: reminder.noteId,
    );
  }

  DateTimeComponents? _matchComponentsFor(RecurrenceType recurrence) {
    switch (recurrence) {
      case RecurrenceType.daily:
        return DateTimeComponents.time;
      case RecurrenceType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RecurrenceType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RecurrenceType.none:
      case RecurrenceType.custom:
        return null;
    }
  }

  Future<void> cancel(int notificationId) {
    return _plugin.cancel(id: notificationId);
  }
}
