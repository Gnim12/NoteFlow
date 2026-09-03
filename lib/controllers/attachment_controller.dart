import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/attachment_model.dart';
import '../services/firestore_service.dart';
import '../services/image_service.dart';
import '../services/sqlite_service.dart';
import '../services/storage_service.dart';

/// Comme pour les catégories, l'envoi vers Firebase Storage est "best
/// effort" : la pièce jointe est immédiatement utilisable en local hors
/// ligne, et l'envoi est retenté à la prochaine ouverture de la note s'il a
/// échoué. La file d'attente robuste de la phase 4 est réservée aux notes.
class AttachmentController {
  AttachmentController._();

  static final AttachmentController instance = AttachmentController._();

  final SqliteService _service = SqliteService.instance;
  final StorageService _storageService = StorageService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final ImageService _imageService = ImageService.instance;

  static const _uuid = Uuid();

  Future<List<Attachment>> getAttachments(String noteId) {
    return _service.getAttachments(noteId);
  }

  Future<Attachment?> addImageFromGallery({
    required String noteId,
    required String userId,
  }) async {
    final path = await _imageService.pickImageFromGallery();
    if (path == null) return null;

    return _saveAttachment(
      noteId: noteId,
      userId: userId,
      localPath: path,
      type: AttachmentType.image,
    );
  }

  Future<Attachment?> addImageFromCamera({
    required String noteId,
    required String userId,
  }) async {
    final path = await _imageService.pickImageFromCamera();
    if (path == null) return null;

    return _saveAttachment(
      noteId: noteId,
      userId: userId,
      localPath: path,
      type: AttachmentType.image,
    );
  }

  Future<Attachment?> addFile({
    required String noteId,
    required String userId,
  }) async {
    final result = await FilePicker.pickFile();
    final pickedPath = result?.path;
    if (pickedPath == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final fileName = "${_uuid.v4()}_${p.basename(pickedPath)}";
    final savedFile = await File(
      pickedPath,
    ).copy("${directory.path}/$fileName");

    return _saveAttachment(
      noteId: noteId,
      userId: userId,
      localPath: savedFile.path,
      type: AttachmentType.file,
    );
  }

  Future<Attachment> _saveAttachment({
    required String noteId,
    required String userId,
    required String localPath,
    required AttachmentType type,
  }) async {
    final attachment = Attachment(
      id: _uuid.v4(),
      noteId: noteId,
      userId: userId,
      type: type,
      fileName: p.basename(localPath),
      localPath: localPath,
      createdAt: DateTime.now(),
    );

    await _service.insertAttachment(attachment);
    _uploadInBackground(attachment);

    return attachment;
  }

  /// Tente d'envoyer les pièces jointes de la note qui n'ont pas encore été
  /// hébergées sur Storage (ex. ajoutées hors ligne). Appelé à l'ouverture
  /// du détail d'une note.
  Future<void> retryPendingUploads(String noteId) async {
    final attachments = await getAttachments(noteId);

    for (final attachment in attachments.where((a) => !a.isUploaded)) {
      await _upload(attachment);
    }
  }

  void _uploadInBackground(Attachment attachment) {
    _upload(attachment).catchError((_) {});
  }

  Future<void> _upload(Attachment attachment) async {
    try {
      final storagePath = _storageService.pathFor(
        userId: attachment.userId,
        noteId: attachment.noteId,
        fileName: "${attachment.id}_${attachment.fileName}",
      );

      final downloadUrl = await _storageService.uploadFile(
        storagePath: storagePath,
        file: File(attachment.localPath),
      );

      final uploaded = attachment.copyWith(
        storagePath: storagePath,
        downloadUrl: downloadUrl,
      );

      await _service.updateAttachment(uploaded);
      await _firestoreService.setAttachment(uploaded);
    } catch (_) {
      // Hors ligne ou erreur réseau : la pièce jointe reste utilisable en
      // local, l'envoi sera retenté plus tard (cf. [retryPendingUploads]).
    }
  }

  Future<void> deleteAttachment(Attachment attachment) async {
    await _service.deleteAttachment(attachment.id!);

    try {
      await File(attachment.localPath).delete();
    } catch (_) {
      // Fichier déjà absent : rien à faire.
    }

    if (attachment.storagePath != null) {
      _storageService.deleteFile(attachment.storagePath!).catchError((_) {});
      _firestoreService
          .deleteAttachment(
            userId: attachment.userId,
            noteId: attachment.noteId,
            attachmentId: attachment.id!,
          )
          .catchError((_) {});
    }
  }
}
