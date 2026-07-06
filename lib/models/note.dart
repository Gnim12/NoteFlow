class Note {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final int color;
  final bool isFavorite;
  final bool isPinned;

  const Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.color = 0xFF2563EB,
    this.isFavorite = false,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'color': color,
      'is_favorite': isFavorite ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      color: map['color'],
      isFavorite: map['is_favorite'] == 1,
      isPinned: map['is_pinned'] == 1,
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    int? color,
    bool? isFavorite,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}