import 'package:flutter/services.dart';

/// A platform exception raised by the Zendesk SDK plugin.
class ZendeskSdkException implements Exception {
  /// Creates a typed Zendesk SDK exception.
  const ZendeskSdkException({
    required this.code,
    required this.message,
    this.details,
  });

  /// Converts a [PlatformException] from the method channel.
  factory ZendeskSdkException.fromPlatformException(
    PlatformException exception,
  ) {
    return ZendeskSdkException(
      code: exception.code,
      message: exception.message ?? 'An unknown Zendesk SDK error occurred.',
      details: exception.details,
    );
  }

  /// Machine-readable error code. See [ZendeskSdkErrorCodes].
  final String code;

  /// Human-readable error description.
  final String message;

  /// Optional native error details.
  final dynamic details;

  @override
  String toString() => 'ZendeskSdkException($code): $message';
}
