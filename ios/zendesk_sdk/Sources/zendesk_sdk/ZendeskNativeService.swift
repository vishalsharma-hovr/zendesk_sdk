/// Native facade composing segregated handlers (DIP + Facade).
final class ZendeskNativeService {
    private let lifecycle: ZendeskLifecycleHandling
    private let messaging: ZendeskMessagingHandling

    init(lifecycle: ZendeskLifecycleHandling, messaging: ZendeskMessagingHandling) {
        self.lifecycle = lifecycle
        self.messaging = messaging
    }

    func execute(command: ZendeskCommand) -> Any {
        switch command {
        case let command as InitializeCommand:
            return lifecycle.initialize(config: command.config, user: command.user)
        case is IsInitializedCommand:
            return lifecycle.isInitialized()
        case is GetUnreadMessageCountCommand:
            return messaging.getUnreadMessageCount()
        case let command as UpdatePushNotificationTokenCommand:
            return messaging.updatePushNotificationToken(token: command.token)
        case let command as HandlePushNotificationCommand:
            return messaging.handlePushNotification(payload: command.payload)
        default:
            return ZendeskNativeResult<Void>.failure(
                code: ZendeskSdkErrorCodes.launchFailed,
                message: "Command requires async handler"
            )
        }
    }
}
