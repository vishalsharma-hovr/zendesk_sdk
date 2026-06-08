import Flutter
import UIKit

enum ZendeskConfigChannel {
    static let name = "zendesk_config"
    static let methodGetConfig = "getZendeskConfig"

    static let keyUrl = "ZENDESK_URL"
    static let keyAppId = "ZENDESK_APP_ID"
    static let keyClientId = "ZENDESK_CLIENT_ID"
    static let keyChannelId = "ZENDESK_CHANNEL_ID"

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: name,
            binaryMessenger: registrar.messenger()
        )

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case methodGetConfig:
                result(readConfig())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func readConfig() -> [String: String] {
        let bundle = Bundle.main
        return [
            keyUrl: readInfoPlistValue(bundle: bundle, key: keyUrl),
            keyAppId: readInfoPlistValue(bundle: bundle, key: keyAppId),
            keyClientId: readInfoPlistValue(bundle: bundle, key: keyClientId),
            keyChannelId: readInfoPlistValue(bundle: bundle, key: keyChannelId),
        ]
    }

    private static func readInfoPlistValue(bundle: Bundle, key: String) -> String {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
            return ""
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty || trimmed.hasPrefix("$(") {
            return ""
        }

        return trimmed
    }
}
