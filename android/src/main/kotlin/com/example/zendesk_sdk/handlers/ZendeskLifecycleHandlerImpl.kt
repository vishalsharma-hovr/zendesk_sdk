package com.example.zendesk_sdk.handlers

import android.util.Log
import com.example.zendesk_sdk.ZendeskSdkErrorCodes
import com.example.zendesk_sdk.models.ZendeskConfig
import com.example.zendesk_sdk.models.ZendeskUser
import com.example.zendesk_sdk.platform.ZendeskLifecycleHandler
import com.example.zendesk_sdk.platform.ZendeskUiContext
import com.example.zendesk_sdk.result.ZendeskResult
import com.example.zendesk_sdk.session.ZendeskSession
import io.flutter.plugin.common.MethodChannel
import zendesk.answerbot.AnswerBot
import zendesk.chat.Chat
import zendesk.core.AnonymousIdentity
import zendesk.core.Zendesk
import zendesk.support.Support
import zendesk.android.Zendesk as ZendeskMessaging

class ZendeskLifecycleHandlerImpl(
    private val session: ZendeskSession,
    private val uiContext: ZendeskUiContext,
) : ZendeskLifecycleHandler {

    override fun initialize(config: ZendeskConfig, user: ZendeskUser): ZendeskResult<Unit> {
        return try {
            val appContext = uiContext.applicationContext()

            Zendesk.INSTANCE.init(appContext, config.url, config.appId, config.clientId)
            Support.INSTANCE.init(Zendesk.INSTANCE)
            val identity = AnonymousIdentity.Builder()
                .withNameIdentifier(user.combinedName)
                .withEmailIdentifier(user.emailId)
                .build()
            AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE)
            Zendesk.INSTANCE.setIdentity(identity)
            Chat.INSTANCE.init(appContext, config.clientId, config.appId)

            session.user = user
            session.isSupportInitialized = true
            ZendeskResult.Success(Unit)
        } catch (e: Exception) {
            session.isSupportInitialized = false
            ZendeskResult.Failure(ZendeskSdkErrorCodes.INIT_FAILED, e.localizedMessage)
        }
    }

    override fun logout(): ZendeskResult<Unit> {
        return ZendeskResult.Failure(
            ZendeskSdkErrorCodes.LOGOUT_FAILED,
            "Use logoutAsync() for logout",
        )
    }

    fun logoutAsync(result: MethodChannel.Result) {
        try {
            Chat.INSTANCE.resetIdentity()
            Zendesk.INSTANCE.setIdentity(AnonymousIdentity.Builder().build())

            val messaging = session.messagingZendesk ?: ZendeskMessaging.instance
            if (messaging != null) {
                messaging.logoutUser(
                    successCallback = { completeLogout(result) },
                    failureCallback = { error ->
                        Log.w("ZENDESK", "Messaging logout failed: ${error.message}")
                        completeLogout(result)
                    },
                )
            } else {
                completeLogout(result)
            }
        } catch (e: Exception) {
            ZendeskResult.Failure(
                ZendeskSdkErrorCodes.LOGOUT_FAILED,
                e.localizedMessage,
            ).complete(result)
        }
    }

    override fun isInitialized(): ZendeskResult<Boolean> {
        return ZendeskResult.Success(session.isSupportInitialized)
    }

    private fun completeLogout(result: MethodChannel.Result) {
        session.clear()
        ZendeskResult.Success(Unit).complete(result)
    }
}
