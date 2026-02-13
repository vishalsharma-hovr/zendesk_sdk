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

public class ZendeskSdkPlugin: NSObject, FlutterPlugin {
    // ✅ GLOBAL USER ID (same as Android)
    private var userId: String = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "zendesk_sdk",
            binaryMessenger: registrar.messenger()
        )
        let instance = ZendeskSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let zendeskUrl = args["zendeskUrl"] as? String,
                  let appId = args["appId"] as? String,
                  let clientId = args["clientId"] as? String,
                  let name = args["name"] as? String,
                  let emailId = args["emailId"] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                return
            }
            // ✅ STORE USER ID ONCE
            userId = args["userId"] as? String ?? ""
            // Initialize Zendesk
            Zendesk.initialize(
                appId: appId,
                clientId: clientId,
                zendeskUrl: zendeskUrl
            )

            // Initialize Support SDK
            Support.initialize(withZendesk: Zendesk.instance)
            let combinedName = "\(name) | UserID: \(userId)"
            // Set identity (anonymous for now)
            let identity = Identity.createAnonymous(name: combinedName, email: emailId)
            Zendesk.instance?.setIdentity(identity)
                
            Chat.initialize(accountKey: clientId, appId: appId)
            AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
            result(nil)

        case "showHelpCenter":
            showHelpCenterFullscreen(result: result, call: call)
            result(nil)

        case "sendUserInformationForTicket":
            sendUserInfomationForTicketCenterFullscreen(result: result, call: call)
            result(nil)

        case "startChatBot":
            showAnswerBotFullscreen(result: result)
            result(nil)

        case "showListOfTickets":
            showListOfTicketsFullscreen()
            result(nil)

        case "startChat":
            guard let args = call.arguments as? [String: Any],
                  let name = args["name"] as? String,
                  let emailId = args["emailId"] as? String,
                  let phoneNumber = args["phoneNumber"] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                return
            }
            startChat(name: name, emailId: emailId, phoneNumber: phoneNumber)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func showListOfTicketsFullscreen() {
        DispatchQueue.main.async {
            let requestListController = RequestUi.buildRequestList()
            if let rootVC = self.getRootViewController() {
                if let navController = rootVC as? UINavigationController {
                    navController.pushViewController(requestListController, animated: true)
                } else {
                    let navController = UINavigationController(rootViewController: requestListController)
                    navController.modalPresentationStyle = .fullScreen
                    rootVC.present(navController, animated: true, completion: nil)
                }
            } else {
                print("No root view controller found to show ticket list.")
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
    func startChat(name: String, emailId: String, phoneNumber: String) {
        DispatchQueue.main.async {
            print("=============> Start chat")

            // Chat configuration
            let chatConfig = ChatConfiguration()
            chatConfig.isAgentAvailabilityEnabled = false

            // Visitor info
            let visitorInfo = VisitorInfo(
                name: name,
                email: emailId,
                phoneNumber: phoneNumber
            )

            // Providers config
            let chatProviderConfig = ChatAPIConfiguration()
            chatProviderConfig.visitorInfo = visitorInfo

            Chat.instance?.configuration = chatProviderConfig

            do {
                // Messaging UI
                let messagingConfiguration = MessagingConfiguration()
                messagingConfiguration.name = "Chat Bot"
                messagingConfiguration.isMultilineResponseOptionsEnabled = true

                let chatConfiguration = ChatConfiguration()
                chatConfiguration.isPreChatFormEnabled = true

                // Build view controller
                let chatEngine = try ChatEngine.engine()
                let answerBotEngine = try AnswerBotEngine.engine()
                let supportEngine = try SupportEngine.engine()
                let viewController = try Messaging.instance.buildUI(engines: [answerBotEngine,chatEngine,supportEngine], configs: [messagingConfiguration, chatConfiguration])

                // Present view controller
                if let rootVC = self.getRootViewController() {
                    
                    let closeButton = UIBarButtonItem(
                        barButtonSystemItem: .close,
                        target: self,
                        action: #selector(self.closeZendeskScreen)
                    )
                    
                    viewController.navigationItem.leftBarButtonItem = closeButton
                    
                    if let navController = rootVC as? UINavigationController {
                        navController.pushViewController(viewController, animated: true)
                    } else {
                        let navController = UINavigationController(rootViewController: viewController)
                        navController.modalPresentationStyle = .fullScreen
                        rootVC.present(navController, animated: true, completion: nil)
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    print("Failed to create chat engine: \(error)")
                    // Optionally, present error to user
                    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                        let alert = UIAlertController(title: "Chat Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        rootVC.present(alert, animated: true)
                    }
                }
            }
        }
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
                  let tripId = args["tripId"] as? String
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
            //       requestConfig.subject = "Trip Support Request"

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
                  let name = args["name"] as? String,
                  let emailId = args["emailId"] as? String,
                  let categoryIdList = args["categoryIdList"] as? [NSNumber]
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
