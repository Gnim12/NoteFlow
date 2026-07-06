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
    final path = join(
      await getDatabasesPath(),
      "noteflow.db",
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  // =====================================
  // CREATE DATABASE
  // =====================================

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL,
        is_pinned INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        photo TEXT
      )
    ''');
  }

  // =====================================
  // DATABASE UPGRADE
  // =====================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
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
      await db.execute(
        "ALTER TABLE users ADD COLUMN photo TEXT",
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

  Future<List<Note>> getNotes() async {
    final db = await database;

    final result = await db.query(
      "notes",
      orderBy: "created_at DESC",
    );

    return result
        .map((e) => Note.fromMap(e))
        .toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;

    return await db.update(
      "notes",
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;

    return await db.delete(
      "notes",
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> deleteAllNotes() async {
    final db = await database;

    return await db.delete("notes");
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

  Future<User?> authenticateUser(
    String email,
    String password,
  ) async {
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

    final result = await db.query(
      "users",
      orderBy: "name ASC",
    );

    return result
        .map((e) => User.fromMap(e))
        .toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "id = ?",
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return User.fromMap(result.first);
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

    return await db.delete(
      "users",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}