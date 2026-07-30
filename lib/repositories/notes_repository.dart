import '../database/database_helper.dart';
import '../models/note.dart';

class NotesRepository {
  NotesRepository._();

  static final NotesRepository instance = NotesRepository._();

  Future<List<Note>> getNotes(int userId) async {
    return DatabaseHelper.instance.getNotes(userId);
  }

  Future<int> insertNote(Note note) async {
    return DatabaseHelper.instance.insertNote(note);
  }

  Future<int> updateNote(Note note) async {
    return DatabaseHelper.instance.updateNote(note);
  }

  Future<int> deleteNote({required int id, required int userId}) async {
    return DatabaseHelper.instance.deleteNote(id: id, userId: userId);
  }

  Future<int> deleteAllNotes(int userId) async {
    return DatabaseHelper.instance.deleteAllNotes(userId);
  }
}
