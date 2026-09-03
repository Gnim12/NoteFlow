import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/shared_note_model.dart';

/// Couche technique pour le partage de notes. Contrairement aux autres
/// services Firestore de l'application, ceux-ci reposent sur des
/// collections racine (non imbriquées sous `users/{uid}`) car ils doivent
/// être visibles par un autre utilisateur que le propriétaire des données.
class SharingService {
  SharingService._();

  static final SharingService instance = SharingService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userDirectory =>
      _db.collection('user_directory');

  CollectionReference<Map<String, dynamic>> get _sharedNotes =>
      _db.collection('shared_notes');

  /// Enregistre/actualise l'entrée d'annuaire de l'utilisateur courant, afin
  /// que d'autres utilisateurs puissent le retrouver par email pour partager
  /// une note avec lui. Best-effort : appelé après connexion/inscription.
  Future<void> upsertDirectoryEntry({
    required String uid,
    required String email,
    required String name,
  }) {
    return _userDirectory.doc(uid).set({
      'email': email.trim().toLowerCase(),
      'name': name,
    });
  }

  /// Résout l'UID d'un utilisateur à partir de son email, via l'annuaire.
  Future<String?> findUidByEmail(String email) async {
    final snapshot = await _userDirectory
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.id;
  }

  Future<void> shareNote(SharedNote share) {
    return _sharedNotes.doc(share.id).set(share.toMap());
  }

  Future<void> updatePermission({
    required String shareId,
    required SharePermission permission,
  }) {
    return _sharedNotes.doc(shareId).update({'permission': permission.name});
  }

  Future<void> revokeShare(String shareId) {
    return _sharedNotes.doc(shareId).delete();
  }

  /// Liste des partages actifs pour une note donnée (utilisé par le
  /// propriétaire pour voir/gérer qui a accès).
  Future<List<SharedNote>> getSharesForNote({
    required String ownerId,
    required String noteId,
  }) async {
    final snapshot = await _sharedNotes
        .where('owner_id', isEqualTo: ownerId)
        .where('note_id', isEqualTo: noteId)
        .get();

    return snapshot.docs
        .map((doc) => SharedNote.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Notes que d'autres utilisateurs ont partagées avec l'utilisateur donné.
  Future<List<SharedNote>> getNotesSharedWithMe(String uid) async {
    final snapshot = await _sharedNotes
        .where('shared_with_uid', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) => SharedNote.fromMap(doc.id, doc.data()))
        .toList();
  }
}
