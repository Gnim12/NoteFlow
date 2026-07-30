class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? photo;
  final String? resetCode;
  final DateTime? resetCodeExpiresAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.photo,
    this.resetCode,
    this.resetCodeExpiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photo': photo,
      'reset_code': resetCode,
      'reset_code_expires_at': resetCodeExpiresAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      photo: map['photo'],
      resetCode: map['reset_code'],
      resetCodeExpiresAt: map['reset_code_expires_at'] != null
          ? DateTime.parse(map['reset_code_expires_at'])
          : null,
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? photo,
    String? resetCode,
    DateTime? resetCodeExpiresAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      photo: photo ?? this.photo,
      resetCode: resetCode ?? this.resetCode,
      resetCodeExpiresAt: resetCodeExpiresAt ?? this.resetCodeExpiresAt,
    );
  }
}
