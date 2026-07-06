import '../database/database_helper.dart';
import '../models/user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// ==========================
  /// INSCRIPTION
  /// ==========================
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Vérification des champs
    if (name.trim().isEmpty) {
      return "Veuillez saisir votre nom.";
    }

    if (email.trim().isEmpty) {
      return "Veuillez saisir votre email.";
    }

    if (!email.contains("@") || !email.contains(".")) {
      return "Adresse email invalide.";
    }

    if (password.length < 6) {
      return "Le mot de passe doit contenir au moins 6 caractères.";
    }

    if (password != confirmPassword) {
      return "Les mots de passe ne correspondent pas.";
    }

    // Vérifier si l'email existe déjà
    final exists = await DatabaseHelper.instance.emailExists(email);

    if (exists) {
      return "Cet email est déjà utilisé.";
    }

    final user = User(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );

    await DatabaseHelper.instance.insertUser(user);

    return null;
  }

  /// ==========================
  /// CONNEXION
  /// ==========================
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    return await DatabaseHelper.instance.authenticateUser(
      email.trim().toLowerCase(),
      password,
    );
  }
}