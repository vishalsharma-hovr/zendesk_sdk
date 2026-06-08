export 'src/zendesk_custom_field.dart';
export 'src/zendesk_sdk_error_codes.dart';
export 'src/zendesk_sdk_exception.dart';

import 'src/zendesk_custom_field.dart';
import 'zendesk_sdk_platform_interface.dart';

/// Entry point for the Zendesk Support, Chat, Answer Bot, and Messaging SDKs.
class ZendeskSdk {
  ZendeskSdk._();

  /// Shared singleton instance.
  static final ZendeskSdk instance = ZendeskSdk._();

  factory ZendeskSdk() => instance;

  /// Initializes Zendesk Support, Chat, and Answer Bot with an anonymous identity.
  ///
  /// Call this once before any other SDK method. [userType] is stored as a
  /// conversation/ticket tag on native platforms (for example `RIDER` or `DRIVER`).
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String name,
    required String emailId,
    required String userId,
    required String userType,
  }) {
    return ZendeskSdkPlatform.instance.initialize(
      url: url,
      appId: appId,
      clientId: clientId,
      name: name,
      emailId: emailId,
      userId: userId,
      userType: userType,
    );
  }

  /// Clears the current Zendesk identity and messaging session.
  ///
  /// Call when the user signs out so the next session does not reuse prior data.
  Future<void> logout() {
    return ZendeskSdkPlatform.instance.logout();
  }

  /// Returns whether [initialize] has completed successfully on the native side.
  Future<bool> isInitialized() {
    return ZendeskSdkPlatform.instance.isInitialized();
  }

  /// Opens the Help Center filtered by [categoryIdList].
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return ZendeskSdkPlatform.instance.showHelpCenter(
      name: name,
      emailId: emailId,
      userId: userId,
      categoryIdList: categoryIdList,
    );
  }

  /// Opens Answer Bot. Supported on Android and iOS.
  Future<void> startChatBot() {
    return ZendeskSdkPlatform.instance.startChatBot();
  }

  /// Opens a single Help Center article by [articleId].
  Future<void> showHelpWithArticleId({required String articleId}) {
    return ZendeskSdkPlatform.instance.showHelpCenterArticleId(
      articleId: articleId,
    );
  }

  /// Opens Help Center articles for a single [categoryId].
  Future<void> showHelpWithCategoryId({required String categoryId}) {
    return ZendeskSdkPlatform.instance.showHelpCenterCategoryId(
      categoryId: categoryId,
    );
  }

  /// Opens ticket submission with user/trip metadata and optional [customFields].
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    return ZendeskSdkPlatform.instance.sendUserInformationForTicket(
      name: name,
      emailId: emailId,
      userId: userId,
      tripId: tripId,
      customFields: customFields,
    );
  }

  /// Opens the user's ticket list.
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return ZendeskSdkPlatform.instance.showListOfTickets(
      name: name,
      emailId: emailId,
      userId: userId,
      tripId: tripId,
    );
  }

  /// Opens Zendesk Messaging using the given Messaging [channelId] (channel key).
  Future<void> startChat({required String channelId}) {
    return ZendeskSdkPlatform.instance.startChat(channelId: channelId);
  }

  /// Returns the total unread messaging count, or `0` if messaging is unavailable.
  Future<int> getUnreadMessageCount() {
    return ZendeskSdkPlatform.instance.getUnreadMessageCount();
  }

  /// Registers or updates the device push token with Zendesk Messaging.
  Future<void> updatePushNotificationToken({required String token}) {
    return ZendeskSdkPlatform.instance.updatePushNotificationToken(token: token);
  }

  /// Validates and optionally displays a Zendesk Messaging push notification.
  ///
  /// Returns `true` when the payload belongs to Zendesk Messaging.
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) {
    return ZendeskSdkPlatform.instance.handlePushNotification(data: data);
  }
}
