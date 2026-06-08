import 'zendesk_sdk_exception.dart';
import 'zendesk_sdk_error_codes.dart';

/// Validates common argument values before invoking the platform channel.
abstract final class ZendeskSdkValidator {
  static void requireNonEmpty(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw ZendeskSdkException(
        code: ZendeskSdkErrorCodes.invalidArguments,
        message: '$fieldName must not be empty',
      );
    }
  }

  static void requireInitializeArgs({
    required String url,
    required String appId,
    required String clientId,
  }) {
    requireNonEmpty(url, 'url');
    requireNonEmpty(appId, 'appId');
    requireNonEmpty(clientId, 'clientId');
  }

  static void requireChannelId(String channelId) {
    requireNonEmpty(channelId, 'channelId');
  }

  static void requirePushToken(String token) {
    requireNonEmpty(token, 'pushToken');
  }
}
