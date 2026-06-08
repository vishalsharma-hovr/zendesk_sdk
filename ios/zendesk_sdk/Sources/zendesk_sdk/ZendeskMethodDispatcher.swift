import Flutter

/// Routes FlutterMethodCall to ZendeskNativeService via parsed commands (Command pattern).
final class ZendeskMethodDispatcher {
    private let service: ZendeskNativeService
    private let lifecycleHandler: ZendeskLifecycleHandler
    private let supportHandler: ZendeskSupportHandler
    private let messagingHandler: ZendeskMessagingHandler

    init(
        service: ZendeskNativeService,
        lifecycleHandler: ZendeskLifecycleHandler,
        supportHandler: ZendeskSupportHandler,
        messagingHandler: ZendeskMessagingHandler
    ) {
        self.service = service
        self.lifecycleHandler = lifecycleHandler
        self.supportHandler = supportHandler
        self.messagingHandler = messagingHandler
    }

    func dispatch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch ZendeskCommandFactory.parse(call: call) {
        case .notImplemented:
            result(FlutterMethodNotImplemented)

        case .invalidArguments:
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.invalidArguments,
                    message: "Invalid or missing arguments for \(call.method)",
                    details: nil
                )
            )

        case .success(let command):
            switch command {
            case is LogoutCommand:
                lifecycleHandler.logoutAsync(result: result)

            case let command as StartChatCommand:
                messagingHandler.startChatAsync(channelId: command.channelId, result: result)

            case let command as ShowHelpCenterCommand:
                supportHandler.showHelpCenterAsync(
                    categoryIdList: command.categoryIdList,
                    result: result
                )

            case let command as ShowHelpCenterArticleIdCommand:
                supportHandler.showHelpCenterArticleIdAsync(
                    articleId: command.articleId,
                    result: result
                )

            case let command as ShowHelpCenterCategoryIdCommand:
                supportHandler.showHelpCenterCategoryIdAsync(
                    categoryId: command.categoryId,
                    result: result
                )

            case let command as SendUserInformationForTicketCommand:
                supportHandler.sendUserInformationForTicketAsync(
                    request: command.request,
                    result: result
                )

            case is ShowListOfTicketsCommand:
                supportHandler.showListOfTicketsAsync(result: result)

            case is StartChatBotCommand:
                supportHandler.startChatBotAsync(result: result)

            default:
                complete(service.execute(command: command), result: result)
            }
        }
    }

    private func complete(_ value: Any, result: @escaping FlutterResult) {
        switch value {
        case let value as ZendeskNativeResult<Void>:
            value.complete(result)
        case let value as ZendeskNativeResult<Bool>:
            value.complete(result)
        case let value as ZendeskNativeResult<Int>:
            value.complete(result)
        default:
            result(
                FlutterError(
                    code: ZendeskSdkErrorCodes.launchFailed,
                    message: "Unhandled command result",
                    details: nil
                )
            )
        }
    }
}
