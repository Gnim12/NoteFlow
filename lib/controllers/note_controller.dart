import 'package:diacritic/diacritic.dart';

import '../models/note_model.dart';
import '../services/sqlite_service.dart';

class NoteController {
  NoteController._();

  static final NoteController instance = NoteController._();
  final SqliteService _service = SqliteService.instance;

  Future<List<Note>> getNotes(String userId) => _service.getNotes(userId);

  Future<String> createNote(Note note) => _service.insertNote(note);

  Future<int> updateNote(Note note) => _service.updateNote(note);

  Future<int> deleteNote({required String id, required String userId}) {
    return _service.deleteNote(id: id, userId: userId);
  }

  Future<int> deleteAllNotes(String userId) => _service.deleteAllNotes(userId);

  Future<int> toggleFavorite(Note note) {
    return _service.updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  Future<int> togglePin(Note note) {
    return _service.updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  /// Épinglées d'abord, puis les plus récentes.
  List<Note> sortPinnedFirst(List<Note> notes) {
    final sorted = List<Note>.from(notes);
    sorted.sort((a, b) {
      if (a.isPinned == b.isPinned) {
        return b.createdAt.compareTo(a.createdAt);
      }
      return a.isPinned ? -1 : 1;
    });
    return sorted;
  }

  List<Note> search(List<Note> notes, String query) {
    final search = removeDiacritics(query.toLowerCase().trim());

    if (search.isEmpty) {
      return List.from(notes);
    }

    return notes.where((note) {
      final title = removeDiacritics(note.title.toLowerCase());
      final description = removeDiacritics(note.description.toLowerCase());
      return title.contains(search) || description.contains(search);
    }).toList();
  }

  List<Note> sort(List<Note> notes, String sortType) {
    final sorted = List<Note>.from(notes);

    switch (sortType) {
      case "recent":
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case "old":
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case "title":
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case "favorite":
        sorted.sort(
          (a, b) => b.isFavorite.toString().compareTo(a.isFavorite.toString()),
        );
        break;
      case "color":
        sorted.sort((a, b) => a.color.compareTo(b.color));
        break;
    }

    return sorted;
  }

  List<Note> favoritesOnly(List<Note> notes) {
    return notes.where((e) => e.isFavorite).toList();
  }

  List<Note> pinnedOnly(List<Note> notes) {
    return notes.where((e) => e.isPinned).toList();
  }

  List<Note> createdToday(List<Note> notes) {
    final now = DateTime.now();
    return notes.where((note) {
      return note.createdAt.year == now.year &&
          note.createdAt.month == now.month &&
          note.createdAt.day == now.day;
    }).toList();
  }
}
