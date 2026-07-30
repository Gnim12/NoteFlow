import 'package:flutter/material.dart';

import 'app_error.dart';

class ErrorPresenter {
  static void showError(BuildContext context, AppError error) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _colorFor(error.kind),
        content: Text(error.message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Color _colorFor(ErrorKind kind) {
    switch (kind) {
      case ErrorKind.validation:
        return Colors.orange.shade700;
      case ErrorKind.auth:
        return Colors.red.shade700;
      case ErrorKind.persistence:
        return Colors.blue.shade700;
      case ErrorKind.unexpected:
        return Colors.deepPurple.shade700;
    }
  }
}
