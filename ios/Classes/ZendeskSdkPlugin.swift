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
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let zendeskUrl = args["zendeskUrl"] as? String,
                  let appId = args["appId"] as? String,
                  let clientId = args["clientId"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
                return
            }

            // ✅ Initialize Zendesk
            Zendesk.initialize(appId: appId,
                               clientId: clientId,
                               zendeskUrl: zendeskUrl)

            // ✅ Initialize Support SDK
            Support.initialize(withZendesk: Zendesk.instance)

            // ✅ Set identity (anonymous for now)
            let identity = Identity.createAnonymous()
            Zendesk.instance?.setIdentity(identity)

            // ✅ Show Help Center UI
            DispatchQueue.main.async {
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                    let requestConfig = RequestUiConfiguration()
                    let helpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [requestConfig])
                    rootVC.present(helpCenter, animated: true, completion: nil)
                    result(nil)
                } else {
                    result(FlutterError(code: "NO_VIEW", message: "No root view controller found", details: nil))
                }
            }

        case "showHelpCenter":
            DispatchQueue.main.async {
                if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                    let requestConfig = RequestUiConfiguration()
                    let helpCenter = HelpCenterUi.buildHelpCenterOverviewUi(withConfigs: [requestConfig])
                    rootVC.present(helpCenter, animated: true, completion: nil)
                    result(nil)
                } else {
                    result(FlutterError(code: "NO_VIEW", message: "No root view controller found", details: nil))
                }
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
