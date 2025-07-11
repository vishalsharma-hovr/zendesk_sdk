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
  Future<void> showHelpCenter({required String name, required String userId}) async {
    await methodChannel.invokeMethod('showHelpCenter', {"name": name, "userId": userId});
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
  Future<void> sendUserInformationForTicket({required String name, required String userId, required String tripId}) async {
    await methodChannel.invokeMethod("sendUserInformationForTicket", {"name": name, "userId": userId, "tripId": tripId});
  }

  @override
  Future<void> startChatBot() async {
    await methodChannel.invokeMethod('startChatBot');
  }
}
