import 'dart:convert';

import 'location_model.dart';

class Note {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int color;
  final bool isFavorite;
  final bool isPinned;
  final String? categoryId;
  final List<String> tags;
  final DateTime? deletedAt;
  final NoteLocation? location;

  const Note({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.color = 0xFF2563EB,
    this.isFavorite = false,
    this.isPinned = false,
    this.categoryId,
    this.tags = const [],
    this.deletedAt,
    this.location,
  });

  bool get isInTrash => deletedAt != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'color': color,
      'is_favorite': isFavorite ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'category_id': categoryId,
      'tags': jsonEncode(tags),
      'deleted_at': deletedAt?.toIso8601String(),
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'place_name': location?.placeName,
      'address': location?.address,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      color: map['color'],
      isFavorite: map['is_favorite'] == 1,
      isPinned: map['is_pinned'] == 1,
      categoryId: map['category_id'] as String?,
      tags: map['tags'] == null
          ? const []
          : List<String>.from(jsonDecode(map['tags'] as String) as List),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.parse(map['deleted_at'] as String),
      location: map['latitude'] == null
          ? null
          : NoteLocation(
              latitude: (map['latitude'] as num).toDouble(),
              longitude: (map['longitude'] as num).toDouble(),
              placeName: map['place_name'] as String?,
              address: map['address'] as String?,
            ),
    );
  }

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? color,
    bool? isFavorite,
    bool? isPinned,
    String? categoryId,
    List<String>? tags,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      deletedAt: deletedAt,
      location: location,
    );
  }

  /// [copyWith] ne peut pas remettre `deletedAt` à `null` (pattern
  /// `??`) : cette méthode dédiée gère explicitement la corbeille.
  Note copyWithDeletedAt(DateTime? deletedAt) {
    return Note(
      id: id,
      userId: userId,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      isFavorite: isFavorite,
      isPinned: isPinned,
      categoryId: categoryId,
      tags: tags,
      deletedAt: deletedAt,
      location: location,
    );
  }

  /// [copyWith] ne peut pas remettre `location` à `null` : cette méthode
  /// dédiée gère explicitement l'ajout/la modification/la suppression de
  /// la localisation associée.
  Note copyWithLocation(NoteLocation? location) {
    return Note(
      id: id,
      userId: userId,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: color,
      isFavorite: isFavorite,
      isPinned: isPinned,
      categoryId: categoryId,
      tags: tags,
      deletedAt: deletedAt,
      location: location,
    );
  }
}
