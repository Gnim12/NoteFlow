import 'package:flutter_test/flutter_test.dart';
import 'package:noteflow/core/errors/app_error.dart';
import 'package:noteflow/core/errors/result.dart';
import 'package:noteflow/models/note_model.dart';

void main() {
  group('App error handling', () {
    test('Result.failure exposes the error and marks the result as failed', () {
      final error = AppError.validation('Veuillez remplir tous les champs.');
      final result = Result<void>.failure(error);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.error, same(error));
    });

    test(
      'AppError.validation creates a validation error with the expected message',
      () {
        final error = AppError.validation('Adresse email invalide.');

        expect(error.kind, ErrorKind.validation);
        expect(error.message, 'Adresse email invalide.');
      },
    );
  });

  group('Note ownership', () {
    test('serializes and restores the note owner', () {
      final note = Note(
        id: '12',
        userId: '7',
        title: 'Note privée',
        description: 'Visible uniquement par son propriétaire.',
        createdAt: DateTime.utc(2026, 7, 30),
      );

      final restored = Note.fromMap(note.toMap());

      expect(restored.userId, '7');
      expect(restored.id, '12');
    });

    test('copyWith preserves the note owner', () {
      final note = Note(
        userId: '7',
        title: 'Initiale',
        description: 'Contenu',
        createdAt: DateTime.utc(2026, 7, 30),
      );

      expect(note.copyWith(title: 'Modifiée').userId, '7');
    });
  });
}
