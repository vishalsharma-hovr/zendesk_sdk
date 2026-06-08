import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/zendesk_custom_field.dart';
import 'src/zendesk_sdk_channel.dart';
import 'src/zendesk_sdk_exception.dart';
import 'src/zendesk_sdk_validator.dart';
import 'zendesk_sdk_platform_interface.dart';

class MethodChannelZendeskSdk extends ZendeskSdkPlatform {
  @visibleForTesting
  final MethodChannel methodChannel;

  MethodChannelZendeskSdk({MethodChannel? methodChannel})
      : methodChannel = methodChannel ?? const MethodChannel(ZendeskSdkChannel.name);

  Future<T?> _invoke<T>(String method, [Map<String, dynamic>? arguments]) async {
    try {
      return await methodChannel.invokeMethod<T>(method, arguments);
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
    ZendeskSdkValidator.requireInitializeArgs(
      url: url,
      appId: appId,
      clientId: clientId,
    );
    return _invoke<void>(ZendeskSdkChannel.methodInitialize, {
      ZendeskSdkChannel.argZendeskUrl: url,
      ZendeskSdkChannel.argAppId: appId,
      ZendeskSdkChannel.argClientId: clientId,
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argUserType: userType,
    });
  }

  @override
  Future<void> logout() {
    return _invoke<void>(ZendeskSdkChannel.methodLogout);
  }

  @override
  Future<bool> isInitialized() async {
    final result = await _invoke<bool>(ZendeskSdkChannel.methodIsInitialized);
    return result ?? false;
  }

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return _invoke<void>(ZendeskSdkChannel.methodShowHelpCenter, {
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argCategoryIdList: categoryIdList,
    });
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    ZendeskSdkValidator.requireNonEmpty(articleId, 'articleId');
    return _invoke<void>(ZendeskSdkChannel.methodShowHelpCenterArticleId, {
      ZendeskSdkChannel.argArticleId: articleId,
    });
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    ZendeskSdkValidator.requireNonEmpty(categoryId, 'categoryId');
    return _invoke<void>(ZendeskSdkChannel.methodShowHelpCenterCategoryId, {
      ZendeskSdkChannel.argCategoryId: categoryId,
    });
  }

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
    List<ZendeskCustomField> customFields = const [],
  }) {
    return _invoke<void>(ZendeskSdkChannel.methodSendUserInformationForTicket, {
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argTripId: tripId,
      ZendeskSdkChannel.argCustomFields:
          customFields.map((field) => field.toJson()).toList(),
    });
  }

  @override
  Future<void> startChatBot() {
    return _invoke<void>(ZendeskSdkChannel.methodStartChatBot);
  }

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return _invoke<void>(ZendeskSdkChannel.methodShowListOfTickets, {
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argTripId: tripId,
    });
  }

  @override
  Future<void> startChat({required String channelId}) {
    ZendeskSdkValidator.requireChannelId(channelId);
    return _invoke<void>(ZendeskSdkChannel.methodStartChat, {
      ZendeskSdkChannel.argChannelId: channelId,
    });
  }

  @override
  Future<int> getUnreadMessageCount() async {
    final result = await _invoke<int>(ZendeskSdkChannel.methodGetUnreadMessageCount);
    return result ?? 0;
  }

  @override
  Future<void> updatePushNotificationToken({required String token}) {
    ZendeskSdkValidator.requirePushToken(token);
    return _invoke<void>(ZendeskSdkChannel.methodUpdatePushNotificationToken, {
      ZendeskSdkChannel.argPushToken: token,
    });
  }

  @override
  Future<bool> handlePushNotification({required Map<String, dynamic> data}) async {
    final result = await _invoke<bool>(ZendeskSdkChannel.methodHandlePushNotification, {
      ZendeskSdkChannel.argPushNotificationData: data,
    });
    return result ?? false;
  }
}
