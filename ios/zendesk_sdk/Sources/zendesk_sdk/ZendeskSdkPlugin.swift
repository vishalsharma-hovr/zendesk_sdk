import Flutter
import UIKit

/// Thin plugin entry point: wires Flutter channel to ZendeskMethodDispatcher.
public class ZendeskSdkPlugin: NSObject, FlutterPlugin, ZendeskPluginHost {
    private var dispatcher: ZendeskMethodDispatcher!
    private let uiContext = ZendeskUiContext()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: ZendeskSdkChannel.name,
            binaryMessenger: registrar.messenger()
        )
        let instance = ZendeskSdkPlugin()
        instance.configure()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private func configure() {
        let session = ZendeskSession()
        let lifecycleHandler = ZendeskLifecycleHandler(session: session)
        let supportHandler = ZendeskSupportHandler(
            session: session,
            uiContext: uiContext,
            pluginHost: self,
            lifecycleHandler: lifecycleHandler
        )
        let messagingHandler = ZendeskMessagingHandler(
            session: session,
            uiContext: uiContext,
            pluginHost: self
        )
        let service = ZendeskNativeService(
            lifecycle: lifecycleHandler,
            messaging: messagingHandler
        )
        dispatcher = ZendeskMethodDispatcher(
            service: service,
            lifecycleHandler: lifecycleHandler,
            supportHandler: supportHandler,
            messagingHandler: messagingHandler
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        dispatcher.dispatch(call: call, result: result)
    }

    @objc public func closeZendeskScreen() {
        DispatchQueue.main.async {
            if let rootVC = self.uiContext.rootViewController(),
               let presented = rootVC.presentedViewController {
                presented.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc public func dismissHelpCenter() {
        DispatchQueue.main.async {
            if let rootVC = self.uiContext.rootViewController(),
               let presentedVC = rootVC.presentedViewController {
                presentedVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}
