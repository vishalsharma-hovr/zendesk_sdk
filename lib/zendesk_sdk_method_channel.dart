import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'zendesk_sdk_platform_interface.dart';

class MethodChannelZendeskSdk extends ZendeskSdkPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('zendesk_sdk');

  @override
  Future<void> initialize({required String url, required String appId, required String clientId}) async {
    await methodChannel.invokeMethod('initialize', {'zendeskUrl': url, 'appId': appId, 'clientId': clientId});
  }

  @override
  Future<void> showHelpCenter({
    required String name,
    required String emailId,
    required String userId,
    required List<int> categoryIdList,
  }) async {
    await methodChannel.invokeMethod('showHelpCenter', {
      "name": name,
      "emailId": emailId,
      "userId": userId,
      "categoryIdList": categoryIdList,
    });
  }

  @override
  Future<void> showHelpCenterArticleId({required String articleId}) async {
    await methodChannel.invokeMethod('showHelpCenterAriticleId', {"articleId": articleId});
  }

  @override
  Future<void> showHelpCenterCategoryId({required String categoryId}) async {
    await methodChannel.invokeMethod('showHelpCenterCategoryId', {"categoryId": categoryId});
  }

  @override
  Future<void> sendUserInformationForTicket({
    required String name,
    required String emailId,
    required String userId,
    required String tripId,
  }) async {
    await methodChannel.invokeMethod("sendUserInformationForTicket", {
      "name": name,
      "emailId": emailId,
      "userId": userId,
      "tripId": tripId,
    });
  }

  @override
  Future<void> startChatBot() async {
    await methodChannel.invokeMethod('startChatBot');
  }
}
