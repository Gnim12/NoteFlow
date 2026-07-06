import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._();

  static final SessionService instance =
      SessionService._();

  static const String _userIdKey = "logged_user_id";

  Future<void> saveUserId(int id) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(_userIdKey, id);
  }

  Future<int?> getUserId() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getInt(_userIdKey);
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
  }
}