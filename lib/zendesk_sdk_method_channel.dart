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
  Future<void> showHelpCenter() async {
    await methodChannel.invokeMethod('showHelpCenter');
  }
}
