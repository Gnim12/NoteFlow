import '../database/database_helper.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  Future<bool> emailExists(String email) async {
    return DatabaseHelper.instance.emailExists(email);
  }

  Future<int> insertUser(User user) async {
    return DatabaseHelper.instance.insertUser(user);
  }

  Future<User?> getUserByEmail(String email) async {
    return DatabaseHelper.instance.getUserByEmail(email);
  }

  Future<User?> getUserById(int id) async {
    return DatabaseHelper.instance.getUserById(id);
  }

  Future<int> updateResetCode({
    required int userId,
    required String? resetCode,
    required DateTime? expiresAt,
  }) async {
    return DatabaseHelper.instance.updateResetCode(
      userId: userId,
      resetCode: resetCode,
      expiresAt: expiresAt,
    );
  }

  Future<int> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    return DatabaseHelper.instance.updatePassword(
      userId: userId,
      newPassword: newPassword,
    );
  }

  Future<int> updateUser(User user) async {
    return DatabaseHelper.instance.updateUser(user);
  }

  Future<User?> authenticateUser({
    required String email,
    required String password,
  }) async {
    return DatabaseHelper.instance.authenticateUser(email, password);
  }
}
