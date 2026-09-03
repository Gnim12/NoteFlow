import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_geofence/native_geofence.dart';

import '../models/reminder_model.dart';
import 'sqlite_service.dart';

/// Couche technique pour les rappels géolocalisés (cahier des charges §5.9,
/// fonctionnalité avancée), basée sur l'API native de géofencing d'Android
/// (`GeofencingClient`, via le plugin `native_geofence`) plutôt que sur une
/// surveillance continue de la position : c'est l'approche recommandée par
/// Android pour respecter les contraintes d'exécution en arrière-plan et
/// préserver la batterie (§11 "Sécurité").
class GeofenceService {
  GeofenceService._();

  static final GeofenceService instance = GeofenceService._();

  Future<void> init() async {
    await NativeGeofenceManager.instance.initialize();
  }

  /// Demande la localisation en avant-plan puis en arrière-plan.
  ///
  /// À partir d'Android 10, l'autorisation "Toujours autoriser" ne peut pas
  /// être demandée dans la même boîte de dialogue que l'autorisation
  /// classique : il faut redemander une seconde fois une fois la première
  /// accordée. Sur Android 11+, l'OS peut aussi exiger que l'utilisateur
  /// bascule ce réglage manuellement depuis les paramètres de l'application
  /// (Localisation → Autoriser tout le temps) : c'est une contrainte du
  /// système, pas du plugin.
  Future<bool> requestPermissions() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission != LocationPermission.always) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always;
  }

  Future<void> registerGeofence(Reminder reminder) async {
    final geofence = Geofence(
      id: reminder.geofenceId,
      location: Location(
        latitude: reminder.latitude!,
        longitude: reminder.longitude!,
      ),
      radiusMeters: reminder.radiusMeters ?? 200,
      triggers: const {GeofenceEvent.enter},
      iosSettings: const IosGeofenceSettings(),
      androidSettings: const AndroidGeofenceSettings(initialTriggers: {}),
    );

    await NativeGeofenceManager.instance.createGeofence(
      geofence,
      geofenceCallback,
    );
  }

  Future<void> removeGeofence(Reminder reminder) {
    return NativeGeofenceManager.instance.removeGeofenceById(
      reminder.geofenceId,
    );
  }
}

/// Exécuté par le système quand l'utilisateur entre dans une zone
/// surveillée — potentiellement dans un isolate séparé, application
/// totalement fermée. Ne peut donc s'appuyer sur aucun état déjà initialisé
/// par l'application principale : la base SQLite et le plugin de
/// notifications sont ré-instanciés ici.
@pragma('vm:entry-point')
Future<void> geofenceCallback(GeofenceCallbackParams params) async {
  if (params.event != GeofenceEvent.enter) return;

  final sqliteService = SqliteService.instance;
  final notifications = FlutterLocalNotificationsPlugin();

  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  for (final geofence in params.geofences) {
    final reminderId = geofence.id.replaceFirst('reminder_', '');
    final reminder = await sqliteService.getReminderById(reminderId);
    if (reminder == null || !reminder.enabled) continue;

    final note = await sqliteService.getNoteById(
      reminder.noteId,
      reminder.userId,
    );
    if (note == null) continue;

    await notifications.show(
      id: reminder.notificationId,
      title: note.title,
      body: reminder.placeName != null
          ? "Vous êtes à proximité de ${reminder.placeName}"
          : (note.description.isEmpty
                ? "Rappel de localisation"
                : note.description),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'note_location_reminders',
          'Rappels géolocalisés',
          channelDescription:
              "Notifications déclenchées à l'approche d'un lieu",
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: note.id,
    );
  }
}
