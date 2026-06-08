import Flutter
import Foundation

/// Command contract mirroring Dart ZendeskCommand (Command pattern + OCP).
protocol ZendeskCommand {
    var methodName: String { get }
}

struct InitializeCommand: ZendeskCommand {
    let config: ZendeskConfig
    let user: ZendeskUser
    var methodName: String { ZendeskSdkChannel.Method.initialize }
}

struct LogoutCommand: ZendeskCommand {
    var methodName: String { ZendeskSdkChannel.Method.logout }
}

struct IsInitializedCommand: ZendeskCommand {
    var methodName: String { ZendeskSdkChannel.Method.isInitialized }
}

struct ShowHelpCenterCommand: ZendeskCommand {
    let categoryIdList: [NSNumber]
    var methodName: String { ZendeskSdkChannel.Method.showHelpCenter }
}

struct ShowHelpCenterArticleIdCommand: ZendeskCommand {
    let articleId: String
    var methodName: String { ZendeskSdkChannel.Method.showHelpCenterArticleId }
}

struct ShowHelpCenterCategoryIdCommand: ZendeskCommand {
    let categoryId: Int64
    var methodName: String { ZendeskSdkChannel.Method.showHelpCenterCategoryId }
}

struct SendUserInformationForTicketCommand: ZendeskCommand {
    let request: ZendeskTicketRequest
    var methodName: String { ZendeskSdkChannel.Method.sendUserInformationForTicket }
}

struct ShowListOfTicketsCommand: ZendeskCommand {
    var methodName: String { ZendeskSdkChannel.Method.showListOfTickets }
}

struct StartChatCommand: ZendeskCommand {
    let channelId: String
    var methodName: String { ZendeskSdkChannel.Method.startChat }
}

struct StartChatBotCommand: ZendeskCommand {
    var methodName: String { ZendeskSdkChannel.Method.startChatBot }
}

struct GetUnreadMessageCountCommand: ZendeskCommand {
    var methodName: String { ZendeskSdkChannel.Method.getUnreadMessageCount }
}

struct UpdatePushNotificationTokenCommand: ZendeskCommand {
    let token: String
    var methodName: String { ZendeskSdkChannel.Method.updatePushNotificationToken }
}

struct HandlePushNotificationCommand: ZendeskCommand {
    let payload: [String: Any]
    var methodName: String { ZendeskSdkChannel.Method.handlePushNotification }
}

enum ZendeskCommandParseResult {
    case success(ZendeskCommand)
    case invalidArguments
    case notImplemented
}

enum ZendeskCommandFactory {
    static func parse(call: FlutterMethodCall) -> ZendeskCommandParseResult {
        switch call.method {
        case ZendeskSdkChannel.Method.initialize:
            guard let config = ZendeskConfig.from(call: call) else {
                return .invalidArguments
            }
            return .success(InitializeCommand(config: config, user: ZendeskUser.from(call: call)))

        case ZendeskSdkChannel.Method.logout:
            return .success(LogoutCommand())

        case ZendeskSdkChannel.Method.isInitialized:
            return .success(IsInitializedCommand())

        case ZendeskSdkChannel.Method.showHelpCenter:
            guard let args = call.arguments as? [String: Any],
                  let categoryIdList = args[ZendeskSdkChannel.Argument.categoryIdList] as? [NSNumber] else {
                return .invalidArguments
            }
            return .success(ShowHelpCenterCommand(categoryIdList: categoryIdList))

        case ZendeskSdkChannel.Method.showHelpCenterArticleId:
            guard let args = call.arguments as? [String: Any],
                  let articleId = args[ZendeskSdkChannel.Argument.articleId] as? String,
                  !articleId.isEmpty,
                  Int64(articleId) != nil else {
                return .invalidArguments
            }
            return .success(ShowHelpCenterArticleIdCommand(articleId: articleId))

        case ZendeskSdkChannel.Method.showHelpCenterCategoryId:
            guard let args = call.arguments as? [String: Any],
                  let categoryIdRaw = args[ZendeskSdkChannel.Argument.categoryId] as? String,
                  let categoryId = Int64(categoryIdRaw) else {
                return .invalidArguments
            }
            return .success(ShowHelpCenterCategoryIdCommand(categoryId: categoryId))

        case ZendeskSdkChannel.Method.sendUserInformationForTicket:
            guard let request = ZendeskTicketRequest.from(call: call) else {
                return .invalidArguments
            }
            return .success(SendUserInformationForTicketCommand(request: request))

        case ZendeskSdkChannel.Method.showListOfTickets:
            return .success(ShowListOfTicketsCommand())

        case ZendeskSdkChannel.Method.startChat:
            guard let args = call.arguments as? [String: Any],
                  let channelId = args[ZendeskSdkChannel.Argument.channelId] as? String,
                  !channelId.isEmpty else {
                return .invalidArguments
            }
            return .success(StartChatCommand(channelId: channelId))

        case ZendeskSdkChannel.Method.startChatBot:
            return .success(StartChatBotCommand())

        case ZendeskSdkChannel.Method.getUnreadMessageCount:
            return .success(GetUnreadMessageCountCommand())

        case ZendeskSdkChannel.Method.updatePushNotificationToken:
            guard let args = call.arguments as? [String: Any],
                  let token = args[ZendeskSdkChannel.Argument.pushToken] as? String,
                  !token.isEmpty else {
                return .invalidArguments
            }
            return .success(UpdatePushNotificationTokenCommand(token: token))

        case ZendeskSdkChannel.Method.handlePushNotification:
            guard let args = call.arguments as? [String: Any],
                  let payload = args[ZendeskSdkChannel.Argument.pushNotificationData] as? [String: Any] else {
                return .invalidArguments
            }
            return .success(HandlePushNotificationCommand(payload: payload))

        default:
            return .notImplemented
        }
    }
}
