enum SharePermission { read, write }

/// Un partage relie une note (identifiée par [noteId] + [ownerId]) à un
/// destinataire ([sharedWithUid]). Contrairement aux notes propres à un
/// utilisateur, les partages n'existent que côté Firestore : consulter ou
/// modifier une note partagée nécessite donc une connexion Internet (aucune
/// mise en cache locale hors ligne pour cette fonctionnalité).
class SharedNote {
  final String id;
  final String noteId;
  final String ownerId;
  final String? ownerEmail;
  final String sharedWithUid;
  final String sharedWithEmail;
  final SharePermission permission;
  final DateTime createdAt;

  const SharedNote({
    required this.id,
    required this.noteId,
    required this.ownerId,
    this.ownerEmail,
    required this.sharedWithUid,
    required this.sharedWithEmail,
    required this.permission,
    required this.createdAt,
  });

  static String idFor({required String noteId, required String sharedWithUid}) {
    return '${noteId}_$sharedWithUid';
  }

  Map<String, dynamic> toMap() {
    return {
      'note_id': noteId,
      'owner_id': ownerId,
      'owner_email': ownerEmail,
      'shared_with_uid': sharedWithUid,
      'shared_with_email': sharedWithEmail,
      'permission': permission.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SharedNote.fromMap(String id, Map<String, dynamic> map) {
    return SharedNote(
      id: id,
      noteId: map['note_id'] as String,
      ownerId: map['owner_id'] as String,
      ownerEmail: map['owner_email'] as String?,
      sharedWithUid: map['shared_with_uid'] as String,
      sharedWithEmail: map['shared_with_email'] as String,
      permission: SharePermission.values.byName(map['permission'] as String),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
