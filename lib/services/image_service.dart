import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  ImageService._();

  static final ImageService instance = ImageService._();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();

    final fileName = basename(image.path);

    final savedImage = await File(image.path).copy(
      "${directory.path}/$fileName",
    );

    return savedImage.path;
  }

  Future<String?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return null;

    final directory = await getApplicationDocumentsDirectory();

    final fileName = basename(image.path);

    final savedImage = await File(image.path).copy(
      "${directory.path}/$fileName",
    );

    return savedImage.path;
  }
}