import '../zendesk_sdk_channel.dart';

/// Command contract for MethodChannel invocations (Command pattern + OCP).
abstract class ZendeskCommand<T> {
  String get methodName;

  Map<String, dynamic>? get arguments;

  void validate() {}
}

/// Merges [ZendeskConfig] and [ZendeskUser] maps for initialize.
Map<String, dynamic> mergeInitializeArgs(
  Map<String, dynamic> config,
  Map<String, dynamic> user,
) {
  return {
    ZendeskSdkChannel.argZendeskUrl: config['zendeskUrl'],
    ZendeskSdkChannel.argAppId: config['appId'],
    ZendeskSdkChannel.argClientId: config['clientId'],
    ZendeskSdkChannel.argName: user['name'],
    ZendeskSdkChannel.argEmailId: user['emailId'],
    ZendeskSdkChannel.argUserId: user['userId'],
    ZendeskSdkChannel.argUserType: user['userType'],
  };
}
