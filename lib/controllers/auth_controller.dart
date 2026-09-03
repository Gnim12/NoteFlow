import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart'
    show GoogleSignInException, GoogleSignInExceptionCode;

import '../core/errors/app_error.dart';
import '../core/errors/result.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/sharing_service.dart';

class PasswordResetResult {
  final bool success;
  final String message;

  const PasswordResetResult({required this.success, required this.message});
}

class AuthController {
  AuthController._();

  static final AuthController instance = AuthController._();
  final FirebaseAuthService _authService = FirebaseAuthService.instance;
  final SharingService _sharingService = SharingService.instance;

  /// Best-effort : permet à d'autres utilisateurs de retrouver ce compte par
  /// email pour partager une note avec lui (cf. phase 9).
  void _syncDirectoryEntry(User user) {
    _sharingService
        .upsertDirectoryEntry(uid: user.id, email: user.email, name: user.name)
        .catchError((_) {});
  }

  User? get currentUser {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return null;
    return _mapUser(firebaseUser);
  }

  User _mapUser(fb.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photo: firebaseUser.photoURL,
    );
  }

  AppError _mapAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppError.validation('Cet email est déjà utilisé.');
      case 'invalid-email':
        return AppError.validation('Adresse email invalide.');
      case 'weak-password':
        return AppError.validation(
          'Le mot de passe doit contenir au moins 6 caractères.',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppError.auth('Email ou mot de passe incorrect.');
      case 'requires-recent-login':
        return AppError.auth(
          'Cette action nécessite une reconnexion récente. Déconnectez-vous puis reconnectez-vous et réessayez.',
        );
      case 'network-request-failed':
        return AppError.persistence('Vérifiez votre connexion Internet.', e);
      default:
        return AppError.persistence(
          'Une erreur est survenue (${e.code}).',
          e,
        );
    }
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
    if (name.trim().isEmpty) {
      return Result.failure(AppError.validation('Veuillez saisir votre nom.'));
    }

    if (email.trim().isEmpty) {
      return Result.failure(
        AppError.validation('Veuillez saisir votre email.'),
      );
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

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());

      if (credential.user != null) {
        _syncDirectoryEntry(_mapUser(credential.user!).copyWith(name: name.trim()));
      }

      return Result.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
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
      final credential = await _authService.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Result.failure(AppError.auth('Connexion impossible.'));
      }

      final user = _mapUser(firebaseUser);
      _syncDirectoryEntry(user);

      return Result.success(user);
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(AppError.persistence('Connexion impossible.', e));
    }
  }

  /// ==========================
  /// CONNEXION GOOGLE
  /// ==========================
  Future<Result<User>> loginWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return Result.failure(AppError.auth('Connexion Google impossible.'));
      }

      final user = _mapUser(firebaseUser);
      _syncDirectoryEntry(user);

      return Result.success(user);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return Result.failure(AppError.validation('Connexion annulée.'));
      }
      return Result.failure(
        AppError.auth('Connexion Google impossible (${e.code}).'),
      );
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (e) {
      return Result.failure(
        AppError.persistence('Connexion Google impossible.', e),
      );
    }
  }

  Future<void> logout() => _authService.signOut();

  /// ==========================
  /// MOT DE PASSE OUBLIÉ
  /// ==========================
  Future<PasswordResetResult> sendPasswordResetEmail({
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return const PasswordResetResult(
        success: false,
        message: "Veuillez saisir votre email.",
      );
    }

    try {
      await _authService.sendPasswordResetEmail(normalizedEmail);

      return const PasswordResetResult(
        success: true,
        message:
            "Un email de réinitialisation a été envoyé. Consultez votre boîte de réception.",
      );
    } on fb.FirebaseAuthException catch (e) {
      return PasswordResetResult(
        success: false,
        message: _mapAuthException(e).message,
      );
    } catch (_) {
      return const PasswordResetResult(
        success: false,
        message: "Impossible d'envoyer l'email de réinitialisation.",
      );
    }
  }

  /// ==========================
  /// PROFIL
  /// ==========================
  Future<Result<User>> updateProfile({
    required User user,
    required String name,
    required String email,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      return Result.failure(AppError.validation('Veuillez saisir votre nom.'));
    }
    if (!_isValidEmail(normalizedEmail)) {
      return Result.failure(AppError.validation('Adresse email invalide.'));
    }

    try {
      await _authService.updateDisplayName(normalizedName);

      if (normalizedEmail != user.email) {
        await _authService.updateEmail(normalizedEmail);
      }

      final updated = user.copyWith(
        name: normalizedName,
        email: normalizedEmail,
      );
      _syncDirectoryEntry(updated);

      return Result.success(updated);
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (error) {
      return Result.failure(
        AppError.persistence('Impossible de mettre à jour le profil.', error),
      );
    }
  }

  Future<Result<void>> changePassword(String newPassword) async {
    if (newPassword.length < 6) {
      return Result.failure(
        AppError.validation(
          'Le mot de passe doit contenir au moins 6 caractères.',
        ),
      );
    }

    try {
      await _authService.updatePassword(newPassword);
      return Result.success(null);
    } on fb.FirebaseAuthException catch (e) {
      return Result.failure(_mapAuthException(e));
    } catch (error) {
      return Result.failure(
        AppError.persistence(
          'Impossible de modifier le mot de passe.',
          error,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}
