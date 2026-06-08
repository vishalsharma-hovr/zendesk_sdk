package com.example.zendesk_sdk.platform

import com.example.zendesk_sdk.result.ZendeskResult

/// Messaging SDK operations: chat, unread count, push (ISP).
interface ZendeskMessagingHandler {
    fun startChat(channelId: String): ZendeskResult<Unit>
    fun getUnreadMessageCount(): ZendeskResult<Int>
    fun updatePushNotificationToken(token: String): ZendeskResult<Unit>
    fun handlePushNotification(payload: Map<String, String>): ZendeskResult<Boolean>
}
