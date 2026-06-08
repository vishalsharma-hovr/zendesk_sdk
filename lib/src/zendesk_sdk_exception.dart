import 'package:flutter/services.dart';

/// A platform exception raised by the Zendesk SDK plugin.
class ZendeskSdkException implements Exception {
  const ZendeskSdkException({
    required this.code,
    required this.message,
    this.details,
  });

  factory ZendeskSdkException.fromPlatformException(
    PlatformException exception,
  ) {
    return ZendeskSdkException(
      code: exception.code,
      message: exception.message ?? 'An unknown Zendesk SDK error occurred.',
      details: exception.details,
    );
  }

  final String code;
  final String message;
  final dynamic details;

  @override
  String toString() => 'ZendeskSdkException($code): $message';
}
