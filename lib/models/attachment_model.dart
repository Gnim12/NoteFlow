enum AttachmentType { image, file }

class Attachment {
  final String? id;
  final String noteId;
  final String userId;
  final AttachmentType type;
  final String fileName;
  final String localPath;
  final String? storagePath;
  final String? downloadUrl;
  final DateTime createdAt;

  const Attachment({
    this.id,
    required this.noteId,
    required this.userId,
    required this.type,
    required this.fileName,
    required this.localPath,
    this.storagePath,
    this.downloadUrl,
    required this.createdAt,
  });

  bool get isUploaded => downloadUrl != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'type': type.name,
      'file_name': fileName,
      'local_path': localPath,
      'storage_path': storagePath,
      'download_url': downloadUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as String?,
      noteId: map['note_id'] as String,
      userId: map['user_id'] as String,
      type: AttachmentType.values.byName(map['type'] as String),
      fileName: map['file_name'] as String,
      localPath: map['local_path'] as String,
      storagePath: map['storage_path'] as String?,
      downloadUrl: map['download_url'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Métadonnées envoyées à Firestore : sans le chemin local, propre à
  /// l'appareil, une fois le fichier effectivement hébergé sur Storage.
  Map<String, dynamic> toCloudMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'type': type.name,
      'file_name': fileName,
      'storage_path': storagePath,
      'download_url': downloadUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Attachment copyWith({String? storagePath, String? downloadUrl}) {
    return Attachment(
      id: id,
      noteId: noteId,
      userId: userId,
      type: type,
      fileName: fileName,
      localPath: localPath,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      createdAt: createdAt,
    );
  }
}
