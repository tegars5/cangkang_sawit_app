/// Result type untuk menangani operasi yang bisa sukses atau gagal
/// Menggunakan sealed class untuk exhaustive pattern matching
sealed class Result<T> {
  const Result();

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Get exception if failure, null otherwise
  Exception? get exceptionOrNull =>
      isFailure ? (this as Failure<T>).exception : null;

  /// Pattern matching untuk handle success dan failure
  R when<R>({
    required R Function(T data) success,
    required R Function(Exception exception) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as Failure<T>).exception);
    }
  }

  /// Transform data jika success
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure(Exception('Transform error: $e'));
      }
    } else {
      return Failure((this as Failure<T>).exception);
    }
  }

  /// Transform exception jika failure
  Result<T> mapError(Exception Function(Exception exception) transform) {
    if (this is Failure<T>) {
      return Failure(transform((this as Failure<T>).exception));
    } else {
      return this;
    }
  }

  /// Get data atau throw exception
  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      throw (this as Failure<T>).exception;
    }
  }

  /// Get data atau return default value
  T getOrDefault(T defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      return defaultValue;
    }
  }

  /// Get data atau return result dari function
  T getOrElse(T Function() defaultValue) {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      return defaultValue();
    }
  }
}

/// Success result dengan data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Failure result dengan exception
class Failure<T> extends Result<T> {
  final Exception exception;

  const Failure(this.exception);

  @override
  String toString() => 'Failure(exception: $exception)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.exception == exception;
  }

  @override
  int get hashCode => exception.hashCode;
}
