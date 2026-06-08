package com.example.zendesk_sdk

import com.example.zendesk_sdk.commands.LogoutCommand
import com.example.zendesk_sdk.commands.StartChatCommand
import com.example.zendesk_sdk.commands.ZendeskCommandFactory
import com.example.zendesk_sdk.commands.ZendeskCommandParseResult
import com.example.zendesk_sdk.handlers.ZendeskLifecycleHandlerImpl
import com.example.zendesk_sdk.handlers.ZendeskMessagingHandlerImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Routes [MethodCall] to [ZendeskNativeService] via parsed commands (Command pattern).
class ZendeskMethodDispatcher(
    private val service: ZendeskNativeService,
    private val lifecycleHandler: ZendeskLifecycleHandlerImpl,
    private val messagingHandler: ZendeskMessagingHandlerImpl,
) {
    fun dispatch(call: MethodCall, result: MethodChannel.Result) {
        when (val parsed = ZendeskCommandFactory.parse(call)) {
            ZendeskCommandParseResult.NotImplemented -> result.notImplemented()
            ZendeskCommandParseResult.InvalidArguments -> result.error(
                ZendeskSdkErrorCodes.INVALID_ARGUMENTS,
                "Invalid or missing arguments for ${call.method}",
                null,
            )

            is ZendeskCommandParseResult.Success -> {
                val command = parsed.command
                when (command) {
                    is LogoutCommand -> lifecycleHandler.logoutAsync(result)
                    is StartChatCommand ->
                        messagingHandler.startChatAsync(command.channelId, result)
                    else -> service.execute(command).complete(result)
                }
            }
        }
    }
}
