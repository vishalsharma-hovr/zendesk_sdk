package com.example.zendesk_sdk

import com.example.zendesk_sdk.commands.GetUnreadMessageCountCommand
import com.example.zendesk_sdk.commands.HandlePushNotificationCommand
import com.example.zendesk_sdk.commands.InitializeCommand
import com.example.zendesk_sdk.commands.IsInitializedCommand
import com.example.zendesk_sdk.commands.LogoutCommand
import com.example.zendesk_sdk.commands.SendUserInformationForTicketCommand
import com.example.zendesk_sdk.commands.ShowHelpCenterArticleIdCommand
import com.example.zendesk_sdk.commands.ShowHelpCenterCategoryIdCommand
import com.example.zendesk_sdk.commands.ShowHelpCenterCommand
import com.example.zendesk_sdk.commands.ShowListOfTicketsCommand
import com.example.zendesk_sdk.commands.StartChatBotCommand
import com.example.zendesk_sdk.commands.StartChatCommand
import com.example.zendesk_sdk.commands.UpdatePushNotificationTokenCommand
import com.example.zendesk_sdk.commands.ZendeskCommand
import com.example.zendesk_sdk.platform.ZendeskLifecycleHandler
import com.example.zendesk_sdk.platform.ZendeskMessagingHandler
import com.example.zendesk_sdk.platform.ZendeskSupportHandler
import com.example.zendesk_sdk.result.ZendeskResult

/// Native facade composing segregated handlers (DIP + Facade).
class ZendeskNativeService(
    private val lifecycle: ZendeskLifecycleHandler,
    private val support: ZendeskSupportHandler,
    private val messaging: ZendeskMessagingHandler,
) {
    fun execute(command: ZendeskCommand): ZendeskResult<*> {
        return when (command) {
            is InitializeCommand -> lifecycle.initialize(command.config, command.user)
            is LogoutCommand -> lifecycle.logout()
            is IsInitializedCommand -> lifecycle.isInitialized()
            is ShowHelpCenterCommand -> support.showHelpCenter(command.categoryIdList)
            is ShowHelpCenterArticleIdCommand ->
                support.showHelpCenterArticleId(command.articleId)
            is ShowHelpCenterCategoryIdCommand ->
                support.showHelpCenterCategoryId(command.categoryId)
            is SendUserInformationForTicketCommand ->
                support.sendUserInformationForTicket(command.request)
            is ShowListOfTicketsCommand -> support.showListOfTickets()
            is StartChatBotCommand -> support.startChatBot()
            is StartChatCommand -> messaging.startChat(command.channelId)
            is GetUnreadMessageCountCommand -> messaging.getUnreadMessageCount()
            is UpdatePushNotificationTokenCommand ->
                messaging.updatePushNotificationToken(command.token)
            is HandlePushNotificationCommand ->
                messaging.handlePushNotification(command.payload)
        }
    }
}
