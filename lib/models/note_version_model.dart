/// Instantané du titre/contenu d'une note avant une modification, pour
/// permettre de consulter l'historique et restaurer une version précédente
/// (cf. cahier des charges §5.1).
class NoteVersion {
  final String? id;
  final String noteId;
  final String userId;
  final String title;
  final String description;
  final DateTime savedAt;

  const NoteVersion({
    this.id,
    required this.noteId,
    required this.userId,
    required this.title,
    required this.description,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'title': title,
      'description': description,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  factory NoteVersion.fromMap(Map<String, dynamic> map) {
    return NoteVersion(
      id: map['id'] as String?,
      noteId: map['note_id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      savedAt: DateTime.parse(map['saved_at']),
    );
  }
}
