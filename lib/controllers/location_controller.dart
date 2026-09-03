import 'package:url_launcher/url_launcher.dart';

import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationController {
  LocationController._();

  static final LocationController instance = LocationController._();
  final LocationService _service = LocationService.instance;

  Future<NoteLocation> getCurrentLocation() async {
    final position = await _service.getCurrentPosition();
    final address = await _service.addressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return NoteLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: address,
    );
  }

  Future<List<PlaceCandidate>> searchPlace(String query) {
    return _service.searchPlace(query);
  }

  Future<String?> addressFromCoordinates(double lat, double lng) {
    return _service.addressFromCoordinates(lat, lng);
  }

  /// Ouvre la localisation dans l'application de navigation par défaut.
  Future<bool> openInMapsApp(NoteLocation location) {
    final uri = Uri.parse(
      'geo:${location.latitude},${location.longitude}?q=${location.latitude},${location.longitude}(${Uri.encodeComponent(location.displayLabel)})',
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
