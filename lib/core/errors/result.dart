import 'app_error.dart';

class Result<T> {
  final T? value;
  final AppError? error;

  const Result._({this.value, this.error});

  factory Result.success(T value) {
    return Result._(value: value);
  }

  factory Result.failure(AppError error) {
    return Result._(error: error);
  }

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
