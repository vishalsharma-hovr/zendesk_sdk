import Flutter
import UIKit
import ZendeskCoreSDK
import SupportSDK

public class ZendeskSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zendesk_sdk", binaryMessenger: registrar.messenger())
        let instance = ZendeskSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController else {
            result(FlutterError(code: "NO_VIEW", message: "RootViewController is not FlutterViewController", details: nil))
            return
        }

        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let zendeskUrl = args["zendeskUrl"] as? String,
                  let appId = args["appId"] as? String,
                  let clientId = args["clientId"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parameters", details: nil))
                return
            }

            Zendesk.initialize(appId: appId, clientId: clientId, zendeskUrl: zendeskUrl)
            Support.initialize(withZendesk: Zendesk.instance)

            let identity = Identity.createAnonymous()
            Zendesk.instance?.setIdentity(identity)

            // Show Help Center after initialization
            showHelpCenter(from: controller, result: result)

        case "showHelpCenter":
            showHelpCenter(from: controller, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // ✅ Helper method to present the Help Center
    private func showHelpCenter(from controller: FlutterViewController, result: @escaping FlutterResult) {
        DispatchQueue.main.async {
            let helpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [])
            let navController = UINavigationController(rootViewController: helpCenter)
            navController.modalPresentationStyle = .fullScreen
            controller.present(navController, animated: true) {
                result(nil)
            }
        }
    }
}
