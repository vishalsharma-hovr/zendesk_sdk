import AnswerBotProvidersSDK
import AnswerBotSDK
import ChatProvidersSDK
import ChatSDK
import Flutter
import SupportProvidersSDK
import SupportSDK
import ZendeskCoreSDK
import ZendeskSDK

final class ZendeskLifecycleHandler: ZendeskLifecycleHandling {
    private let session: ZendeskSession

    init(session: ZendeskSession) {
        self.session = session
    }

    func initialize(config: ZendeskConfig, user: ZendeskUser) -> ZendeskNativeResult<Void> {
        Zendesk.initialize(
            appId: config.appId,
            clientId: config.clientId,
            zendeskUrl: config.url
        )

        Support.initialize(withZendesk: Zendesk.instance)
        let identity = Identity.createAnonymous(name: user.combinedName, email: user.emailId)
        Zendesk.instance?.setIdentity(identity)

        Chat.initialize(accountKey: config.clientId, appId: config.appId)
        AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)

        session.user = user
        session.isSupportInitialized = true
        return .success(())
    }

    func isInitialized() -> ZendeskNativeResult<Bool> {
        .success(session.isSupportInitialized)
    }

    func logoutAsync(result: @escaping FlutterResult) {
        Task {
            do {
                try await Zendesk.instance?.logoutUser()
                let clearedIdentity = Identity.createAnonymous(name: "", email: "")
                Zendesk.instance?.setIdentity(clearedIdentity)
                session.clear()
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
                        )
                    )
                }
            }
        }
    }

    func requireInitialized(result: @escaping FlutterResult) -> Bool {
        guard session.isSupportInitialized else {
            ZendeskNativeResult<Void>.failure(
                code: ZendeskSdkErrorCodes.notInitialized,
                message: "Call initialize() before using the Zendesk SDK"
            ).complete(result)
            return false
        }
        return true
    }
}
