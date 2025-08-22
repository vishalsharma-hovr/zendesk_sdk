import AnswerBotProvidersSDK
import AnswerBotSDK
import Flutter
import MessagingAPI
import MessagingSDK
import SDKConfigurations
import SupportProvidersSDK
import SupportSDK
import UIKit
import ZendeskCoreSDK

public class ZendeskSdkPlugin: NSObject, FlutterPlugin {
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
                let clientId = args["clientId"] as? String
            else {
                result(
                    FlutterError(
                        code: "INVALID_ARGUMENTS",
                        message: "Missing required parameters",
                        details: nil
                    ))
                return
            }

            // Initialize Zendesk
            Zendesk.initialize(
                appId: appId,
                clientId: clientId,
                zendeskUrl: zendeskUrl
            )

            // Initialize Support SDK
            Support.initialize(withZendesk: Zendesk.instance)

            // Set identity (anonymous for now)
            let identity = Identity.createAnonymous()
            Zendesk.instance?.setIdentity(identity)

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

        default:
            result(FlutterMethodNotImplemented)
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
                let name = args["name"] as? String,
                let emailId = args["emailId"] as? String,
                let userId = args["userId"] as? String,
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

            // Combine user info into a single display name
            let combinedName = "\(name) | UserID: \(userId) | TripID: \(tripId)"

            // Set identity
            let identity = Identity.createAnonymous(name: combinedName, email: emailId)
            Zendesk.instance?.setIdentity(identity)

            // ✅ Create Request UI (ticket submission)
            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = ["user_id:\(userId)", "trip_id:\(tripId)"]
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

    //    private func sendUserInfomationForTicketCenterFullscreen(
    //        result: @escaping FlutterResult,
    //        call: FlutterMethodCall
    //    ) {
    //        DispatchQueue.main.async {
    //            guard let rootVC = self.getRootViewController() else {
    //                result(
    //                    FlutterError(
    //                        code: "NO_VIEW",
    //                        message: "No root view controller found",
    //                        details: nil
    //                    )
    //                )
    //                return
    //            }
    //
    //                // Extract user info
    //            guard let args = call.arguments as? [String: Any],
    //                  let name = args["name"] as? String,
    //                  let userId = args["userId"] as? String,
    //                  let tripId = args["tripId"] as? String else {
    //                result(
    //                    FlutterError(
    //                        code: "INVALID_ARGUMENTS",
    //                        message: "Missing required fields: name, userId, or tripId",
    //                        details: nil
    //                    )
    //                )
    //                return
    //            }
    //
    //                // ✅ Combine user info into a single display name
    //            let combinedName = "\(name) | UserID: \(userId) | TripID: \(tripId)"
    //
    //                // ✅ Set identity
    //            let identity = Identity.createAnonymous(name: combinedName, email: userId)
    //            Zendesk.instance?.setIdentity(identity)
    //
    //                // Configure Help Center
    //            let helpCenterConfig = HelpCenterUiConfiguration()
    //            helpCenterConfig.showContactOptions = true
    //
    //            let requestConfig = RequestUiConfiguration()
    //
    //            let helpCenterVC = HelpCenterUi.buildHelpCenterOverviewUi(
    //                withConfigs: [helpCenterConfig, requestConfig]
    //            )
    //
    //            let navController = UINavigationController(rootViewController: helpCenterVC)
    //            navController.modalPresentationStyle = .fullScreen
    //
    //            let closeButton = UIBarButtonItem(
    //                barButtonSystemItem: .done,
    //                target: self,
    //                action: #selector(self.dismissHelpCenter)
    //            )
    //            helpCenterVC.navigationItem.rightBarButtonItem = closeButton
    //
    //            rootVC.present(navController, animated: true) {
    //                result(nil)
    //            }
    //        }
    //    }

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
                let userId = args["userId"] as? String,
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
            // Combine user info into a single display name
            let combinedName = "\(name) | UserID: \(userId)"

            // Set identity
            let identity = Identity.createAnonymous(name: combinedName, email: emailId)
            Zendesk.instance?.setIdentity(identity)

            let requestConfig = RequestUiConfiguration()
            requestConfig.tags = ["user_id:\(userId)"]

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
