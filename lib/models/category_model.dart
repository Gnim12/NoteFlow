class Category {
  final String? id;
  final String userId;
  final String name;
  final int color;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.userId,
    required this.name,
    this.color = 0xFF2563EB,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Category copyWith({String? id, String? userId, String? name, int? color}) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
}
