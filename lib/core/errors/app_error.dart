import 'package:flutter/foundation.dart';

enum ErrorKind { validation, auth, persistence, unexpected }

class AppError {
  final ErrorKind kind;
  final String message;
  final String? debugMessage;
  final Object? cause;

  const AppError({
    required this.kind,
    required this.message,
    this.debugMessage,
    this.cause,
  });

  factory AppError.validation(String message, [Object? cause]) {
    return AppError(kind: ErrorKind.validation, message: message, cause: cause);
  }

  factory AppError.auth(String message, [Object? cause]) {
    return AppError(kind: ErrorKind.auth, message: message, cause: cause);
  }

  factory AppError.persistence(String message, [Object? cause]) {
    return AppError(
      kind: ErrorKind.persistence,
      message: message,
      cause: cause,
    );
  }

  factory AppError.unexpected([Object? cause, String? debugMessage]) {
    return AppError(
      kind: ErrorKind.unexpected,
      message: 'Une erreur inattendue s’est produite.',
      debugMessage: debugMessage,
      cause: cause,
    );
  }

  factory AppError.fromException(Object exception, {String? fallback}) {
    return AppError.persistence(
      fallback ?? 'Impossible d’effectuer cette action.',
      exception,
    );
  }

  void logDebug() {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[$kind] $message');

    if (debugMessage != null) {
      debugPrint('Debug: $debugMessage');
    }

    if (cause != null) {
      debugPrint('Cause: $cause');
    }
  }
}
