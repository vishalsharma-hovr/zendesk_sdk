
import 'zendesk_sdk_platform_interface.dart';

class ZendeskSdk {
  Future<void> initialize({
    required String url,
    required String appId,
    required String clientId,
  }) {
    return ZendeskSdkPlatform.instance.initialize(url: url, appId: appId, clientId: clientId);
  }

  Future<void> showHelpCenter() {
    return ZendeskSdkPlatform.instance.showHelpCenter();
  }
}
