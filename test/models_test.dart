import 'package:flutter_test/flutter_test.dart';
import 'package:noteflow/models/location_model.dart';
import 'package:noteflow/models/note_model.dart';
import 'package:noteflow/models/note_version_model.dart';
import 'package:noteflow/models/reminder_model.dart';
import 'package:noteflow/models/shared_note_model.dart';

void main() {
  group('Note serialization', () {
    Note buildNote() {
      final now = DateTime.utc(2026, 9, 1, 10, 30);
      return Note(
        id: 'note-1',
        userId: 'user-1',
        title: 'Courses',
        description: 'Lait, pain, œufs',
        createdAt: now,
        updatedAt: now,
        categoryId: 'cat-1',
        tags: const ['urgent', 'maison'],
        location: const NoteLocation(
          latitude: 48.8566,
          longitude: 2.3522,
          placeName: 'Paris',
          address: 'Paris, France',
        ),
      );
    }

    test('round-trips tags, category and location through toMap/fromMap', () {
      final note = buildNote();
      final restored = Note.fromMap(note.toMap());

      expect(restored.tags, ['urgent', 'maison']);
      expect(restored.categoryId, 'cat-1');
      expect(restored.location?.latitude, 48.8566);
      expect(restored.location?.longitude, 2.3522);
      expect(restored.location?.placeName, 'Paris');
      expect(restored.isInTrash, isFalse);
    });

    test('copyWithDeletedAt moves a note in and out of the trash', () {
      final note = buildNote();
      final trashed = note.copyWithDeletedAt(DateTime.utc(2026, 9, 2));

      expect(trashed.isInTrash, isTrue);

      final restored = trashed.copyWithDeletedAt(null);
      expect(restored.isInTrash, isFalse);
    });

    test('copyWithLocation can clear a previously set location', () {
      final note = buildNote();
      expect(note.location, isNotNull);

      final cleared = note.copyWithLocation(null);
      expect(cleared.location, isNull);
    });

    test('copyWith does not touch deletedAt or location', () {
      final trashed = buildNote().copyWithDeletedAt(DateTime.utc(2026, 9, 2));
      final updated = trashed.copyWith(title: 'Courses (modifié)');

      expect(updated.isInTrash, isTrue);
      expect(updated.location, isNotNull);
    });
  });

  group('NoteVersion serialization', () {
    test('round-trips through toMap/fromMap', () {
      final version = NoteVersion(
        id: 'v1',
        noteId: 'note-1',
        userId: 'user-1',
        title: 'Ancien titre',
        description: 'Ancien contenu',
        savedAt: DateTime.utc(2026, 8, 1, 9),
      );

      final restored = NoteVersion.fromMap(version.toMap());

      expect(restored.title, 'Ancien titre');
      expect(restored.noteId, 'note-1');
      expect(restored.savedAt, DateTime.utc(2026, 8, 1, 9));
    });
  });

  group('Reminder recurrence', () {
    Reminder buildReminder(RecurrenceType type, {int? interval}) {
      return Reminder(
        noteId: 'note-1',
        userId: 'user-1',
        dateTime: DateTime.utc(2026, 9, 1, 8),
        recurrence: type,
        customIntervalDays: interval,
        notificationId: 42,
        createdAt: DateTime.utc(2026, 9, 1),
      );
    }

    test('labels each recurrence type in French', () {
      expect(buildReminder(RecurrenceType.none).recurrenceLabel, 'Ponctuel');
      expect(buildReminder(RecurrenceType.daily).recurrenceLabel, 'Quotidien');
      expect(
        buildReminder(RecurrenceType.weekly).recurrenceLabel,
        'Hebdomadaire',
      );
      expect(buildReminder(RecurrenceType.monthly).recurrenceLabel, 'Mensuel');
    });

    test('custom recurrence includes the interval in days', () {
      final reminder = buildReminder(RecurrenceType.custom, interval: 3);
      expect(reminder.recurrenceLabel, 'Tous les 3 jours');
    });

    test('copyWith only overrides the provided fields', () {
      final reminder = buildReminder(RecurrenceType.daily);
      final disabled = reminder.copyWith(enabled: false);

      expect(disabled.enabled, isFalse);
      expect(disabled.recurrence, RecurrenceType.daily);
      expect(disabled.notificationId, reminder.notificationId);
    });
  });

  group('SharedNote', () {
    test('idFor combines noteId and recipient uid deterministically', () {
      final id = SharedNote.idFor(noteId: 'note-1', sharedWithUid: 'uid-2');
      expect(id, 'note-1_uid-2');
    });

    test('round-trips through toMap/fromMap', () {
      final share = SharedNote(
        id: 'note-1_uid-2',
        noteId: 'note-1',
        ownerId: 'uid-1',
        ownerEmail: 'owner@example.com',
        sharedWithUid: 'uid-2',
        sharedWithEmail: 'friend@example.com',
        permission: SharePermission.write,
        createdAt: DateTime.utc(2026, 9, 1),
      );

      final restored = SharedNote.fromMap(share.id, share.toMap());

      expect(restored.permission, SharePermission.write);
      expect(restored.sharedWithEmail, 'friend@example.com');
      expect(restored.ownerId, 'uid-1');
    });
  });
}
