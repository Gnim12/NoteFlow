enum SyncOperation { upsert, delete, deleteAll }

class SyncQueueEntry {
  final int id;
  final String userId;
  final String? noteId;
  final SyncOperation operation;
  final DateTime createdAt;

  const SyncQueueEntry({
    required this.id,
    required this.userId,
    required this.noteId,
    required this.operation,
    required this.createdAt,
  });

  factory SyncQueueEntry.fromMap(Map<String, dynamic> map) {
    return SyncQueueEntry(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      noteId: map['note_id'] as String?,
      operation: SyncOperation.values.byName(map['operation'] as String),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
