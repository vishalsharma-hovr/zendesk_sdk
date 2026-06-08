package com.example.zendesk_sdk.commands

import com.example.zendesk_sdk.ZendeskSdkChannel
import com.example.zendesk_sdk.models.ZendeskConfig
import com.example.zendesk_sdk.models.ZendeskTicketRequest
import com.example.zendesk_sdk.models.ZendeskUser
import io.flutter.plugin.common.MethodCall

/// Command contract mirroring Dart [ZendeskCommand] (Command pattern + OCP).
sealed interface ZendeskCommand {
    val methodName: String
}

data class InitializeCommand(
    val config: ZendeskConfig,
    val user: ZendeskUser,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.INITIALIZE
}

data object LogoutCommand : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.LOGOUT
}

data object IsInitializedCommand : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.IS_INITIALIZED
}

data class ShowHelpCenterCommand(
    val categoryIdList: List<Long>,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.SHOW_HELP_CENTER
}

data class ShowHelpCenterArticleIdCommand(
    val articleId: Long,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.SHOW_HELP_CENTER_ARTICLE_ID
}

data class ShowHelpCenterCategoryIdCommand(
    val categoryId: Long,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.SHOW_HELP_CENTER_CATEGORY_ID
}

data class SendUserInformationForTicketCommand(
    val request: ZendeskTicketRequest,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.SEND_USER_INFORMATION_FOR_TICKET
}

data object ShowListOfTicketsCommand : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.SHOW_LIST_OF_TICKETS
}

data class StartChatCommand(
    val channelId: String,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.START_CHAT
}

data object StartChatBotCommand : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.START_CHAT_BOT
}

data object GetUnreadMessageCountCommand : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.GET_UNREAD_MESSAGE_COUNT
}

data class UpdatePushNotificationTokenCommand(
    val token: String,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.UPDATE_PUSH_NOTIFICATION_TOKEN
}

data class HandlePushNotificationCommand(
    val payload: Map<String, String>,
) : ZendeskCommand {
    override val methodName: String = ZendeskSdkChannel.Method.HANDLE_PUSH_NOTIFICATION
}

sealed class ZendeskCommandParseResult {
    data class Success(val command: ZendeskCommand) : ZendeskCommandParseResult()
    data object InvalidArguments : ZendeskCommandParseResult()
    data object NotImplemented : ZendeskCommandParseResult()
}

object ZendeskCommandFactory {
    fun parse(call: MethodCall): ZendeskCommandParseResult {
        return when (call.method) {
            ZendeskSdkChannel.Method.INITIALIZE -> {
                val config = ZendeskConfig.fromMethodCall(call)
                    ?: return ZendeskCommandParseResult.InvalidArguments
                ZendeskCommandParseResult.Success(
                    InitializeCommand(config = config, user = ZendeskUser.fromMethodCall(call)),
                )
            }

            ZendeskSdkChannel.Method.LOGOUT ->
                ZendeskCommandParseResult.Success(LogoutCommand)

            ZendeskSdkChannel.Method.IS_INITIALIZED ->
                ZendeskCommandParseResult.Success(IsInitializedCommand)

            ZendeskSdkChannel.Method.SHOW_HELP_CENTER -> {
                val categoryIdList =
                    call.argument<List<Long>>(ZendeskSdkChannel.Argument.CATEGORY_ID_LIST)
                        ?: emptyList()
                ZendeskCommandParseResult.Success(
                    ShowHelpCenterCommand(categoryIdList = categoryIdList),
                )
            }

            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_ARTICLE_ID -> {
                val articleId = call.argument<String>(ZendeskSdkChannel.Argument.ARTICLE_ID)
                    ?.toLongOrNull()
                    ?: return ZendeskCommandParseResult.InvalidArguments
                ZendeskCommandParseResult.Success(
                    ShowHelpCenterArticleIdCommand(articleId = articleId),
                )
            }

            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_CATEGORY_ID -> {
                val categoryId = call.argument<String>(ZendeskSdkChannel.Argument.CATEGORY_ID)
                    ?.toLongOrNull()
                    ?: return ZendeskCommandParseResult.InvalidArguments
                ZendeskCommandParseResult.Success(
                    ShowHelpCenterCategoryIdCommand(categoryId = categoryId),
                )
            }

            ZendeskSdkChannel.Method.SEND_USER_INFORMATION_FOR_TICKET -> {
                val request = ZendeskTicketRequest.fromMethodCall(call)
                    ?: return ZendeskCommandParseResult.InvalidArguments
                ZendeskCommandParseResult.Success(
                    SendUserInformationForTicketCommand(request = request),
                )
            }

            ZendeskSdkChannel.Method.SHOW_LIST_OF_TICKETS ->
                ZendeskCommandParseResult.Success(ShowListOfTicketsCommand)

            ZendeskSdkChannel.Method.START_CHAT -> {
                val channelId = call.argument<String>(ZendeskSdkChannel.Argument.CHANNEL_ID)
                if (channelId.isNullOrBlank()) {
                    return ZendeskCommandParseResult.InvalidArguments
                }
                ZendeskCommandParseResult.Success(StartChatCommand(channelId = channelId))
            }

            ZendeskSdkChannel.Method.START_CHAT_BOT ->
                ZendeskCommandParseResult.Success(StartChatBotCommand)

            ZendeskSdkChannel.Method.GET_UNREAD_MESSAGE_COUNT ->
                ZendeskCommandParseResult.Success(GetUnreadMessageCountCommand)

            ZendeskSdkChannel.Method.UPDATE_PUSH_NOTIFICATION_TOKEN -> {
                val token = call.argument<String>(ZendeskSdkChannel.Argument.PUSH_TOKEN)
                if (token.isNullOrBlank()) {
                    return ZendeskCommandParseResult.InvalidArguments
                }
                ZendeskCommandParseResult.Success(
                    UpdatePushNotificationTokenCommand(token = token),
                )
            }

            ZendeskSdkChannel.Method.HANDLE_PUSH_NOTIFICATION -> {
                @Suppress("UNCHECKED_CAST")
                val payload = call.argument<Map<String, Any>>(
                    ZendeskSdkChannel.Argument.PUSH_NOTIFICATION_DATA,
                ) ?: emptyMap()
                ZendeskCommandParseResult.Success(
                    HandlePushNotificationCommand(
                        payload = payload.mapValues { it.value.toString() },
                    ),
                )
            }

            else -> ZendeskCommandParseResult.NotImplemented
        }
    }
}
