/// Localisation associée à une note. Contrairement aux catégories ou aux
/// pièces jointes, elle est embarquée directement dans le document de la
/// note (cf. cahier des charges §8.1 "locationId ou objet location") :
/// elle profite ainsi gratuitement de la file de synchronisation robuste et
/// de la résolution de conflits déjà en place pour les notes.
class NoteLocation {
  final double latitude;
  final double longitude;
  final String? placeName;
  final String? address;

  const NoteLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'place_name': placeName,
      'address': address,
    };
  }

  factory NoteLocation.fromMap(Map<String, dynamic> map) {
    return NoteLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      placeName: map['place_name'] as String?,
      address: map['address'] as String?,
    );
  }

  /// Libellé lisible : nom du lieu si disponible, sinon l'adresse, sinon
  /// les coordonnées brutes.
  String get displayLabel {
    if (placeName != null && placeName!.isNotEmpty) return placeName!;
    if (address != null && address!.isNotEmpty) return address!;
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }
}
