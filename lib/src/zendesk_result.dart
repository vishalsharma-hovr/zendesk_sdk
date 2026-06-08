import 'zendesk_sdk_exception.dart';

/// Algebraic result type for explicit success/failure (Dart 3 sealed classes).
sealed class ZendeskResult<T> {
  const ZendeskResult();

  bool get isSuccess => this is ZendeskSuccess<T>;
  bool get isFailure => this is ZendeskFailure<T>;

  T get valueOrThrow {
    return switch (this) {
      ZendeskSuccess<T>(:final value) => value as T,
      ZendeskFailure<T>(:final error) => throw error,
    };
  }
}

/// Successful operation with optional [value].
final class ZendeskSuccess<T> extends ZendeskResult<T> {
  const ZendeskSuccess([this.value]);

  final T? value;
}

/// Failed operation carrying a typed [ZendeskSdkException].
final class ZendeskFailure<T> extends ZendeskResult<T> {
  const ZendeskFailure(this.error);

  final ZendeskSdkException error;
}
