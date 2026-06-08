import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/platform/zendesk_lifecycle_platform.dart';
import 'src/platform/zendesk_messaging_platform.dart';
import 'src/platform/zendesk_support_platform.dart';
import 'src/zendesk_custom_field.dart';
import 'zendesk_sdk_method_channel.dart';

/// Federated platform contract implementing segregated capability interfaces.
abstract class ZendeskSdkPlatform extends PlatformInterface
    implements ZendeskLifecyclePlatform, ZendeskSupportPlatform, ZendeskMessagingPlatform {
  ZendeskSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZendeskSdkPlatform _instance = MethodChannelZendeskSdk();

  static ZendeskSdkPlatform get instance => _instance;

  static set instance(ZendeskSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String name,
    required String emailId,
    required String userId,
    required String userType,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  @override
  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  @override
  Future<bool> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    throw UnimplementedError('showHelpCenter() has not been implemented.');
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    throw UnimplementedError('showHelpCenterArticleId() has not been implemented.');
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    throw UnimplementedError('showHelpCenterCategoryId() has not been implemented.');
  }

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    throw UnimplementedError('sendUserInformationForTicket() has not been implemented');
  }

  @override
  Future<void> startChatBot() {
    throw UnimplementedError('startChatBot() has not been implemented.');
  }

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    throw UnimplementedError('showListOfTickets() has not been implemented.');
  }

  @override
  Future<void> startChat({required String channelId}) {
    throw UnimplementedError('startChat() has not been implemented.');
  }

  @override
  Future<int> getUnreadMessageCount() {
    throw UnimplementedError('getUnreadMessageCount() has not been implemented.');
  }

  @override
  Future<void> updatePushNotificationToken({required String token}) {
    throw UnimplementedError('updatePushNotificationToken() has not been implemented.');
  }

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) {
    throw UnimplementedError('handlePushNotification() has not been implemented.');
  }
}
