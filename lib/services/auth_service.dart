import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../core/errors/app_error.dart';
import '../core/errors/result.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

class PasswordResetResult {
  final bool success;
  final String message;
  final String? code;

  const PasswordResetResult({
    required this.success,
    required this.message,
    this.code,
  });
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final AuthRepository _repository = AuthRepository.instance;

  static const _passwordIterations = 100000;

  String _hashPassword(String value, {String? salt}) {
    final actualSalt = salt ?? _generateSalt();
    var block = Hmac(
      sha256,
      utf8.encode(actualSalt),
    ).convert(utf8.encode(value)).bytes;
    final derived = List<int>.from(block);

    for (var index = 1; index < _passwordIterations; index++) {
      block = Hmac(sha256, utf8.encode(value)).convert(block).bytes;
      for (var byteIndex = 0; byteIndex < derived.length; byteIndex++) {
        derived[byteIndex] ^= block[byteIndex];
      }
    }

    return 'pbkdf2-sha256\$$_passwordIterations\$$actualSalt\$${base64Encode(derived)}';
  }

  String _generateSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  bool _matchesPassword(String password, String storedPassword) {
    final parts = storedPassword.split(r'$');
    if (parts.length == 4 && parts.first == 'pbkdf2-sha256') {
      return _hashPassword(password, salt: parts[2]) == storedPassword;
    }

    return storedPassword == sha256.convert(utf8.encode(password)).toString() ||
        storedPassword == password;
  }

  String _generateResetCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// ==========================
  /// INSCRIPTION
  /// ==========================
  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (name.trim().isEmpty) {
        return Result.failure(
          AppError.validation('Veuillez saisir votre nom.'),
        );
      }

      if (email.trim().isEmpty) {
        return Result.failure(
          AppError.validation('Veuillez saisir votre email.'),
        );
      }

      if (!email.contains('@') || !email.contains('.')) {
        return Result.failure(AppError.validation('Adresse email invalide.'));
      }

      if (password.length < 6) {
        return Result.failure(
          AppError.validation(
            'Le mot de passe doit contenir au moins 6 caractères.',
          ),
        );
      }

      if (password != confirmPassword) {
        return Result.failure(
          AppError.validation('Les mots de passe ne correspondent pas.'),
        );
      }

      final normalizedEmail = email.trim().toLowerCase();
      final exists = await _repository.emailExists(normalizedEmail);

      if (exists) {
        return Result.failure(
          AppError.validation('Cet email est déjà utilisé.'),
        );
      }

      final user = User(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: _hashPassword(password),
      );

      await _repository.insertUser(user);

      return Result.success(null);
    } catch (e) {
      return Result.failure(
        AppError.persistence('Impossible de créer le compte.', e),
      );
    }
  }

  /// ==========================
  /// CONNEXION
  /// ==========================
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return Result.failure(
        AppError.validation('Veuillez remplir tous les champs.'),
      );
    }

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final user = await _repository.getUserByEmail(normalizedEmail);

      if (user == null) {
        return Result.failure(
          AppError.auth('Email ou mot de passe incorrect.'),
        );
      }

      if (_matchesPassword(password, user.password)) {
        if (!user.password.startsWith('pbkdf2-sha256\$')) {
          await _repository.updateUser(
            user.copyWith(password: _hashPassword(password)),
          );
        }
        return Result.success(user);
      }

      return Result.failure(AppError.auth('Email ou mot de passe incorrect.'));
    } catch (e) {
      return Result.failure(AppError.persistence('Connexion impossible.', e));
    }
  }

  /// ==========================
  /// MOT DE PASSE OUBLIÉ
  /// ==========================
  Future<PasswordResetResult> requestPasswordReset({
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return const PasswordResetResult(
        success: false,
        message: "Veuillez saisir votre email.",
      );
    }

    final user = await _repository.getUserByEmail(normalizedEmail);

    if (user == null) {
      return const PasswordResetResult(
        success: false,
        message: "Aucun compte ne correspond à cet email.",
      );
    }

    final code = _generateResetCode();
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    await _repository.updateResetCode(
      userId: user.id!,
      resetCode: _hashPassword(code),
      expiresAt: expiresAt,
    );

    return PasswordResetResult(
      success: true,
      message:
          "Un code de vérification a été généré. Utilisez-le pour réinitialiser votre mot de passe.",
      code: code,
    );
  }

  Future<PasswordResetResult> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await _repository.getUserByEmail(normalizedEmail);

    if (user == null) {
      return const PasswordResetResult(
        success: false,
        message: "Aucun compte ne correspond à cet email.",
      );
    }

    if (user.resetCode == null || user.resetCodeExpiresAt == null) {
      return const PasswordResetResult(
        success: false,
        message: "Aucun code de réinitialisation n’a été demandé.",
      );
    }

    if (DateTime.now().isAfter(user.resetCodeExpiresAt!)) {
      return const PasswordResetResult(
        success: false,
        message: "Le code a expiré. Demandez un nouveau code.",
      );
    }

    if (user.resetCode != _hashPassword(code)) {
      return const PasswordResetResult(
        success: false,
        message: "Le code est invalide.",
      );
    }

    return const PasswordResetResult(success: true, message: "Code valide.");
  }

  Future<PasswordResetResult> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (newPassword.length < 6) {
      return const PasswordResetResult(
        success: false,
        message: "Le mot de passe doit contenir au moins 6 caractères.",
      );
    }

    final verification = await verifyResetCode(
      email: normalizedEmail,
      code: code,
    );

    if (!verification.success) {
      return verification;
    }

    final user = await _repository.getUserByEmail(normalizedEmail);

    if (user == null) {
      return const PasswordResetResult(
        success: false,
        message: "Compte introuvable.",
      );
    }

    await _repository.updatePassword(
      userId: user.id!,
      newPassword: _hashPassword(newPassword),
    );

    return const PasswordResetResult(
      success: true,
      message: "Votre mot de passe a été réinitialisé avec succès.",
    );
  }

  Future<Result<User>> updateProfile({
    required User user,
    required String name,
    required String email,
    String? newPassword,
    String? photo,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      return Result.failure(AppError.validation('Veuillez saisir votre nom.'));
    }
    if (!_isValidEmail(normalizedEmail)) {
      return Result.failure(AppError.validation('Adresse email invalide.'));
    }
    if (newPassword != null &&
        newPassword.isNotEmpty &&
        newPassword.length < 6) {
      return Result.failure(
        AppError.validation(
          'Le mot de passe doit contenir au moins 6 caractères.',
        ),
      );
    }

    try {
      final owner = await _repository.getUserByEmail(normalizedEmail);
      if (owner != null && owner.id != user.id) {
        return Result.failure(
          AppError.validation('Cet email est déjà utilisé.'),
        );
      }

      final updated = user.copyWith(
        name: normalizedName,
        email: normalizedEmail,
        password: newPassword == null || newPassword.isEmpty
            ? user.password
            : _hashPassword(newPassword),
        photo: photo,
      );
      await _repository.updateUser(updated);
      return Result.success(updated);
    } catch (error) {
      return Result.failure(
        AppError.persistence('Impossible de mettre à jour le profil.', error),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$').hasMatch(email);
  }
}
