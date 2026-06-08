import Flutter

/// Immutable Zendesk account configuration (Value Object).
struct ZendeskConfig {
    let url: String
    let appId: String
    let clientId: String

    static func from(call: FlutterMethodCall) -> ZendeskConfig? {
        guard let args = call.arguments as? [String: Any],
              let url = args[ZendeskSdkChannel.Argument.zendeskUrl] as? String,
              let appId = args[ZendeskSdkChannel.Argument.appId] as? String,
              let clientId = args[ZendeskSdkChannel.Argument.clientId] as? String,
              !url.isEmpty,
              !appId.isEmpty,
              !clientId.isEmpty
        else {
            return nil
        }
        return ZendeskConfig(url: url, appId: appId, clientId: clientId)
    }
}
