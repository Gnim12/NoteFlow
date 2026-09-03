enum RecurrenceType { none, daily, weekly, monthly, custom }

/// Un rappel se déclenche soit à une date/heure ([ReminderTriggerType.time]),
/// soit à l'approche d'un lieu ([ReminderTriggerType.location]) — cf. cahier
/// des charges §5.9, fonctionnalité avancée.
enum ReminderTriggerType { time, location }

class Reminder {
  final String? id;
  final String noteId;
  final String userId;
  final ReminderTriggerType triggerType;
  final DateTime dateTime;
  final RecurrenceType recurrence;

  /// Nombre de jours entre deux occurrences, utilisé seulement quand
  /// [recurrence] vaut [RecurrenceType.custom].
  final int? customIntervalDays;

  /// Champs utilisés uniquement quand [triggerType] vaut
  /// [ReminderTriggerType.location].
  final double? latitude;
  final double? longitude;
  final double? radiusMeters;
  final String? placeName;

  final bool enabled;

  /// Identifiant numérique donné à `flutter_local_notifications` pour cette
  /// notification (nécessaire pour pouvoir l'annuler/la remplacer). Sert
  /// aussi d'identifiant de géofence (converti en chaîne) pour les rappels
  /// géolocalisés.
  final int notificationId;

  final DateTime createdAt;

  const Reminder({
    this.id,
    required this.noteId,
    required this.userId,
    this.triggerType = ReminderTriggerType.time,
    required this.dateTime,
    this.recurrence = RecurrenceType.none,
    this.customIntervalDays,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    this.placeName,
    this.enabled = true,
    required this.notificationId,
    required this.createdAt,
  });

  bool get isLocationBased => triggerType == ReminderTriggerType.location;

  /// Identifiant utilisé côté `native_geofence` pour ce rappel.
  String get geofenceId => 'reminder_$id';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'trigger_type': triggerType.name,
      'date_time': dateTime.toIso8601String(),
      'recurrence': recurrence.name,
      'custom_interval_days': customIntervalDays,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'place_name': placeName,
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
      triggerType: ReminderTriggerType.values.byName(
        (map['trigger_type'] as String?) ?? ReminderTriggerType.time.name,
      ),
      dateTime: DateTime.parse(map['date_time']),
      recurrence: RecurrenceType.values.byName(map['recurrence'] as String),
      customIntervalDays: map['custom_interval_days'] as int?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      radiusMeters: (map['radius_meters'] as num?)?.toDouble(),
      placeName: map['place_name'] as String?,
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
      triggerType: triggerType,
      dateTime: dateTime ?? this.dateTime,
      recurrence: recurrence ?? this.recurrence,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      placeName: placeName,
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
