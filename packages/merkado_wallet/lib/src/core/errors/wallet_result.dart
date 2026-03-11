/// Result<T> — Generic sealed result wrapper.
///
/// Mirrors the same pattern used in merkado_auth to maintain consistency
/// across the Merkado OS package ecosystem.
sealed class WalletResult<T> {
  const WalletResult();

  factory WalletResult.success(T value) = _Success<T>;
  factory WalletResult.failure(String message, [Exception? exception]) = _Failure<T>;

  bool get isSuccess => this is _Success<T>;
  bool get isFailure => this is _Failure<T>;

  T? get valueOrNull => switch (this) {
    _Success<T>(:final value) => value,
    _Failure<T>() => null,
  };

  String? get errorOrNull => switch (this) {
    _Success<T>() => null,
    _Failure<T>(:final message) => message,
  };

  void when({
    required void Function(T value) success,
    required void Function(String error, Exception? exception) failure,
  }) {
    switch (this) {
      case _Success<T>(:final value):
        success(value);
      case _Failure<T>(:final message, :final exception):
        failure(message, exception);
    }
  }

  R map<R>({
    required R Function(T value) success,
    required R Function(String error, Exception? exception) failure,
  }) {
    return switch (this) {
      _Success<T>(:final value) => success(value),
      _Failure<T>(:final message, :final exception) => failure(message, exception),
    };
  }
}

final class _Success<T> extends WalletResult<T> {
  final T value;
  const _Success(this.value);
}

final class _Failure<T> extends WalletResult<T> {
  final String message;
  final Exception? exception;
  const _Failure(this.message, [this.exception]);
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;
}