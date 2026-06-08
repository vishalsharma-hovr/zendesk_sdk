import AnswerBotProvidersSDK
import AnswerBotSDK
import ChatProvidersSDK
import ChatSDK
import Flutter
import MessagingAPI
import MessagingSDK
import SDKConfigurations
import SupportProvidersSDK
import SupportSDK
import UIKit
import ZendeskCoreSDK
import ZendeskSDKMessaging
import ZendeskSDK

public class ZendeskSdkPlugin: NSObject, FlutterPlugin {
    private var userId: String = ""
    private var userType: String = ""
    private var visitorName: String = ""
    private var visitorEmail: String = ""
    private var isSupportInitialized = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: ZendeskSdkChannel.name,
            binaryMessenger: registrar.messenger()
        )
        let instance = ZendeskSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case ZendeskSdkChannel.Method.initialize:
            initialize(call: call, result: result)
        case ZendeskSdkChannel.Method.logout:
            logout(result: result)
        case ZendeskSdkChannel.Method.isInitialized:
            result(isSupportInitialized)
        case ZendeskSdkChannel.Method.showHelpCenter:
            showHelpCenter(result: result, call: call)
        case ZendeskSdkChannel.Method.showHelpCenterArticleId:
            showHelpCenterArticleId(call: call, result: result)
        case ZendeskSdkChannel.Method.showHelpCenterCategoryId:
            showHelpCenterCategoryId(call: call, result: result)
        case ZendeskSdkChannel.Method.sendUserInformationForTicket:
            sendUserInformationForTicket(result: result, call: call)
        case ZendeskSdkChannel.Method.startChatBot:
            showAnswerBotFullscreen(result: result)
        case ZendeskSdkChannel.Method.showListOfTickets:
            showListOfTicketsFullscreen(result: result)
        case ZendeskSdkChannel.Method.startChat:
            startChat(call: call, result: result)
        case ZendeskSdkChannel.Method.getUnreadMessageCount:
            getUnreadMessageCount(result: result)
        case ZendeskSdkChannel.Method.updatePushNotificationToken:
            updatePushNotificationToken(call: call, result: result)
        case ZendeskSdkChannel.Method.handlePushNotification:
            handlePushNotification(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let zendeskUrl = args[ZendeskSdkChannel.Argument.zendeskUrl] as? String,
              let appId = args[ZendeskSdkChannel.Argument.appId] as? String,
              let clientId = args[ZendeskSdkChannel.Argument.clientId] as? String,
              let name = args[ZendeskSdkChannel.Argument.name] as? String,
              let emailId = args[ZendeskSdkChannel.Argument.emailId] as? String
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "Missing required parameters",
                    details: nil
                ))
            return
        }

        userId = args[ZendeskSdkChannel.Argument.userId] as? String ?? ""
        userType = args[ZendeskSdkChannel.Argument.userType] as? String ?? ""
        visitorName = name
        visitorEmail = emailId

        Zendesk.initialize(
            appId: appId,
            clientId: clientId,
            zendeskUrl: zendeskUrl
        )

        Support.initialize(withZendesk: Zendesk.instance)
        let combinedName = "\(name) | UserID: \(userId)"
        let identity = Identity.createAnonymous(name: combinedName, email: emailId)
        Zendesk.instance?.setIdentity(identity)

        Chat.initialize(accountKey: clientId, appId: appId)
        AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
        isSupportInitialized = true
        result(nil)
    }

    private func logout(result: @escaping FlutterResult) {
        Task {
            do {
                try await Zendesk.instance?.logoutUser()
                let clearedIdentity = Identity.createAnonymous(name: "", email: "")
                Zendesk.instance?.setIdentity(clearedIdentity)
                userId = ""
                userType = ""
                visitorName = ""
                visitorEmail = ""
                isSupportInitialized = false
                DispatchQueue.main.async {
                    result(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    result(
                        FlutterError(
                            code: ZendeskSdkErrorCodes.logoutFailed,
                            message: error.localizedDescription,
                            details: nil
                        ))
                }
            }
        }
    }

    private func requireInitialized(result: @escaping FlutterResult) -> Bool {
        guard isSupportInitialized else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.notInitialized,
                    message: "Call initialize() before using the Zendesk SDK",
                    details: nil
                ))
            return false
        }
        return true
    }

    private func baseTags(tripId: String? = nil) -> [String] {
        var tags = ["user_id:\(userId)", "mobile_app"]
        if !userType.isEmpty {
            tags.append("user_type:\(userType)")
        }
        if let tripId, !tripId.isEmpty {
            tags.append("trip_id:\(tripId)")
        }
        return tags
    }

    private func applyMessagingVisitorInfo() {
        var fields: [String: String] = [:]
        if !visitorName.isEmpty {
            fields["name"] = visitorName
        }
        if !visitorEmail.isEmpty {
            fields["email"] = visitorEmail
        }
        if !fields.isEmpty {
            Zendesk.instance?.messaging?.setConversationFields(fields)
        }

        var tags: [String] = []
        if !userId.isEmpty {
            tags.append("user_id:\(userId)")
        }
        if !userType.isEmpty {
            tags.append("user_type:\(userType)")
        }
        if !tags.isEmpty {
            Zendesk.instance?.messaging?.setConversationTags(tags)
        }
    }

    private func showListOfTicketsFullscreen(result: @escaping FlutterResult) {
        guard requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            let requestListController = RequestUi.buildRequestList()
            if let navController = rootVC as? UINavigationController {
                navController.pushViewController(requestListController, animated: true)
            } else {
                let navController = UINavigationController(rootViewController: requestListController)
                navController.modalPresentationStyle = .fullScreen
                rootVC.present(navController, animated: true, completion: nil)
            }
            result(nil)
        }
    }

    private func startChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let channelId = args[ZendeskSdkChannel.Argument.channelId] as? String,
              !channelId.isEmpty
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "Missing channelId",
                    details: nil
                ))
            return
        }

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
                        let rootVC = self.getRootViewController()
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
                        target: self,
                        action: #selector(self.closeZendeskScreen)
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

    @objc private func closeZendeskScreen() {
        DispatchQueue.main.async {
            if let rootVC = self.getRootViewController(),
               let presented = rootVC.presentedViewController {
                presented.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func sendUserInformationForTicket(
        result: @escaping FlutterResult,
        call: FlutterMethodCall
    ) {
        guard requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            guard let args = call.arguments as? [String: Any],
                  let tripId = args[ZendeskSdkChannel.Argument.tripId] as? String
            else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.invalidArguments,
                        message: "Missing required fields: tripId",
                        details: nil
                    )
                )
                return
            }

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = self.baseTags(tripId: tripId)
            let customFields = self.parseCustomFields(from: args)
            if !customFields.isEmpty {
                requestConfig.customFields = customFields
            }

            let requestVC = RequestUi.buildRequestUi(with: [requestConfig])
            let navController = UINavigationController(rootViewController: requestVC)
            navController.modalPresentationStyle = .fullScreen

            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.dismissHelpCenter)
            )
            requestVC.navigationItem.rightBarButtonItem = closeButton

            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    private func showHelpCenterArticleId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard requireInitialized(result: result) else { return }

        guard let args = call.arguments as? [String: Any],
              let articleIdRaw = args[ZendeskSdkChannel.Argument.articleId] as? String,
              let articleId = Int64(articleIdRaw)
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "articleId must be a numeric article ID",
                    details: nil
                ))
            return
        }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            let articleVC = HelpCenterUi.buildHelpCenterArticleUi(withArticleId: NSNumber(value: articleId))
            let navController = UINavigationController(rootViewController: articleVC)
            navController.modalPresentationStyle = .fullScreen
            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    private func showHelpCenterCategoryId(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard requireInitialized(result: result) else { return }

        guard let args = call.arguments as? [String: Any],
              let categoryIdRaw = args[ZendeskSdkChannel.Argument.categoryId] as? String,
              let categoryId = Int64(categoryIdRaw)
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "categoryId must be a numeric category ID",
                    details: nil
                ))
            return
        }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = self.baseTags()

            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true
            helpCenterConfig.groupType = .category
            helpCenterConfig.groupIds = [NSNumber(value: categoryId)]

            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
                withConfigs: [helpCenterConfig, requestConfig]
            )

            let navController = UINavigationController(rootViewController: helpCenterVC)
            navController.modalPresentationStyle = .fullScreen

            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.dismissHelpCenter)
            )
            helpCenterVC.navigationItem.rightBarButtonItem = closeButton
            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    private func showHelpCenter(
        result: @escaping FlutterResult,
        call: FlutterMethodCall
    ) {
        guard requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            guard let args = call.arguments as? [String: Any],
                  let categoryIdList = args[ZendeskSdkChannel.Argument.categoryIdList] as? [NSNumber]
            else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.invalidArguments,
                        message: "Missing required fields: categoryIdList",
                        details: nil
                    )
                )
                return
            }

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = self.baseTags()

            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true
            helpCenterConfig.groupType = .category
            helpCenterConfig.groupIds = categoryIdList

            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
                withConfigs: [helpCenterConfig, requestConfig]
            )

            let navController = UINavigationController(rootViewController: helpCenterVC)
            navController.modalPresentationStyle = .fullScreen

            let closeButton = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.dismissHelpCenter)
            )
            helpCenterVC.navigationItem.rightBarButtonItem = closeButton
            rootVC.present(navController, animated: true) {
                result(nil)
            }
        }
    }

    private func showAnswerBotFullscreen(result: @escaping FlutterResult) {
        guard requireInitialized(result: result) else { return }

        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.noUiContext,
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            Support.initialize(withZendesk: Zendesk.instance)
            AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)

            do {
                let answerBotEngine = try AnswerBotEngine.engine()
                let messagingConfig = MessagingConfiguration()

                let answerBotVC = try Messaging.instance.buildUI(
                    engines: [answerBotEngine],
                    configs: [messagingConfig]
                )

                let navController = UINavigationController(rootViewController: answerBotVC)
                navController.modalPresentationStyle = .fullScreen
                navController.setNavigationBarHidden(false, animated: false)

                let closeButton = UIBarButtonItem(
                    barButtonSystemItem: .done,
                    target: self,
                    action: #selector(self.dismissHelpCenter)
                )
                answerBotVC.navigationItem.rightBarButtonItem = closeButton

                rootVC.present(navController, animated: true) {
                    result(nil)
                }
            } catch {
                result(
                    FlutterError(
                        code: ZendeskSdkErrorCodes.answerBotError,
                        message: "Failed to launch Answer Bot",
                        details: error.localizedDescription
                    )
                )
            }
        }
    }

    private func getUnreadMessageCount(result: @escaping FlutterResult) {
        let count = Zendesk.instance?.messaging?.getUnreadMessageCount() ?? 0
        result(count)
    }

    private func updatePushNotificationToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let token = args[ZendeskSdkChannel.Argument.pushToken] as? String,
              !token.isEmpty
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "Missing push token",
                    details: nil
                ))
            return
        }

        guard let tokenData = token.hexadecimalData ?? token.data(using: .utf8) else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "pushToken must be a hex-encoded APNs device token or UTF-8 string",
                    details: nil
                ))
            return
        }

        PushNotifications.updatePushNotificationToken(tokenData)
        result(nil)
    }

    private func handlePushNotification(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let payload = args[ZendeskSdkChannel.Argument.pushNotificationData] as? [String: Any]
        else {
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "Missing push notification payload",
                    details: nil
                ))
            return
        }

        let userInfo = payload.reduce(into: [AnyHashable: Any]()) { partialResult, entry in
            partialResult[entry.key] = entry.value
        }

        switch PushNotifications.shouldBeDisplayed(userInfo) {
        case .messagingShouldDisplay:
            PushNotifications.handleTap(userInfo) { _ in }
            result(true)
        case .messagingShouldNotDisplay:
            result(true)
        case .notFromMessaging:
            result(false)
        @unknown default:
            result(false)
        }
    }

    @objc private func dismissHelpCenter() {
        DispatchQueue.main.async {
            if let rootVC = self.getRootViewController(),
               let presentedVC = rootVC.presentedViewController
            {
                presentedVC.dismiss(animated: true, completion: nil)
            }
        }
    }

    private func parseCustomFields(from args: [String: Any]) -> [CustomField] {
        guard let customFieldsArg = args[ZendeskSdkChannel.Argument.customFields] as? [[String: Any]] else {
            return []
        }

        return customFieldsArg.compactMap { field in
            guard let fieldIdNumber = field[ZendeskSdkChannel.Argument.fieldId] as? NSNumber,
                  let value = field[ZendeskSdkChannel.Argument.value] as? String else {
                return nil
            }
            return CustomField(fieldId: fieldIdNumber.int64Value, value: value)
        }
    }

    private func getRootViewController() -> UIViewController? {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first
            else {
                return nil
            }
            return window.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
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
