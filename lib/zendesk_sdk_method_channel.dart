import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/commands/zendesk_command.dart';
import 'src/commands/zendesk_commands.dart';
import 'src/models/zendesk_config.dart';
import 'src/models/zendesk_push_notification.dart';
import 'src/models/zendesk_ticket_request.dart';
import 'src/models/zendesk_user.dart';
import 'src/platform/zendesk_lifecycle_platform.dart';
import 'src/platform/zendesk_messaging_platform.dart';
import 'src/platform/zendesk_support_platform.dart';
import 'src/zendesk_custom_field.dart';
import 'src/zendesk_sdk_channel.dart';
import 'src/zendesk_sdk_exception.dart';
import 'zendesk_sdk_platform_interface.dart';

class MethodChannelZendeskSdk extends ZendeskSdkPlatform
    implements ZendeskLifecyclePlatform, ZendeskSupportPlatform, ZendeskMessagingPlatform {
  @visibleForTesting
  final MethodChannel methodChannel;

  MethodChannelZendeskSdk({MethodChannel? methodChannel})
      : methodChannel = methodChannel ?? const MethodChannel(ZendeskSdkChannel.name);

  Future<T?> _execute<T>(ZendeskCommand<T> command) async {
    command.validate();
    try {
      return await methodChannel.invokeMethod<T>(
        command.methodName,
        command.arguments,
      );
    } on PlatformException catch (error) {
      throw ZendeskSdkException.fromPlatformException(error);
    }
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
    return _execute<void>(
      InitializeCommand(
        config: ZendeskConfig(url: url, appId: appId, clientId: clientId),
        user: ZendeskUser(
          name: name,
          emailId: emailId,
          userId: userId,
          userType: userType,
        ),
      ),
    );
  }

  @override
  Future<void> logout() => _execute<void>(LogoutCommand());

  @override
  Future<bool> isInitialized() async {
    final result = await _execute<bool>(IsInitializedCommand());
    return result ?? false;
  }

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return _execute<void>(
      ShowHelpCenterCommand(
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

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    return _execute<void>(ShowHelpCenterArticleIdCommand(articleId));
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    return _execute<void>(ShowHelpCenterCategoryIdCommand(categoryId));
  }

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    return _execute<void>(
      SendUserInformationForTicketCommand(
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
      ),
    );
  }

  @override
  Future<void> startChatBot() => _execute<void>(StartChatBotCommand());

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return _execute<void>(
      ShowListOfTicketsCommand(
        user: ZendeskUser(
          name: name,
          emailId: emailId,
          userId: userId,
          userType: '',
        ),
        tripId: tripId,
      ),
    );
  }

  @override
  Future<void> startChat({required String channelId}) {
    return _execute<void>(StartChatCommand(channelId));
  }

  @override
  Future<int> getUnreadMessageCount() async {
    final result = await _execute<int>(GetUnreadMessageCountCommand());
    return result ?? 0;
  }

  @override
  Future<void> updatePushNotificationToken({required String token}) {
    return _execute<void>(UpdatePushNotificationTokenCommand(ZendeskPushToken(token)));
  }

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) async {
    final result = await _execute<bool>(
      HandlePushNotificationCommand(ZendeskPushNotification(data: data)),
    );
    return result ?? false;
  }
}
