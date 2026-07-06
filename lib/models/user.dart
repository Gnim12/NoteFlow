class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? photo;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photo': photo,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      photo: map['photo'],
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? photo,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photo: photo ?? this.photo,
    );
  }
}