import 'package:diacritic/diacritic.dart';
import 'package:uuid/uuid.dart';

import '../models/note_model.dart';
import '../models/note_version_model.dart';
import '../services/firestore_service.dart';
import '../services/sqlite_service.dart';
import '../services/sync_service.dart';

class NoteController {
  NoteController._();

  static final NoteController instance = NoteController._();
  final SqliteService _service = SqliteService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final SyncService _syncService = SyncService.instance;

  static const _uuid = Uuid();

  Future<List<Note>> getNotes(String userId) => _service.getNotes(userId);

  Future<Note?> getNoteById(String id, String userId) {
    return _service.getNoteById(id, userId);
  }

  Future<String> createNote(Note note) async {
    final withId = note.copyWith(id: note.id ?? _uuid.v4());

    await _service.insertNote(withId);
    await _syncService.enqueueUpsert(userId: withId.userId, noteId: withId.id!);

    return withId.id!;
  }

  Future<int> updateNote(Note note) async {
    await _snapshotVersionIfContentChanged(note);

    final updated = note.copyWith(updatedAt: DateTime.now());

    final rows = await _service.updateNote(updated);
    await _syncService.enqueueUpsert(userId: updated.userId, noteId: updated.id!);

    return rows;
  }

  /// Sauvegarde l'état précédent du titre/contenu avant d'appliquer une
  /// modification, pour permettre de consulter l'historique et restaurer une
  /// version antérieure (cahier des charges §5.1). Ignore les mises à jour
  /// qui ne touchent ni le titre ni la description (ex. épingler, changer de
  /// catégorie) pour ne pas polluer l'historique.
  Future<void> _snapshotVersionIfContentChanged(Note newState) async {
    final previous = await _service.getNoteById(newState.id!, newState.userId);
    if (previous == null) return;

    if (previous.title == newState.title &&
        previous.description == newState.description) {
      return;
    }

    final version = NoteVersion(
      id: _uuid.v4(),
      noteId: previous.id!,
      userId: previous.userId,
      title: previous.title,
      description: previous.description,
      savedAt: DateTime.now(),
    );

    await _service.insertNoteVersion(version);
    await _service.trimNoteVersions(previous.id!);
    _firestoreService.setNoteVersion(version).catchError((_) {});
  }

  Future<List<NoteVersion>> getVersions(String noteId) {
    return _service.getNoteVersions(noteId);
  }

  Future<int> deleteNote({required String id, required String userId}) async {
    final rows = await _service.deleteNote(id: id, userId: userId);
    await _service.deleteNoteVersions(id);
    await _syncService.enqueueDelete(userId: userId, noteId: id);

    return rows;
  }

  Future<int> deleteAllNotes(String userId) async {
    final rows = await _service.deleteAllNotes(userId);
    await _syncService.enqueueDeleteAll(userId);

    return rows;
  }

  // =====================================
  // CORBEILLE
  // =====================================

  Future<List<Note>> getTrashedNotes(String userId) {
    return _service.getTrashedNotes(userId);
  }

  Future<int> moveToTrash(Note note) async {
    final trashed = note
        .copyWith(updatedAt: DateTime.now())
        .copyWithDeletedAt(DateTime.now());

    final rows = await _service.updateNote(trashed);
    await _syncService.enqueueUpsert(userId: trashed.userId, noteId: trashed.id!);

    return rows;
  }

  Future<int> restoreFromTrash(Note note) async {
    final restored = note
        .copyWith(updatedAt: DateTime.now())
        .copyWithDeletedAt(null);

    final rows = await _service.updateNote(restored);
    await _syncService.enqueueUpsert(userId: restored.userId, noteId: restored.id!);

    return rows;
  }

  Future<int> deleteNotePermanently(Note note) {
    return deleteNote(id: note.id!, userId: note.userId);
  }

  Future<void> emptyTrash(String userId) async {
    final trashed = await getTrashedNotes(userId);

    for (final note in trashed) {
      await deleteNotePermanently(note);
    }
  }

  Future<int> toggleFavorite(Note note) {
    return updateNote(note.copyWith(isFavorite: !note.isFavorite));
  }

  Future<int> togglePin(Note note) {
    return updateNote(note.copyWith(isPinned: !note.isPinned));
  }

  Future<int> pendingSyncCount(String userId) {
    return _syncService.pendingCount(userId);
  }

  /// Récupère les notes de Firestore et les fusionne dans SQLite : utile au
  /// premier lancement sur un nouvel appareil, ou après une réinstallation.
  /// Ne remplace une note locale que si la version distante est plus récente.
  Future<void> syncFromCloud(String userId) async {
    try {
      // Pousse d'abord les opérations en attente pour ne pas laisser le
      // pull ci-dessous ressusciter une note supprimée hors ligne.
      await _syncService.flush(userId);

      final cloudNotes = await _firestoreService.getNotes(userId);
      final localNotes = await _service.getAllNotes(userId);
      final localById = {for (final note in localNotes) note.id: note};

      for (final cloudNote in cloudNotes) {
        final localNote = localById[cloudNote.id];

        if (localNote == null ||
            cloudNote.updatedAt.isAfter(localNote.updatedAt)) {
          await _service.insertNote(cloudNote);
        }
      }
    } catch (_) {
      // Pas de connexion : on continue avec les données locales.
    }
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
      final tags = note.tags.map((t) => removeDiacritics(t.toLowerCase()));

      return title.contains(search) ||
          description.contains(search) ||
          tags.any((tag) => tag.contains(search));
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
      case "modified":
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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

  List<Note> filterByCategory(List<Note> notes, String? categoryId) {
    if (categoryId == null) return List.from(notes);
    return notes.where((note) => note.categoryId == categoryId).toList();
  }

  List<Note> filterByTag(List<Note> notes, String tag) {
    return notes.where((note) => note.tags.contains(tag)).toList();
  }

  List<String> allTags(List<Note> notes) {
    final tags = <String>{};
    for (final note in notes) {
      tags.addAll(note.tags);
    }
    final sorted = tags.toList()..sort();
    return sorted;
  }
}
