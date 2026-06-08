import Flutter
import MessagingSDK
import UIKit
import ZendeskSDK
import ZendeskSDKMessaging

final class ZendeskMessagingHandler: ZendeskMessagingHandling {
    private let session: ZendeskSession
    private weak var uiContext: ZendeskUiContextProviding?
    private weak var pluginHost: ZendeskPluginHost?

    init(
        session: ZendeskSession,
        uiContext: ZendeskUiContextProviding,
        pluginHost: ZendeskPluginHost
    ) {
        self.session = session
        self.uiContext = uiContext
        self.pluginHost = pluginHost
    }

    func startChatAsync(channelId: String, result: @escaping FlutterResult) {
        Zendesk.initialize(
            withChannelKey: channelId,
            messagingFactory: DefaultMessagingFactory()
        ) { initResult in
            switch initResult {
            case .success:
                DispatchQueue.main.async {
                    self.applyMessagingVisitorInfo()

                    guard
                        let viewController = Zendesk.instance?.messaging?.messagingViewController(),
                        let rootVC = self.uiContext?.rootViewController()
                    else {
                        result(
                            FlutterError(
                                code: ZendeskSdkErrorCodes.noUiContext,
                                message: "Failed to get Zendesk view controller or root view controller",
                                details: nil
                            )
                        )
                        return
                    }

                    viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                        barButtonSystemItem: .close,
                        target: self.pluginHost,
                        action: #selector(ZendeskPluginHost.closeZendeskScreen)
                    )

                    if let nav = rootVC as? UINavigationController {
                        nav.pushViewController(viewController, animated: true)
                    } else if let nav = rootVC.navigationController {
                        nav.pushViewController(viewController, animated: true)
                    } else {
                        let nav = UINavigationController(rootViewController: viewController)
                        nav.modalPresentationStyle = .fullScreen
                        rootVC.present(nav, animated: true)
                    }
                    result(nil)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: ZendeskSdkErrorCodes.chatInitFailed,
                            message: error.localizedDescription,
                            details: nil
                        )
                    )
                }
            }
        }
    }

    func getUnreadMessageCount() -> ZendeskNativeResult<Int> {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount() ?? 0
        return .success(count)
    }

    func updatePushNotificationToken(token: String) -> ZendeskNativeResult<Void> {
        guard let tokenData = token.hexadecimalData ?? token.data(using: .utf8) else {
            return .failure(
                code: ZendeskSdkErrorCodes.invalidArguments,
                message: "pushToken must be a hex-encoded APNs device token or UTF-8 string"
            )
        }

        PushNotifications.updatePushNotificationToken(tokenData)
        return .success(())
    }

    func handlePushNotification(payload: [String: Any]) -> ZendeskNativeResult<Bool> {
        let userInfo = payload.reduce(into: [AnyHashable: Any]()) { partialResult, entry in
            partialResult[entry.key] = entry.value
        }

        switch PushNotifications.shouldBeDisplayed(userInfo) {
        case .messagingShouldDisplay:
            PushNotifications.handleTap(userInfo) { _ in }
            return .success(true)
        case .messagingShouldNotDisplay:
            return .success(true)
        case .notFromMessaging:
            return .success(false)
        @unknown default:
            return .success(false)
        }
    }

    private func applyMessagingVisitorInfo() {
        let user = session.user
        var fields: [String: String] = [:]
        if !user.name.isEmpty {
            fields["name"] = user.name
        }
        if !user.emailId.isEmpty {
            fields["email"] = user.emailId
        }
        if !fields.isEmpty {
            Zendesk.instance?.messaging?.setConversationFields(fields)
        }

        var tags: [String] = []
        if !user.userId.isEmpty {
            tags.append("user_id:\(user.userId)")
        }
        if !user.userType.isEmpty {
            tags.append("user_type:\(user.userType)")
        }
        if !tags.isEmpty {
            Zendesk.instance?.messaging?.setConversationTags(tags)
        }
    }
}

/// Host object for UI selectors presented by messaging/support handlers.
@objc protocol ZendeskPluginHost: AnyObject {
    @objc func closeZendeskScreen()
    @objc func dismissHelpCenter()
}

private extension String {
    var hexadecimalData: Data? {
        var data = Data()
        var temp = ""
        for character in self where character.isHexDigit {
            temp.append(character)
            if temp.count == 2 {
                guard let byte = UInt8(temp, radix: 16) else { return nil }
                data.append(byte)
                temp = ""
            }
        }
        return data.isEmpty ? nil : data
    }
}
