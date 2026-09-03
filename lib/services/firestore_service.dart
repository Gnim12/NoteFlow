import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attachment_model.dart';
import '../models/category_model.dart';
import '../models/note_model.dart';
import '../models/note_version_model.dart';
import '../models/reminder_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notesCollection(String userId) {
    return _db.collection('users').doc(userId).collection('notes');
  }

  CollectionReference<Map<String, dynamic>> _categoriesCollection(
    String userId,
  ) {
    return _db.collection('users').doc(userId).collection('categories');
  }

  CollectionReference<Map<String, dynamic>> _attachmentsCollection(
    String userId,
    String noteId,
  ) {
    return _notesCollection(
      userId,
    ).doc(noteId).collection('attachments');
  }

  CollectionReference<Map<String, dynamic>> _remindersCollection(
    String userId,
    String noteId,
  ) {
    return _notesCollection(userId).doc(noteId).collection('reminders');
  }

  CollectionReference<Map<String, dynamic>> _versionsCollection(
    String userId,
    String noteId,
  ) {
    return _notesCollection(userId).doc(noteId).collection('versions');
  }

  Future<void> setNote(Note note) {
    return _notesCollection(note.userId).doc(note.id).set(note.toMap());
  }

  Future<Note?> getNote({required String userId, required String noteId}) async {
    final doc = await _notesCollection(userId).doc(noteId).get();
    if (!doc.exists) return null;

    return Note.fromMap(doc.data()!);
  }

  Future<List<Note>> getNotes(String userId) async {
    final snapshot = await _notesCollection(userId).get();
    return snapshot.docs.map((doc) => Note.fromMap(doc.data())).toList();
  }

  Future<void> deleteNote({required String userId, required String noteId}) {
    return _notesCollection(userId).doc(noteId).delete();
  }

  Future<void> deleteAllNotes(String userId) async {
    final snapshot = await _notesCollection(userId).get();
    final batch = _db.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> setCategory(Category category) {
    return _categoriesCollection(
      category.userId,
    ).doc(category.id).set(category.toMap());
  }

  Future<List<Category>> getCategories(String userId) async {
    final snapshot = await _categoriesCollection(userId).get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<void> deleteCategory({
    required String userId,
    required String categoryId,
  }) {
    return _categoriesCollection(userId).doc(categoryId).delete();
  }

  Future<void> setAttachment(Attachment attachment) {
    return _attachmentsCollection(attachment.userId, attachment.noteId)
        .doc(attachment.id)
        .set(attachment.toCloudMap());
  }

  Future<void> deleteAttachment({
    required String userId,
    required String noteId,
    required String attachmentId,
  }) {
    return _attachmentsCollection(userId, noteId).doc(attachmentId).delete();
  }

  Future<void> setReminder(Reminder reminder) {
    return _remindersCollection(reminder.userId, reminder.noteId)
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<void> deleteReminder({
    required String userId,
    required String noteId,
    required String reminderId,
  }) {
    return _remindersCollection(userId, noteId).doc(reminderId).delete();
  }

  Future<void> setNoteVersion(NoteVersion version) {
    return _versionsCollection(version.userId, version.noteId)
        .doc(version.id)
        .set(version.toMap());
  }
}
