import '../zendesk_custom_field.dart';
import '../../zendesk_sdk_platform_interface.dart';
import 'zendesk_lifecycle_platform.dart';
import 'zendesk_messaging_platform.dart';
import 'zendesk_support_platform.dart';

/// Adapter composition: one [ZendeskSdkPlatform] exposed as segregated interfaces.
final class ZendeskLifecyclePlatformAdapter implements ZendeskLifecyclePlatform {
  const ZendeskLifecyclePlatformAdapter(this._delegate);

  final ZendeskSdkPlatform _delegate;

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
    return _delegate.initialize(
      url: url,
      appId: appId,
      clientId: clientId,
      name: name,
      emailId: emailId,
      userId: userId,
      userType: userType,
    );
  }

  @override
  Future<void> logout() => _delegate.logout();

  @override
  Future<bool> isInitialized() => _delegate.isInitialized();
}

final class ZendeskSupportPlatformAdapter implements ZendeskSupportPlatform {
  const ZendeskSupportPlatformAdapter(this._delegate);

  final ZendeskSdkPlatform _delegate;

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return _delegate.showHelpCenter(
      name: name,
      emailId: emailId,
      userId: userId,
      categoryIdList: categoryIdList,
    );
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    return _delegate.showHelpCenterArticleId(articleId: articleId);
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    return _delegate.showHelpCenterCategoryId(categoryId: categoryId);
  }

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    return _delegate.sendUserInformationForTicket(
      name: name,
      emailId: emailId,
      userId: userId,
      tripId: tripId,
      customFields: customFields,
    );
  }

  @override
  Future<void> startChatBot() => _delegate.startChatBot();

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return _delegate.showListOfTickets(
      name: name,
      emailId: emailId,
      userId: userId,
      tripId: tripId,
    );
  }
}

final class ZendeskMessagingPlatformAdapter implements ZendeskMessagingPlatform {
  const ZendeskMessagingPlatformAdapter(this._delegate);

  final ZendeskSdkPlatform _delegate;

  @override
  Future<void> startChat({required String channelId}) {
    return _delegate.startChat(channelId: channelId);
  }

  @override
  Future<int> getUnreadMessageCount() => _delegate.getUnreadMessageCount();

  @override
  Future<void> updatePushNotificationToken({required String token}) {
    return _delegate.updatePushNotificationToken(token: token);
  }

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) {
    return _delegate.handlePushNotification(data: data);
  }
}
