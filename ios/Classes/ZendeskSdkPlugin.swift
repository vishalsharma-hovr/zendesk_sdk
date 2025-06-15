import Flutter
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
            showHelpCenterFullscreen(result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func showHelpCenterFullscreen(result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW",
                        message: "No root view controller found",
                        details: nil
                    ))
                return
            }

            // Configure Help Center for fullscreen presentation
            let helpCenterConfig = HelpCenterUiConfiguration()
            helpCenterConfig.showContactOptions = true

            let requestConfig = RequestUiConfiguration()

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