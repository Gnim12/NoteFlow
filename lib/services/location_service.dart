import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  final Geocoding _geocoding = Geocoding();

  /// Demande la permission puis renvoie la position actuelle. Lève une
  /// [Exception] avec un message explicite si le service ou la permission
  /// est indisponible.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permission de localisation refusée.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission de localisation refusée définitivement. Autorisez-la depuis les paramètres de l\'application.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Adresse lisible correspondant à des coordonnées (géocodage inverse).
  Future<String?> addressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;

      return _formatPlacemark(placemarks.first);
    } catch (_) {
      return null;
    }
  }

  /// Recherche un lieu par son nom/adresse (géocodage direct).
  Future<List<PlaceCandidate>> searchPlace(String query) async {
    try {
      final locations = await _geocoding.locationFromAddress(query);
      final candidates = <PlaceCandidate>[];

      for (final location in locations) {
        final address = await addressFromCoordinates(
          location.latitude,
          location.longitude,
        );

        candidates.add(
          PlaceCandidate(
            latitude: location.latitude,
            longitude: location.longitude,
            address: address,
          ),
        );
      }

      return candidates;
    } catch (_) {
      return [];
    }
  }

  String _formatPlacemark(Placemark placemark) {
    final parts = [
      placemark.street,
      placemark.locality,
      placemark.postalCode,
      placemark.country,
    ].where((part) => part != null && part.isNotEmpty);

    return parts.join(', ');
  }
}

class PlaceCandidate {
  final double latitude;
  final double longitude;
  final String? address;

  const PlaceCandidate({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
