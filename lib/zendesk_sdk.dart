export 'src/models/zendesk_config.dart';
export 'src/models/zendesk_help_center_query.dart';
export 'src/models/zendesk_push_notification.dart';
export 'src/models/zendesk_ticket_request.dart';
export 'src/models/zendesk_user.dart';
export 'src/platform/zendesk_lifecycle_platform.dart';
export 'src/platform/zendesk_messaging_platform.dart';
export 'src/platform/zendesk_support_platform.dart';
export 'src/zendesk_custom_field.dart';
export 'src/zendesk_result.dart';
export 'src/zendesk_sdk_error_codes.dart';
export 'src/zendesk_sdk_exception.dart';
export 'src/zendesk_service.dart';

import 'src/models/zendesk_config.dart';
import 'src/models/zendesk_help_center_query.dart';
import 'src/models/zendesk_push_notification.dart';
import 'src/models/zendesk_ticket_request.dart';
import 'src/models/zendesk_user.dart';
import 'src/zendesk_custom_field.dart';
import 'src/zendesk_result.dart';
import 'src/zendesk_service.dart';
import 'zendesk_sdk_platform_interface.dart';

/// Entry point for the Zendesk Support, Chat, Answer Bot, and Messaging SDKs.
///
/// Thin facade over [ZendeskService] (Facade pattern). Prefer injecting
/// [ZendeskService] directly when demonstrating dependency injection.
class ZendeskSdk {
  ZendeskSdk._(this._service);

  /// Shared singleton backed by the default platform implementation.
  static final ZendeskSdk instance = ZendeskSdk._(
    ZendeskService.fromSdkPlatform(ZendeskSdkPlatform.instance),
  );

  factory ZendeskSdk() => instance;

  /// Creates an SDK facade with an injected [ZendeskService] (Dependency Injection).
  factory ZendeskSdk.withService(ZendeskService service) => ZendeskSdk._(service);

  final ZendeskService _service;

  /// Exposes the underlying service for advanced OOP/DI scenarios.
  ZendeskService get service => _service;

  /// Initializes Zendesk Support, Chat, and Answer Bot with an anonymous identity.
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
    required String name,
    required String emailId,
    required String userId,
    required String userType,
  }) {
    return _service.initialize(
      config: ZendeskConfig(url: url, appId: appId, clientId: clientId),
      user: ZendeskUser(
        name: name,
        emailId: emailId,
        userId: userId,
        userType: userType,
      ),
    );
  }

  /// Object-oriented initialize returning an explicit [ZendeskResult].
  Future<ZendeskResult<void>> initializeResult({
    required ZendeskConfig config,
    required ZendeskUser user,
  }) {
    return _service.initializeResult(config: config, user: user);
  }

  Future<void> logout() => _service.logout();

  Future<ZendeskResult<void>> logoutResult() => _service.logoutResult();

  Future<bool> isInitialized() => _service.isInitialized();

  Future<ZendeskResult<bool>> isInitializedResult() => _service.isInitializedResult();

  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return _service.showHelpCenter(
      CategoryListHelpCenterQuery(
        user: ZendeskUser(
          name: name,
          emailId: emailId,
          userId: userId,
          userType: '',
        ),
        categoryIdList: categoryIdList,
      ),
    );
  }

  Future<void> showHelpCenterQuery(CategoryListHelpCenterQuery query) {
    return _service.showHelpCenter(query);
  }

  Future<ZendeskResult<void>> showHelpCenterResult(ZendeskHelpCenterQuery query) {
    return _service.showHelpCenterResult(query);
  }

  Future<void> startChatBot() => _service.startChatBot();

  Future<void> showHelpWithArticleId({required String articleId}) {
    return _service.showHelpCenterResult(
      ArticleHelpCenterQuery(
        user: const ZendeskUser(
          name: '',
          emailId: '',
          userId: '',
          userType: '',
        ),
        articleId: articleId,
      ),
    ).then((result) => result.valueOrThrow);
  }

  Future<void> showHelpWithCategoryId({required String categoryId}) {
    return _service.showHelpCenterResult(
      CategoryHelpCenterQuery(
        user: const ZendeskUser(
          name: '',
          emailId: '',
          userId: '',
          userType: '',
        ),
        categoryId: categoryId,
      ),
    ).then((result) => result.valueOrThrow);
  }

  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    return _service.sendTicket(
      ZendeskTicketRequest(
        user: ZendeskUser(
          name: name,
          emailId: emailId,
          userId: userId,
          userType: '',
        ),
        tripId: tripId,
        customFields: customFields,
      ),
    );
  }

  Future<void> sendTicket(ZendeskTicketRequest request) => _service.sendTicket(request);

  Future<ZendeskResult<void>> sendTicketResult(ZendeskTicketRequest request) {
    return _service.sendTicketResult(request);
  }

  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return _service.showTicketList(
      user: ZendeskUser(
        name: name,
        emailId: emailId,
        userId: userId,
        userType: '',
      ),
      tripId: tripId,
    );
  }

  Future<void> startChat({required String channelId}) {
    return _service.startChat(channelId: channelId);
  }

  Future<int> getUnreadMessageCount() => _service.getUnreadMessageCount();

  Future<void> updatePushNotificationToken({required String token}) {
    return _service.updatePushToken(ZendeskPushToken(token));
  }

  Future<bool> handlePushNotification({required Map<String, dynamic> data}) {
    return _service.handlePushNotification(ZendeskPushNotification(data: data));
  }
}
