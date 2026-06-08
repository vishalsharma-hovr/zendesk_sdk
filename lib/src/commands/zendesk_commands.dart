import '../models/zendesk_config.dart';
import '../models/zendesk_push_notification.dart';
import '../models/zendesk_ticket_request.dart';
import '../models/zendesk_user.dart';
import '../zendesk_sdk_channel.dart';
import '../zendesk_sdk_validator.dart';
import 'zendesk_command.dart';

final class InitializeCommand extends ZendeskCommand<void> {
  InitializeCommand({
    required ZendeskConfig config,
    required ZendeskUser user,
  })  : _config = config,
        _user = user;

  final ZendeskConfig _config;
  final ZendeskUser _user;

  @override
  String get methodName => ZendeskSdkChannel.methodInitialize;

  @override
  Map<String, dynamic> get arguments => mergeInitializeArgs(
        _config.toChannelArguments(),
        _user.toChannelArguments(),
      );

  @override
  void validate() {
    ZendeskSdkValidator.requireInitializeArgs(
      url: _config.url,
      appId: _config.appId,
      clientId: _config.clientId,
    );
  }
}

final class LogoutCommand extends ZendeskCommand<void> {
  @override
  String get methodName => ZendeskSdkChannel.methodLogout;

  @override
  Map<String, dynamic>? get arguments => null;
}

final class IsInitializedCommand extends ZendeskCommand<bool> {
  @override
  String get methodName => ZendeskSdkChannel.methodIsInitialized;

  @override
  Map<String, dynamic>? get arguments => null;
}

final class ShowHelpCenterCommand extends ZendeskCommand<void> {
  ShowHelpCenterCommand({
    required ZendeskUser user,
    required List<int> categoryIdList,
  })  : _user = user,
        _categoryIdList = categoryIdList;

  final ZendeskUser _user;
  final List<int> _categoryIdList;

  @override
  String get methodName => ZendeskSdkChannel.methodShowHelpCenter;

  @override
  Map<String, dynamic> get arguments => {
        ..._user.toChannelArguments(),
        ZendeskSdkChannel.argCategoryIdList: _categoryIdList,
      };
}

final class ShowHelpCenterArticleIdCommand extends ZendeskCommand<void> {
  ShowHelpCenterArticleIdCommand(this.articleId);

  final String articleId;

  @override
  String get methodName => ZendeskSdkChannel.methodShowHelpCenterArticleId;

  @override
  Map<String, dynamic> get arguments => {
        ZendeskSdkChannel.argArticleId: articleId,
      };

  @override
  void validate() => ZendeskSdkValidator.requireNonEmpty(articleId, 'articleId');
}

final class ShowHelpCenterCategoryIdCommand extends ZendeskCommand<void> {
  ShowHelpCenterCategoryIdCommand(this.categoryId);

  final String categoryId;

  @override
  String get methodName => ZendeskSdkChannel.methodShowHelpCenterCategoryId;

  @override
  Map<String, dynamic> get arguments => {
        ZendeskSdkChannel.argCategoryId: categoryId,
      };

  @override
  void validate() => ZendeskSdkValidator.requireNonEmpty(categoryId, 'categoryId');
}

final class SendUserInformationForTicketCommand extends ZendeskCommand<void> {
  SendUserInformationForTicketCommand(this.request);

  final ZendeskTicketRequest request;

  @override
  String get methodName => ZendeskSdkChannel.methodSendUserInformationForTicket;

  @override
  Map<String, dynamic> get arguments => request.toChannelArguments();
}

final class StartChatBotCommand extends ZendeskCommand<void> {
  @override
  String get methodName => ZendeskSdkChannel.methodStartChatBot;

  @override
  Map<String, dynamic>? get arguments => null;
}

final class ShowListOfTicketsCommand extends ZendeskCommand<void> {
  ShowListOfTicketsCommand({
    required ZendeskUser user,
    required String tripId,
  })  : _user = user,
        _tripId = tripId;

  final ZendeskUser _user;
  final String _tripId;

  @override
  String get methodName => ZendeskSdkChannel.methodShowListOfTickets;

  @override
  Map<String, dynamic> get arguments => {
        ..._user.toChannelArguments(),
        ZendeskSdkChannel.argTripId: _tripId,
      };
}

final class StartChatCommand extends ZendeskCommand<void> {
  StartChatCommand(this.channelId);

  final String channelId;

  @override
  String get methodName => ZendeskSdkChannel.methodStartChat;

  @override
  Map<String, dynamic> get arguments => {
        ZendeskSdkChannel.argChannelId: channelId,
      };

  @override
  void validate() => ZendeskSdkValidator.requireChannelId(channelId);
}

final class GetUnreadMessageCountCommand extends ZendeskCommand<int> {
  @override
  String get methodName => ZendeskSdkChannel.methodGetUnreadMessageCount;

  @override
  Map<String, dynamic>? get arguments => null;
}

final class UpdatePushNotificationTokenCommand extends ZendeskCommand<void> {
  UpdatePushNotificationTokenCommand(ZendeskPushToken token) : _token = token;

  final ZendeskPushToken _token;

  @override
  String get methodName => ZendeskSdkChannel.methodUpdatePushNotificationToken;

  @override
  Map<String, dynamic> get arguments => {
        ZendeskSdkChannel.argPushToken: _token.value,
      };

  @override
  void validate() => ZendeskSdkValidator.requirePushToken(_token.value);
}

final class HandlePushNotificationCommand extends ZendeskCommand<bool> {
  HandlePushNotificationCommand(ZendeskPushNotification notification)
      : _notification = notification;

  final ZendeskPushNotification _notification;

  @override
  String get methodName => ZendeskSdkChannel.methodHandlePushNotification;

  @override
  Map<String, dynamic> get arguments => _notification.toChannelArguments();
}
