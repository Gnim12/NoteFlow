import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/attachment_model.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';
import '../models/note_version_model.dart';
import '../models/reminder_model.dart';
import '../models/sync_queue_entry.dart';

class SqliteService {
  SqliteService._();

  static final SqliteService instance = SqliteService._();

  static const _uuid = Uuid();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), "noteflow.db");

    return await openDatabase(
      path,
      version: 14,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  // =====================================
  // CREATE DATABASE
  // =====================================

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL,
        category_id TEXT,
        tags TEXT,
        deleted_at TEXT,
        latitude REAL,
        longitude REAL,
        place_name TEXT,
        address TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC)',
    );

    await _createSyncQueueTable(db);
    await _createCategoriesTable(db);
    await _createAttachmentsTable(db);
    await _createRemindersTable(db);
    await _createNoteVersionsTable(db);
  }

  Future<void> _createNoteVersionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE note_versions(
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        saved_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_note_versions_note ON note_versions(note_id, saved_at DESC)',
    );
  }

  Future<void> _createRemindersTable(Database db) async {
    await db.execute('''
      CREATE TABLE reminders(
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        date_time TEXT NOT NULL,
        recurrence TEXT NOT NULL,
        custom_interval_days INTEGER,
        enabled INTEGER NOT NULL,
        notification_id INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_reminders_note ON reminders(note_id)');
    await db.execute('CREATE INDEX idx_reminders_user ON reminders(user_id)');
  }

  Future<void> _createSyncQueueTable(Database db) async {
    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        note_id TEXT,
        operation TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sync_queue_user ON sync_queue(user_id, id)',
    );
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_categories_user ON categories(user_id)',
    );
  }

  Future<void> _createAttachmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE attachments(
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        file_name TEXT NOT NULL,
        local_path TEXT NOT NULL,
        storage_path TEXT,
        download_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_attachments_note ON attachments(note_id)',
    );
  }

  // =====================================
  // DATABASE UPGRADE
  // =====================================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute("ALTER TABLE users ADD COLUMN photo TEXT");
    }

    if (oldVersion < 4) {
      await db.execute("ALTER TABLE users ADD COLUMN reset_code TEXT");
      await db.execute(
        "ALTER TABLE users ADD COLUMN reset_code_expires_at TEXT",
      );
    }

    if (oldVersion < 5) {
      // Les anciennes notes ne pouvaient pas être attribuées de façon fiable.
      // Elles restent dans la base mais ne sont exposées à aucun compte.
      await db.execute('ALTER TABLE notes ADD COLUMN user_id INTEGER');
      await db.execute(
        'CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC)',
      );
    }

    if (oldVersion < 6) {
      // Migration des identifiants INTEGER vers TEXT afin de préparer la
      // synchronisation Firestore (qui utilise des identifiants String).
      await db.execute('DROP INDEX IF EXISTS idx_notes_user_created');

      await db.execute('''
        CREATE TABLE users_new(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          photo TEXT,
          reset_code TEXT,
          reset_code_expires_at TEXT
        )
      ''');
      await db.execute('''
        INSERT INTO users_new
        SELECT CAST(id AS TEXT), name, email, password, photo, reset_code, reset_code_expires_at
        FROM users
      ''');
      await db.execute('DROP TABLE users');
      await db.execute('ALTER TABLE users_new RENAME TO users');

      await db.execute('''
        CREATE TABLE notes_new(
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          created_at TEXT NOT NULL,
          color INTEGER NOT NULL,
          is_favorite INTEGER NOT NULL,
          is_pinned INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        INSERT INTO notes_new
        SELECT CAST(id AS TEXT), CAST(user_id AS TEXT), title, description, created_at, color, is_favorite, is_pinned
        FROM notes
      ''');
      await db.execute('DROP TABLE notes');
      await db.execute('ALTER TABLE notes_new RENAME TO notes');

      await db.execute(
        'CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC)',
      );
    }

    if (oldVersion < 7) {
      // L'authentification et le profil sont désormais gérés par Firebase
      // Authentication : la table locale des comptes n'a plus lieu d'être.
      await db.execute('DROP TABLE IF EXISTS users');
    }

    if (oldVersion < 8) {
      // Nécessaire pour la synchronisation Firestore : la stratégie de
      // résolution de conflit se base sur la date de dernière modification.
      await db.execute('ALTER TABLE notes ADD COLUMN updated_at TEXT');
      await db.execute('UPDATE notes SET updated_at = created_at');
    }

    if (oldVersion < 9) {
      // File d'attente des opérations à rejouer vers Firestore lorsque la
      // connexion revient (fonctionnement hors ligne, cf. phase 4).
      await _createSyncQueueTable(db);
    }

    if (oldVersion < 10) {
      // Catégories, tags et corbeille (cf. phase 5).
      await db.execute('ALTER TABLE notes ADD COLUMN category_id TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN deleted_at TEXT');
      await _createCategoriesTable(db);
    }

    if (oldVersion < 11) {
      // Pièces jointes + Firebase Storage (cf. phase 6).
      await _createAttachmentsTable(db);
    }

    if (oldVersion < 12) {
      // Localisation associée à une note, embarquée dans le document
      // (cf. phase 7).
      await db.execute('ALTER TABLE notes ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE notes ADD COLUMN longitude REAL');
      await db.execute('ALTER TABLE notes ADD COLUMN place_name TEXT');
      await db.execute('ALTER TABLE notes ADD COLUMN address TEXT');
    }

    if (oldVersion < 13) {
      // Rappels et notifications (cf. phase 8).
      await _createRemindersTable(db);
    }

    if (oldVersion < 14) {
      // Historique des modifications (cf. phase 10).
      await _createNoteVersionsTable(db);
    }
  }

  // =====================================
  // NOTES
  // =====================================

  Future<String> insertNote(Note note) async {
    final db = await database;
    final id = note.id ?? _uuid.v4();

    await db.insert(
      "notes",
      note.copyWith(id: id).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Note>> getNotes(String userId) async {
    final db = await database;

    final result = await db.query(
      "notes",
      where: 'user_id = ? AND deleted_at IS NULL',
      whereArgs: [userId],
      orderBy: "created_at DESC",
    );

    return result.map((e) => Note.fromMap(e)).toList();
  }

  /// Contrairement à [getNotes], inclut aussi les notes de la corbeille :
  /// utilisé pour la fusion avec Firestore où l'état de suppression doit
  /// être comparé, pas seulement les notes actives.
  Future<List<Note>> getAllNotes(String userId) async {
    final db = await database;

    final result = await db.query(
      "notes",
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: "created_at DESC",
    );

    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<List<Note>> getTrashedNotes(String userId) async {
    final db = await database;

    final result = await db.query(
      "notes",
      where: 'user_id = ? AND deleted_at IS NOT NULL',
      whereArgs: [userId],
      orderBy: "deleted_at DESC",
    );

    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;

    return await db.update(
      "notes",
      note.toMap(),
      where: "id = ? AND user_id = ?",
      whereArgs: [note.id, note.userId],
    );
  }

  Future<int> deleteNote({required String id, required String userId}) async {
    final db = await database;

    return await db.delete(
      "notes",
      where: "id = ? AND user_id = ?",
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteAllNotes(String userId) async {
    final db = await database;

    return await db.delete("notes", where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<Note?> getNoteById(String id, String userId) async {
    final db = await database;

    final result = await db.query(
      "notes",
      where: "id = ? AND user_id = ?",
      whereArgs: [id, userId],
    );

    if (result.isEmpty) return null;

    return Note.fromMap(result.first);
  }

  // =====================================
  // FILE DE SYNCHRONISATION
  // =====================================

  Future<void> enqueueSync({
    required String userId,
    String? noteId,
    required SyncOperation operation,
  }) async {
    final db = await database;

    await db.insert("sync_queue", {
      "user_id": userId,
      "note_id": noteId,
      "operation": operation.name,
      "created_at": DateTime.now().toIso8601String(),
    });
  }

  Future<List<SyncQueueEntry>> getSyncQueue(String userId) async {
    final db = await database;

    final result = await db.query(
      "sync_queue",
      where: "user_id = ?",
      whereArgs: [userId],
      orderBy: "id ASC",
    );

    return result.map((e) => SyncQueueEntry.fromMap(e)).toList();
  }

  Future<int> getSyncQueueCount(String userId) async {
    final db = await database;

    final result = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM sync_queue WHERE user_id = ?",
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> removeSyncQueueEntry(int id) async {
    final db = await database;

    await db.delete("sync_queue", where: "id = ?", whereArgs: [id]);
  }

  // =====================================
  // CATÉGORIES
  // =====================================

  Future<String> insertCategory(Category category) async {
    final db = await database;
    final id = category.id ?? _uuid.v4();

    await db.insert(
      "categories",
      category.copyWith(id: id).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Category>> getCategories(String userId) async {
    final db = await database;

    final result = await db.query(
      "categories",
      where: "user_id = ?",
      whereArgs: [userId],
      orderBy: "name ASC",
    );

    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;

    return await db.update(
      "categories",
      category.toMap(),
      where: "id = ? AND user_id = ?",
      whereArgs: [category.id, category.userId],
    );
  }

  Future<int> deleteCategory({required String id, required String userId}) async {
    final db = await database;

    // Les notes de cette catégorie redeviennent "Sans catégorie" plutôt que
    // de pointer vers une catégorie supprimée.
    await db.update(
      "notes",
      {"category_id": null},
      where: "category_id = ? AND user_id = ?",
      whereArgs: [id, userId],
    );

    return await db.delete(
      "categories",
      where: "id = ? AND user_id = ?",
      whereArgs: [id, userId],
    );
  }

  // =====================================
  // PIÈCES JOINTES
  // =====================================

  Future<String> insertAttachment(Attachment attachment) async {
    final db = await database;
    final id = attachment.id ?? _uuid.v4();

    await db.insert(
      "attachments",
      Attachment(
        id: id,
        noteId: attachment.noteId,
        userId: attachment.userId,
        type: attachment.type,
        fileName: attachment.fileName,
        localPath: attachment.localPath,
        storagePath: attachment.storagePath,
        downloadUrl: attachment.downloadUrl,
        createdAt: attachment.createdAt,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Attachment>> getAttachments(String noteId) async {
    final db = await database;

    final result = await db.query(
      "attachments",
      where: "note_id = ?",
      whereArgs: [noteId],
      orderBy: "created_at ASC",
    );

    return result.map((e) => Attachment.fromMap(e)).toList();
  }

  Future<Attachment?> getAttachmentById(String id) async {
    final db = await database;

    final result = await db.query(
      "attachments",
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return Attachment.fromMap(result.first);
  }

  Future<int> updateAttachment(Attachment attachment) async {
    final db = await database;

    return await db.update(
      "attachments",
      attachment.toMap(),
      where: "id = ?",
      whereArgs: [attachment.id],
    );
  }

  Future<int> deleteAttachment(String id) async {
    final db = await database;

    return await db.delete("attachments", where: "id = ?", whereArgs: [id]);
  }

  // =====================================
  // RAPPELS
  // =====================================

  Future<String> insertReminder(Reminder reminder) async {
    final db = await database;
    final id = reminder.id ?? _uuid.v4();

    await db.insert(
      "reminders",
      Reminder(
        id: id,
        noteId: reminder.noteId,
        userId: reminder.userId,
        dateTime: reminder.dateTime,
        recurrence: reminder.recurrence,
        customIntervalDays: reminder.customIntervalDays,
        enabled: reminder.enabled,
        notificationId: reminder.notificationId,
        createdAt: reminder.createdAt,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  Future<List<Reminder>> getReminders(String noteId) async {
    final db = await database;

    final result = await db.query(
      "reminders",
      where: "note_id = ?",
      whereArgs: [noteId],
      orderBy: "date_time ASC",
    );

    return result.map((e) => Reminder.fromMap(e)).toList();
  }

  Future<List<Reminder>> getAllReminders(String userId) async {
    final db = await database;

    final result = await db.query(
      "reminders",
      where: "user_id = ?",
      whereArgs: [userId],
      orderBy: "date_time ASC",
    );

    return result.map((e) => Reminder.fromMap(e)).toList();
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;

    return await db.update(
      "reminders",
      reminder.toMap(),
      where: "id = ?",
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(String id) async {
    final db = await database;

    return await db.delete("reminders", where: "id = ?", whereArgs: [id]);
  }

  // =====================================
  // HISTORIQUE DES MODIFICATIONS
  // =====================================

  Future<void> insertNoteVersion(NoteVersion version) async {
    final db = await database;

    await db.insert("note_versions", {
      ...version.toMap(),
      "id": version.id ?? _uuid.v4(),
    });
  }

  Future<List<NoteVersion>> getNoteVersions(String noteId) async {
    final db = await database;

    final result = await db.query(
      "note_versions",
      where: "note_id = ?",
      whereArgs: [noteId],
      orderBy: "saved_at DESC",
    );

    return result.map((e) => NoteVersion.fromMap(e)).toList();
  }

  /// Ne conserve que les [keep] versions les plus récentes d'une note, pour
  /// éviter une croissance illimitée de l'historique.
  Future<void> trimNoteVersions(String noteId, {int keep = 20}) async {
    final db = await database;

    final ids = await db.query(
      "note_versions",
      columns: ["id"],
      where: "note_id = ?",
      whereArgs: [noteId],
      orderBy: "saved_at DESC",
      offset: keep,
    );

    if (ids.isEmpty) return;

    final idsToDelete = ids.map((row) => row["id"]).toList();
    await db.delete(
      "note_versions",
      where: "id IN (${idsToDelete.map((_) => '?').join(',')})",
      whereArgs: idsToDelete,
    );
  }

  Future<void> deleteNoteVersions(String noteId) async {
    final db = await database;

    await db.delete("note_versions", where: "note_id = ?", whereArgs: [noteId]);
  }
}
