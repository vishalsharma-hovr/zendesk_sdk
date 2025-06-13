import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'zendesk_sdk_method_channel.dart';

abstract class ZendeskSdkPlatform extends PlatformInterface {
  ZendeskSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZendeskSdkPlatform _instance = MethodChannelZendeskSdk();

  static ZendeskSdkPlatform get instance => _instance;

  static set instance(ZendeskSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize({required String url, required String appId, required String clientId}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<void> showHelpCenter() {
    throw UnimplementedError('showHelpCenter() has not been implemented.');
  }
}
