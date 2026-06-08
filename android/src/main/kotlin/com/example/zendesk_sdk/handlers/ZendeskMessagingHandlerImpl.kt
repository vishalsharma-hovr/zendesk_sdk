package com.example.zendesk_sdk.handlers

import android.util.Log
import com.example.zendesk_sdk.ZendeskSdkErrorCodes
import com.example.zendesk_sdk.platform.ZendeskMessagingHandler
import com.example.zendesk_sdk.platform.ZendeskUiContext
import com.example.zendesk_sdk.result.ZendeskResult
import com.example.zendesk_sdk.session.ZendeskSession
import io.flutter.plugin.common.MethodChannel
import zendesk.messaging.android.DefaultMessagingFactory
import zendesk.messaging.android.push.PushNotifications
import zendesk.messaging.android.push.PushResponsibility
import zendesk.android.Zendesk as ZendeskMessaging

class ZendeskMessagingHandlerImpl(
    private val session: ZendeskSession,
    private val uiContext: ZendeskUiContext,
) : ZendeskMessagingHandler {

    override fun startChat(channelId: String): ZendeskResult<Unit> {
        return ZendeskResult.Failure(
            ZendeskSdkErrorCodes.CHAT_ENGINE_FAILED,
            "Use startChatAsync() for startChat",
        )
    }

    fun startChatAsync(channelId: String, result: MethodChannel.Result) {
        val currentActivity = uiContext.currentActivity()
        if (currentActivity == null) {
            ZendeskResult.Failure(
                ZendeskSdkErrorCodes.NO_UI_CONTEXT,
                "No activity attached",
            ).complete(result)
            return
        }

        try {
            ZendeskMessaging.initialize(
                context = currentActivity,
                channelKey = channelId,
                successCallback = { zendesk ->
                    session.messagingZendesk = zendesk
                    applyMessagingVisitorInfo(zendesk)
                    zendesk.messaging.showMessaging(currentActivity)
                    ZendeskResult.Success(Unit).complete(result)
                },
                failureCallback = { error ->
                    ZendeskResult.Failure(
                        ZendeskSdkErrorCodes.CHAT_INIT_FAILED,
                        error.message,
                    ).complete(result)
                },
                messagingFactory = DefaultMessagingFactory(),
            )
        } catch (e: Exception) {
            ZendeskResult.Failure(
                ZendeskSdkErrorCodes.CHAT_ENGINE_FAILED,
                e.localizedMessage,
            ).complete(result)
        }
    }

    override fun getUnreadMessageCount(): ZendeskResult<Int> {
        return try {
            val count = session.messagingZendesk?.messaging?.getUnreadMessageCount()
                ?: ZendeskMessaging.instance?.messaging?.getUnreadMessageCount()
                ?: 0
            ZendeskResult.Success(count)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.UNREAD_COUNT_FAILED, e.localizedMessage)
        }
    }

    override fun updatePushNotificationToken(token: String): ZendeskResult<Unit> {
        return try {
            PushNotifications.updatePushNotificationToken(token)
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.PUSH_TOKEN_FAILED, e.localizedMessage)
        }
    }

    override fun handlePushNotification(payload: Map<String, String>): ZendeskResult<Boolean> {
        return try {
            when (PushNotifications.shouldBeDisplayed(payload)) {
                PushResponsibility.MESSAGING_SHOULD_DISPLAY -> {
                    PushNotifications.displayNotification(
                        uiContext.applicationContext(),
                        payload,
                    )
                    ZendeskResult.Success(true)
                }

                PushResponsibility.MESSAGING_SHOULD_NOT_DISPLAY -> ZendeskResult.Success(true)

                PushResponsibility.NOT_FROM_MESSAGING -> ZendeskResult.Success(false)

                else -> ZendeskResult.Success(false)
            }
        } catch (e: Exception) {
            ZendeskResult.Failure(ZendeskSdkErrorCodes.PUSH_NOTIFICATION_FAILED, e.localizedMessage)
        }
    }

    private fun applyMessagingVisitorInfo(zendesk: ZendeskMessaging) {
        val user = session.user
        val fields = mutableMapOf<String, String>()
        if (user.name.isNotBlank()) {
            fields["name"] = user.name
        }
        if (user.emailId.isNotBlank()) {
            fields["email"] = user.emailId
        }
        if (fields.isNotEmpty()) {
            try {
                zendesk.messaging.setConversationFields(fields)
            } catch (e: Exception) {
                Log.w("ZENDESK", "Unable to set conversation fields: ${e.message}")
            }
        }

        val tags = mutableListOf<String>()
        if (user.userId.isNotBlank()) {
            tags.add("user_id:${user.userId}")
        }
        if (user.userType.isNotBlank()) {
            tags.add("user_type:${user.userType}")
        }
        if (tags.isNotEmpty()) {
            try {
                zendesk.messaging.setConversationTags(tags)
            } catch (e: Exception) {
                Log.w("ZENDESK", "Unable to set conversation tags: ${e.message}")
            }
        }
    }
}
