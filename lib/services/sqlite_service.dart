import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/note_model.dart';

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
      version: 7,
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
        color INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_notes_user_created ON notes(user_id, created_at DESC)',
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
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: "created_at DESC",
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
}
