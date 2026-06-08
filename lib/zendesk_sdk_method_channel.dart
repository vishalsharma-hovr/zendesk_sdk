import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/zendesk_custom_field.dart';
import 'src/zendesk_sdk_channel.dart';
import 'src/zendesk_sdk_exception.dart';
import 'zendesk_sdk_platform_interface.dart';

class MethodChannelZendeskSdk extends ZendeskSdkPlatform {
  @visibleForTesting
  final MethodChannel methodChannel;

  MethodChannelZendeskSdk({MethodChannel? methodChannel})
      : methodChannel = methodChannel ?? const MethodChannel(ZendeskSdkChannel.name);

  Future<void> _invoke(String method, [Map<String, dynamic>? arguments]) async {
    try {
      await methodChannel.invokeMethod<void>(method, arguments);
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
    return _invoke(ZendeskSdkChannel.methodInitialize, {
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
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) {
    return _invoke(ZendeskSdkChannel.methodShowHelpCenter, {
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argCategoryIdList: categoryIdList,
    });
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) {
    return _invoke(ZendeskSdkChannel.methodShowHelpCenterArticleId, {
      ZendeskSdkChannel.argArticleId: articleId,
    });
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) {
    return _invoke(ZendeskSdkChannel.methodShowHelpCenterCategoryId, {
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
    return _invoke(ZendeskSdkChannel.methodSendUserInformationForTicket, {
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
    return _invoke(ZendeskSdkChannel.methodStartChatBot);
  }

  @override
  Future<void> showListOfTickets({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) {
    return _invoke(ZendeskSdkChannel.methodShowListOfTickets, {
      ZendeskSdkChannel.argName: name,
      ZendeskSdkChannel.argEmailId: emailId,
      ZendeskSdkChannel.argUserId: userId,
      ZendeskSdkChannel.argTripId: tripId,
    });
  }

  @override
  Future<void> startChat({required String channelId}) {
    return _invoke(ZendeskSdkChannel.methodStartChat, {
      ZendeskSdkChannel.argChannelId: channelId,
    });
  }
}
