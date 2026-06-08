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
    // ✅ GLOBAL USER ID (same as Android)
    private var userId: String = ""

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
            guard let args = call.arguments as? [String: Any],
                  let zendeskUrl = args[ZendeskSdkChannel.Argument.zendeskUrl] as? String,
                  let appId = args[ZendeskSdkChannel.Argument.appId] as? String,
                  let clientId = args[ZendeskSdkChannel.Argument.clientId] as? String,
                  let name = args[ZendeskSdkChannel.Argument.name] as? String,
                  let emailId = args[ZendeskSdkChannel.Argument.emailId] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                return
            }
            userId = args[ZendeskSdkChannel.Argument.userId] as? String ?? ""
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
            result(nil)

        case ZendeskSdkChannel.Method.showHelpCenter:
            showHelpCenterFullscreen(result: result, call: call)

        case ZendeskSdkChannel.Method.sendUserInformationForTicket:
            sendUserInfomationForTicketCenterFullscreen(result: result, call: call)

        case ZendeskSdkChannel.Method.startChatBot:
            showAnswerBotFullscreen(result: result)

        case ZendeskSdkChannel.Method.showListOfTickets:
            showListOfTicketsFullscreen(result: result)

        case ZendeskSdkChannel.Method.startChat:
            guard let args = call.arguments as? [String: Any],
                  let channelId = args[ZendeskSdkChannel.Argument.channelId] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                return
            }
            startChat(channelId: channelId, result: result)

        case ZendeskSdkChannel.Method.showHelpCenterArticleId,
             ZendeskSdkChannel.Method.showHelpCenterCategoryId:
            result(FlutterMethodNotImplemented)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func showListOfTicketsFullscreen(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW",
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
    @objc private func closeZendeskScreen() {
        DispatchQueue.main.async {
            if let rootVC = self.getRootViewController(),
               let presented = rootVC.presentedViewController {
                presented.dismiss(animated: true, completion: nil)
            }
        }
    }
//    func startChat(channelId: String) {
//        DispatchQueue.main.async {
//            print("=============> Start chat")
//            do {
//                Zendesk.initialize(withChannelKey: channelId,
//                    messagingFactory: DefaultMessagingFactory()) { result in
//                    if case .success(_) = result {
//                        if let viewController = Zendesk.instance?.messaging?.messagingViewController(),
//                           let rootVC = self.getRootViewController() {
//                            if let navController = rootVC as? UINavigationController {
//                                navController.pushViewController(viewController, animated: true)
//                            } else {
//                                let navController = UINavigationController(rootViewController: viewController)
//                                navController.modalPresentationStyle = .fullScreen
//                                rootVC.present(navController, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                    if case let .failure(error) = result {
//                        print("Messaging did not initialize. Error: \(error.localizedDescription)")
//                    }
//                }
//            }
//            catch {
//                DispatchQueue.main.async {
//                    print("Failed to create chat engine: \(error)")
//                    // Optionally, present error to user
//                    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
//                        let alert = UIAlertController(title: "Chat Error", message: error.localizedDescription, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default))
//                        rootVC.present(alert, animated: true)
//                    }
//                }
//            }
////            // Chat configuration
////            let chatConfig = ChatConfiguration()
////            chatConfig.isAgentAvailabilityEnabled = false
////
////            // Visitor info
////            let visitorInfo = VisitorInfo(
////                name: name,
////                email: emailId,
////                phoneNumber: phoneNumber
////            )
////
////            // Providers config
////            let chatProviderConfig = ChatAPIConfiguration()
////            chatProviderConfig.visitorInfo = visitorInfo
////
////            Chat.instance?.configuration = chatProviderConfig
////
////            do {
////                // Messaging UI
////                let messagingConfiguration = MessagingConfiguration()
////                messagingConfiguration.name = "Chat Bot"
////                messagingConfiguration.isMultilineResponseOptionsEnabled = true
////
////                let chatConfiguration = ChatConfiguration()
////                chatConfiguration.isPreChatFormEnabled = true
////
////                // Build view controller
////                let chatEngine = try ChatEngine.engine()
////                let answerBotEngine = try AnswerBotEngine.engine()
////                let supportEngine = try SupportEngine.engine()
////                let viewController = try Messaging.instance.buildUI(engines: [answerBotEngine,chatEngine,supportEngine], configs: [messagingConfiguration, chatConfiguration])
////
////                // Present view controller
////                if let rootVC = self.getRootViewController() {
////
////                    let closeButton = UIBarButtonItem(
////                        barButtonSystemItem: .close,
////                        target: self,
////                        action: #selector(self.closeZendeskScreen)
////                    )
////
////                    viewController.navigationItem.leftBarButtonItem = closeButton
////
////                    if let navController = rootVC as? UINavigationController {
////                        navController.pushViewController(viewController, animated: true)
////                    } else {
////                        let navController = UINavigationController(rootViewController: viewController)
////                        navController.modalPresentationStyle = .fullScreen
////                        rootVC.present(navController, animated: true, completion: nil)
////                    }
////                }
////
////            } catch {
////                DispatchQueue.main.async {
////                    print("Failed to create chat engine: \(error)")
////                    // Optionally, present error to user
////                    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
////                        let alert = UIAlertController(title: "Chat Error", message: error.localizedDescription, preferredStyle: .alert)
////                        alert.addAction(UIAlertAction(title: "OK", style: .default))
////                        rootVC.present(alert, animated: true)
////                    }
////                }
////            }
//        }
//    }

    func startChat(channelId: String, result: @escaping FlutterResult) {
        Zendesk.initialize(
            withChannelKey: channelId,
            messagingFactory: DefaultMessagingFactory()
        ) { initResult in
            switch initResult {
            case .success:
                DispatchQueue.main.async {
                    guard
                        let viewController = Zendesk.instance?.messaging?.messagingViewController(),
                        let rootVC = self.getRootViewController()
                    else {
                        result(
                            FlutterError(
                                code: "NO_VIEW",
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
                            code: "CHAT_INIT_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        )
                    )
                }
            }
        }
    }
    
//    func getRootViewController() -> UIViewController? {
//        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
//            return nil
//        }
//        return window.rootViewController
//    }
    
    func showErrorAlert(message: String) {
        guard let rootVC = getRootViewController() else { return }
        
        let alert = UIAlertController(
            title: "Zendesk Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        rootVC.present(alert, animated: true)
    }
    
    private func sendUserInfomationForTicketCenterFullscreen(
        result: @escaping FlutterResult,
        call: FlutterMethodCall
    ) {
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW",
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            // Extract user info
            guard let args = call.arguments as? [String: Any],
                  let tripId = args[ZendeskSdkChannel.Argument.tripId] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required fields: name, userId, or tripId",
                        details: nil
                    )
                )
                return
            }
            // ✅ Create Request UI (ticket submission)
            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = ["user_id:\(self.userId)", "trip_id:\(tripId)"]
            let customFields = self.parseCustomFields(from: args)
            if !customFields.isEmpty {
                requestConfig.customFields = customFields
            }

            let requestVC = RequestUi.buildRequestUi(with: [requestConfig])
            let navController = UINavigationController(rootViewController: requestVC)
            navController.modalPresentationStyle = .fullScreen

            // Add close button
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

    private func showHelpCenterFullscreen(
        result: @escaping FlutterResult,
        call: FlutterMethodCall
    ) {
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW",
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }
            // Extract user info
            guard let args = call.arguments as? [String: Any],
                  let name = args[ZendeskSdkChannel.Argument.name] as? String,
                  let emailId = args[ZendeskSdkChannel.Argument.emailId] as? String,
                  let categoryIdList = args[ZendeskSdkChannel.Argument.categoryIdList] as? [NSNumber]
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required fields: name, userId, or tripId",
                        details: nil
                    )
                )
                return
            }
            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = ["user_id:\(self.userId)"]

            // Configure Help Center for fullscreen presentation
            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true
            helpCenterConfig.groupType = .category
            helpCenterConfig.groupIds = categoryIdList

            // Build Help Center UI
            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
                withConfigs: [helpCenterConfig, requestConfig]
            )

            // Create navigation controller for proper fullscreen presentation
            let navController = UINavigationController(rootViewController: helpCenterVC)
            navController.modalPresentationStyle = .fullScreen
            // Add close button to navigation bar
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
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW",
                        message: "No root view controller found",
                        details: nil
                    )
                )
                return
            }

            Support.initialize(withZendesk: Zendesk.instance)
            AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)

            do {
                // Prepare Zendesk engines and config
                let answerBotEngine = try AnswerBotEngine.engine()
                let messagingConfig = MessagingConfiguration()

                // Build the Messaging UI with AnswerBot
                let answerBotVC = try Messaging.instance.buildUI(
                    engines: [answerBotEngine],
                    configs: [messagingConfig]
                )

                // Embed in a navigation controller for fullscreen experience
                let navController = UINavigationController(rootViewController: answerBotVC)
                navController.modalPresentationStyle = .fullScreen
                navController.setNavigationBarHidden(false, animated: false)

                // Add close button
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
                        code: "ANSWERBOT_ERROR",
                        message: "Failed to launch Answer Bot",
                        details: error.localizedDescription
                    )
                )
            }
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
        // Updated method to get root view controller (keyWindow is deprecated)
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

