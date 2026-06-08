import '../zendesk_sdk_platform_interface.dart';
import 'models/zendesk_config.dart';
import 'models/zendesk_help_center_query.dart';
import 'models/zendesk_push_notification.dart';
import 'models/zendesk_ticket_request.dart';
import 'models/zendesk_user.dart';
import 'platform/zendesk_lifecycle_platform.dart';
import 'platform/zendesk_messaging_platform.dart';
import 'platform/zendesk_platform_adapters.dart';
import 'platform/zendesk_support_platform.dart';
import 'zendesk_result.dart';
import 'zendesk_sdk_exception.dart';

/// Application service coordinating segregated platform interfaces (DIP + Facade).
class ZendeskService {
  ZendeskService({
    required ZendeskLifecyclePlatform lifecycle,
    required ZendeskSupportPlatform support,
    required ZendeskMessagingPlatform messaging,
  })  : _lifecycle = lifecycle,
        _support = support,
        _messaging = messaging;

  /// Builds a service from the federated plugin platform using adapter composition.
  factory ZendeskService.fromSdkPlatform(ZendeskSdkPlatform platform) {
    return ZendeskService(
      lifecycle: ZendeskLifecyclePlatformAdapter(platform),
      support: ZendeskSupportPlatformAdapter(platform),
      messaging: ZendeskMessagingPlatformAdapter(platform),
    );
  }

  final ZendeskLifecyclePlatform _lifecycle;
  final ZendeskSupportPlatform _support;
  final ZendeskMessagingPlatform _messaging;

  Future<ZendeskResult<void>> initializeResult({
    required ZendeskConfig config,
    required ZendeskUser user,
  }) {
    return _run(() => _lifecycle.initialize(
          url: config.url,
          appId: config.appId,
          clientId: config.clientId,
          name: user.name,
          emailId: user.emailId,
          userId: user.userId,
          userType: user.userType,
        ));
  }

  Future<void> initialize({
    required ZendeskConfig config,
    required ZendeskUser user,
  }) {
    return initializeResult(config: config, user: user).then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<void>> logoutResult() => _run(_lifecycle.logout);

  Future<void> logout() => logoutResult().then((result) => result.valueOrThrow);

  Future<ZendeskResult<bool>> isInitializedResult() => _run(_lifecycle.isInitialized);

  Future<bool> isInitialized() => isInitializedResult().then((result) => result.valueOrThrow);

  Future<ZendeskResult<void>> showHelpCenterResult(ZendeskHelpCenterQuery query) {
    return _run(() async {
      switch (query) {
        case CategoryListHelpCenterQuery(:final user, :final categoryIdList):
          await _support.showHelpCenter(
            name: user.name,
            emailId: user.emailId,
            userId: user.userId,
            categoryIdList: categoryIdList,
          );
        case ArticleHelpCenterQuery(:final articleId):
          await _support.showHelpCenterArticleId(articleId: articleId);
        case CategoryHelpCenterQuery(:final categoryId):
          await _support.showHelpCenterCategoryId(categoryId: categoryId);
      }
    });
  }

  Future<void> showHelpCenter(CategoryListHelpCenterQuery query) {
    return showHelpCenterResult(query).then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<void>> sendTicketResult(ZendeskTicketRequest request) {
    return _run(() => _support.sendUserInformationForTicket(
          name: request.user.name,
          emailId: request.user.emailId,
          userId: request.user.userId,
          tripId: request.tripId,
          customFields: request.customFields,
        ));
  }

  Future<void> sendTicket(ZendeskTicketRequest request) {
    return sendTicketResult(request).then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<void>> showTicketListResult({
    required ZendeskUser user,
    required String tripId,
  }) {
    return _run(() => _support.showListOfTickets(
          name: user.name,
          emailId: user.emailId,
          userId: user.userId,
          tripId: tripId,
        ));
  }

  Future<void> showTicketList({
    required ZendeskUser user,
    required String tripId,
  }) {
    return showTicketListResult(user: user, tripId: tripId)
        .then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<void>> startChatBotResult() => _run(_support.startChatBot);

  Future<void> startChatBot() => startChatBotResult().then((result) => result.valueOrThrow);

  Future<ZendeskResult<void>> startChatResult({required String channelId}) {
    return _run(() => _messaging.startChat(channelId: channelId));
  }

  Future<void> startChat({required String channelId}) {
    return startChatResult(channelId: channelId).then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<int>> getUnreadMessageCountResult() {
    return _run(_messaging.getUnreadMessageCount);
  }

  Future<int> getUnreadMessageCount() {
    return getUnreadMessageCountResult().then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<void>> updatePushTokenResult(ZendeskPushToken token) {
    return _run(() => _messaging.updatePushNotificationToken(token: token.value));
  }

  Future<void> updatePushToken(ZendeskPushToken token) {
    return updatePushTokenResult(token).then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<bool>> handlePushNotificationResult(
    ZendeskPushNotification notification,
  ) {
    return _run(() => _messaging.handlePushNotification(data: notification.data));
  }

  Future<bool> handlePushNotification(ZendeskPushNotification notification) {
    return handlePushNotificationResult(notification)
        .then((result) => result.valueOrThrow);
  }

  Future<ZendeskResult<T>> _run<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return ZendeskSuccess<T>(value);
    } on ZendeskSdkException catch (error) {
      return ZendeskFailure<T>(error);
    }
  }
}
