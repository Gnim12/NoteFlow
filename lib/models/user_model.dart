class User {
  final String id;
  final String name;
  final String email;
  final String? photo;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
  });

  User copyWith({String? id, String? name, String? email, String? photo}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
    );
  }
}
