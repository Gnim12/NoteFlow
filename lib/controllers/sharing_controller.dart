import '../core/errors/app_error.dart';
import '../core/errors/result.dart';
import '../models/note_model.dart';
import '../models/shared_note_model.dart';
import '../services/firestore_service.dart';
import '../services/sharing_service.dart';
import 'auth_controller.dart';

class SharedNoteWithData {
  final SharedNote share;
  final Note note;

  const SharedNoteWithData({required this.share, required this.note});
}

class SharingController {
  SharingController._();

  static final SharingController instance = SharingController._();

  final SharingService _service = SharingService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  Future<Result<SharedNote>> shareNote({
    required Note note,
    required String email,
    required SharePermission permission,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return Result.failure(AppError.validation('Veuillez saisir un email.'));
    }

    try {
      final uid = await _service.findUidByEmail(normalizedEmail);

      if (uid == null) {
        return Result.failure(
          AppError.validation(
            'Aucun utilisateur NoteFlow trouvé avec cet email.',
          ),
        );
      }

      if (uid == note.userId) {
        return Result.failure(
          AppError.validation(
            'Vous ne pouvez pas partager une note avec vous-même.',
          ),
        );
      }

      final share = SharedNote(
        id: SharedNote.idFor(noteId: note.id!, sharedWithUid: uid),
        noteId: note.id!,
        ownerId: note.userId,
        ownerEmail: AuthController.instance.currentUser?.email,
        sharedWithUid: uid,
        sharedWithEmail: normalizedEmail,
        permission: permission,
        createdAt: DateTime.now(),
      );

      // S'assure que la note existe bien côté Firestore (elle peut ne pas
      // encore avoir été synchronisée si l'appareil vient d'être hors ligne).
      await _firestoreService.setNote(note);
      await _service.shareNote(share);

      return Result.success(share);
    } catch (e) {
      return Result.failure(
        AppError.persistence('Impossible de partager la note.', e),
      );
    }
  }

  Future<List<SharedNote>> getSharesForNote(Note note) {
    return _service.getSharesForNote(ownerId: note.userId, noteId: note.id!);
  }

  Future<void> updatePermission(String shareId, SharePermission permission) {
    return _service.updatePermission(shareId: shareId, permission: permission);
  }

  Future<void> revokeShare(String shareId) {
    return _service.revokeShare(shareId);
  }

  Future<List<SharedNoteWithData>> getNotesSharedWithMe(String uid) async {
    final shares = await _service.getNotesSharedWithMe(uid);
    final result = <SharedNoteWithData>[];

    for (final share in shares) {
      final note = await _firestoreService.getNote(
        userId: share.ownerId,
        noteId: share.noteId,
      );
      if (note != null) {
        result.add(SharedNoteWithData(share: share, note: note));
      }
    }

    return result;
  }

  /// Écrit directement sur Firestore : les notes partagées ne transitent pas
  /// par le cache SQLite ni la file de synchronisation locale (celles-ci
  /// sont indexées par propriétaire), une connexion est donc nécessaire pour
  /// modifier une note partagée.
  Future<void> updateSharedNote(Note note) {
    return _firestoreService.setNote(
      note.copyWith(updatedAt: DateTime.now()),
    );
  }
}
