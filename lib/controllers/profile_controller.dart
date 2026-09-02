import 'package:shared_preferences/shared_preferences.dart';

import '../core/errors/result.dart';
import '../models/user_model.dart';
import '../services/image_service.dart';
import 'auth_controller.dart';

class ProfileController {
  ProfileController._();

  static final ProfileController instance = ProfileController._();

  final ImageService _imageService = ImageService.instance;
  final AuthController _authController = AuthController.instance;

  String _photoCacheKey(String userId) => 'profile_photo_$userId';

  /// La photo de profil est mise en cache localement en attendant l'arrivée
  /// de Firebase Storage (voir la phase pièces jointes).
  Future<User?> loadCurrentUser() async {
    final user = _authController.currentUser;
    if (user == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final cachedPhoto = prefs.getString(_photoCacheKey(user.id));

    return cachedPhoto == null ? user : user.copyWith(photo: cachedPhoto);
  }

  Future<Result<User>> saveProfile({
    required User user,
    required String name,
    required String email,
  }) {
    return _authController.updateProfile(user: user, name: name, email: email);
  }

  Future<String?> pickPhoto(String source) {
    if (source == "gallery") {
      return _imageService.pickImageFromGallery();
    }
    if (source == "camera") {
      return _imageService.pickImageFromCamera();
    }
    return Future.value(null);
  }

  Future<User> updatePhoto(User user, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoCacheKey(user.id), path);

    return user.copyWith(photo: path);
  }
}
