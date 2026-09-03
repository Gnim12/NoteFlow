enum RecurrenceType { none, daily, weekly, monthly, custom }

class Reminder {
  final String? id;
  final String noteId;
  final String userId;
  final DateTime dateTime;
  final RecurrenceType recurrence;

  /// Nombre de jours entre deux occurrences, utilisé seulement quand
  /// [recurrence] vaut [RecurrenceType.custom].
  final int? customIntervalDays;

  final bool enabled;

  /// Identifiant numérique donné à `flutter_local_notifications` pour cette
  /// notification (nécessaire pour pouvoir l'annuler/la remplacer).
  final int notificationId;

  final DateTime createdAt;

  const Reminder({
    this.id,
    required this.noteId,
    required this.userId,
    required this.dateTime,
    this.recurrence = RecurrenceType.none,
    this.customIntervalDays,
    this.enabled = true,
    required this.notificationId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'date_time': dateTime.toIso8601String(),
      'recurrence': recurrence.name,
      'custom_interval_days': customIntervalDays,
      'enabled': enabled ? 1 : 0,
      'notification_id': notificationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String?,
      noteId: map['note_id'] as String,
      userId: map['user_id'] as String,
      dateTime: DateTime.parse(map['date_time']),
      recurrence: RecurrenceType.values.byName(map['recurrence'] as String),
      customIntervalDays: map['custom_interval_days'] as int?,
      enabled: map['enabled'] == 1,
      notificationId: map['notification_id'] as int,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Reminder copyWith({
    DateTime? dateTime,
    RecurrenceType? recurrence,
    int? customIntervalDays,
    bool? enabled,
  }) {
    return Reminder(
      id: id,
      noteId: noteId,
      userId: userId,
      dateTime: dateTime ?? this.dateTime,
      recurrence: recurrence ?? this.recurrence,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      enabled: enabled ?? this.enabled,
      notificationId: notificationId,
      createdAt: createdAt,
    );
  }

  String get recurrenceLabel {
    switch (recurrence) {
      case RecurrenceType.none:
        return "Ponctuel";
      case RecurrenceType.daily:
        return "Quotidien";
      case RecurrenceType.weekly:
        return "Hebdomadaire";
      case RecurrenceType.monthly:
        return "Mensuel";
      case RecurrenceType.custom:
        return "Tous les $customIntervalDays jours";
    }
  }
}
