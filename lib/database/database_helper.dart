import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

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
      version: 5,
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
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

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        photo TEXT,
        reset_code TEXT,
        reset_code_expires_at TEXT
      )
    ''');
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
  }

  // =====================================
  // NOTES
  // =====================================

  Future<int> insertNote(Note note) async {
    final db = await database;

    return await db.insert(
      "notes",
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes(int userId) async {
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

  Future<int> deleteNote({required int id, required int userId}) async {
    final db = await database;

    return await db.delete(
      "notes",
      where: "id = ? AND user_id = ?",
      whereArgs: [id, userId],
    );
  }

  Future<int> deleteAllNotes(int userId) async {
    final db = await database;

    return await db.delete("notes", where: 'user_id = ?', whereArgs: [userId]);
  }

  // =====================================
  // USERS
  // =====================================

  Future<int> insertUser(User user) async {
    final db = await database;

    return await db.insert(
      "users",
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<User?> authenticateUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<List<User>> getUsers() async {
    final db = await database;

    final result = await db.query("users", orderBy: "name ASC");

    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await database;

    final result = await db.query("users", where: "id = ?", whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
  }

  Future<int> updateResetCode({
    required int userId,
    required String? resetCode,
    required DateTime? expiresAt,
  }) async {
    final db = await database;

    return await db.update(
      "users",
      {
        "reset_code": resetCode,
        "reset_code_expires_at": expiresAt?.toIso8601String(),
      },
      where: "id = ?",
      whereArgs: [userId],
    );
  }

  Future<int> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    final db = await database;

    return await db.update(
      "users",
      {
        "password": newPassword,
        "reset_code": null,
        "reset_code_expires_at": null,
      },
      where: "id = ?",
      whereArgs: [userId],
    );
  }

  Future<int> updateUser(User user) async {
    final db = await database;

    return await db.update(
      "users",
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;

    return await db.delete("users", where: "id = ?", whereArgs: [id]);
  }
}
