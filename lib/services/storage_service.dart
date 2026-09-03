import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  String pathFor({
    required String userId,
    required String noteId,
    required String fileName,
  }) {
    return 'users/$userId/notes/$noteId/$fileName';
  }

  Future<String> uploadFile({
    required String storagePath,
    required File file,
  }) async {
    final ref = _storage.ref(storagePath);
    await ref.putFile(file);

    return ref.getDownloadURL();
  }

  Future<void> deleteFile(String storagePath) {
    return _storage.ref(storagePath).delete();
  }
}
