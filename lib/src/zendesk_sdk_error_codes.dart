/// Shared error codes returned by native platforms via [PlatformException].
abstract final class ZendeskSdkErrorCodes {
  static const String invalidArguments = 'INVALID_ARGUMENTS';
  static const String noUiContext = 'NO_UI_CONTEXT';
  static const String notInitialized = 'NOT_INITIALIZED';
  static const String initFailed = 'INIT_FAILED';
  static const String chatInitFailed = 'CHAT_INIT_FAILED';
  static const String chatEngineFailed = 'CHAT_ENGINE_FAILED';
  static const String launchFailed = 'LAUNCH_FAILED';
  static const String answerBotError = 'ANSWERBOT_ERROR';
  static const String logoutFailed = 'LOGOUT_FAILED';
  static const String unreadCountFailed = 'UNREAD_COUNT_FAILED';
  static const String pushTokenFailed = 'PUSH_TOKEN_FAILED';
  static const String pushNotificationFailed = 'PUSH_NOTIFICATION_FAILED';
}
