package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import com.zendesk.service.ErrorResponse
import com.zendesk.service.ZendeskCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.answerbot.AnswerBot
import zendesk.answerbot.AnswerBotEngine
import zendesk.chat.Chat
import zendesk.classic.messaging.MessagingActivity
import zendesk.core.AnonymousIdentity
import zendesk.core.Zendesk
import zendesk.messaging.android.DefaultMessagingFactory
import zendesk.messaging.android.push.PushNotifications
import zendesk.messaging.android.push.PushResponsibility
import zendesk.support.CustomField
import zendesk.support.Request
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.guide.ViewArticleActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity
import zendesk.android.Zendesk as ZendeskMessaging

class ZendeskSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var isSupportInitialized = false
    private var messagingZendesk: ZendeskMessaging? = null

    private var userId: String = ""
    private var userType: String = ""
    private var visitorName: String = ""
    private var visitorEmail: String = ""

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, ZendeskSdkChannel.NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            ZendeskSdkChannel.Method.INITIALIZE -> initialize(call, result)
            ZendeskSdkChannel.Method.LOGOUT -> logout(result)
            ZendeskSdkChannel.Method.IS_INITIALIZED -> result.success(isSupportInitialized)
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER -> showHelpCenter(call, result)
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_ARTICLE_ID ->
                showHelpCenterArticleId(call, result)
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_CATEGORY_ID ->
                showHelpCenterCategoryId(call, result)
            ZendeskSdkChannel.Method.SEND_USER_INFORMATION_FOR_TICKET ->
                sendUserInformationForTicket(call, result)
            ZendeskSdkChannel.Method.SHOW_LIST_OF_TICKETS -> showListOfTickets(result)
            ZendeskSdkChannel.Method.START_CHAT -> startChat(call, result)
            ZendeskSdkChannel.Method.START_CHAT_BOT -> startChatBot(result)
            ZendeskSdkChannel.Method.GET_UNREAD_MESSAGE_COUNT -> getUnreadMessageCount(result)
            ZendeskSdkChannel.Method.UPDATE_PUSH_NOTIFICATION_TOKEN ->
                updatePushNotificationToken(call, result)
            ZendeskSdkChannel.Method.HANDLE_PUSH_NOTIFICATION ->
                handlePushNotification(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>(ZendeskSdkChannel.Argument.ZENDESK_URL)
        val appId = call.argument<String>(ZendeskSdkChannel.Argument.APP_ID)
        val clientId = call.argument<String>(ZendeskSdkChannel.Argument.CLIENT_ID)
        val name = call.argument<String>(ZendeskSdkChannel.Argument.NAME) ?: ""
        val emailId = call.argument<String>(ZendeskSdkChannel.Argument.EMAIL_ID) ?: ""
        userId = call.argument<String>(ZendeskSdkChannel.Argument.USER_ID) ?: ""
        userType = call.argument<String>(ZendeskSdkChannel.Argument.USER_TYPE) ?: ""
        visitorName = name
        visitorEmail = emailId
        val combinedName = "$name | UserID: $userId"

        if (url.isNullOrBlank() || appId.isNullOrBlank() || clientId.isNullOrBlank()) {
            result.error(
                ZendeskSdkErrorCodes.INVALID_ARGUMENTS,
                "Missing required initialization parameters",
                null,
            )
            return
        }

        try {
            val appContext = context
                ?: return result.error(
                    ZendeskSdkErrorCodes.NO_UI_CONTEXT,
                    "Application context is unavailable",
                    null,
                )

            Zendesk.INSTANCE.init(appContext, url, appId, clientId)
            Support.INSTANCE.init(Zendesk.INSTANCE)
            val identity = AnonymousIdentity.Builder()
                .withNameIdentifier(combinedName)
                .withEmailIdentifier(emailId)
                .build()
            AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE)
            Zendesk.INSTANCE.setIdentity(identity)
            Chat.INSTANCE.init(appContext, clientId, appId)
            isSupportInitialized = true
            result.success(null)
        } catch (e: Exception) {
            isSupportInitialized = false
            result.error(ZendeskSdkErrorCodes.INIT_FAILED, e.localizedMessage, null)
        }
    }

    private fun logout(result: MethodChannel.Result) {
        try {
            Chat.INSTANCE.resetIdentity()
            Zendesk.INSTANCE.setIdentity(
                AnonymousIdentity.Builder().build(),
            )

            val messaging = messagingZendesk ?: ZendeskMessaging.instance
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
            result.error(ZendeskSdkErrorCodes.LOGOUT_FAILED, e.localizedMessage, null)
        }
    }

    private fun completeLogout(result: MethodChannel.Result) {
        messagingZendesk = null
        userId = ""
        userType = ""
        visitorName = ""
        visitorEmail = ""
        isSupportInitialized = false
        result.success(null)
    }

    private fun requireInitialized(result: MethodChannel.Result): Boolean {
        if (!isSupportInitialized) {
            result.error(
                ZendeskSdkErrorCodes.NOT_INITIALIZED,
                "Call initialize() before using the Zendesk SDK",
                null,
            )
            return false
        }
        return true
    }

    private fun requireActivity(result: MethodChannel.Result): Activity? {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error(
                ZendeskSdkErrorCodes.NO_UI_CONTEXT,
                "No activity attached",
                null,
            )
            return null
        }
        return currentActivity
    }

    private fun baseTags(): List<String> {
        val tags = mutableListOf("user_id:$userId", "mobile_app")
        if (userType.isNotBlank()) {
            tags.add("user_type:$userType")
        }
        return tags
    }

    private fun showHelpCenter(call: MethodCall, result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        try {
            val categoryIdList =
                call.argument<List<Long>>(ZendeskSdkChannel.Argument.CATEGORY_ID_LIST) ?: emptyList()
            val currentActivity = requireActivity(result) ?: return

            val requestActivityConfig = RequestActivity.builder()
                .withTags(baseTags())
                .config()

            HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryIdList)
                .withContactUsButtonVisible(true)
                .show(currentActivity, requestActivityConfig)

            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage, null)
        }
    }

    private fun showHelpCenterArticleId(call: MethodCall, result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        val articleIdRaw = call.argument<String>(ZendeskSdkChannel.Argument.ARTICLE_ID)
        val articleId = articleIdRaw?.toLongOrNull()
        if (articleId == null) {
            result.error(
                ZendeskSdkErrorCodes.INVALID_ARGUMENTS,
                "articleId must be a numeric article ID",
                null,
            )
            return
        }

        try {
            val currentActivity = requireActivity(result) ?: return
            ViewArticleActivity.builder(articleId).show(currentActivity)
            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage, null)
        }
    }

    private fun showHelpCenterCategoryId(call: MethodCall, result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        val categoryIdRaw = call.argument<String>(ZendeskSdkChannel.Argument.CATEGORY_ID)
        val categoryId = categoryIdRaw?.toLongOrNull()
        if (categoryId == null) {
            result.error(
                ZendeskSdkErrorCodes.INVALID_ARGUMENTS,
                "categoryId must be a numeric category ID",
                null,
            )
            return
        }

        try {
            val currentActivity = requireActivity(result) ?: return
            val requestActivityConfig = RequestActivity.builder()
                .withTags(baseTags())
                .config()

            HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryId)
                .withContactUsButtonVisible(true)
                .show(currentActivity, requestActivityConfig)

            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage, null)
        }
    }

    private fun sendUserInformationForTicket(call: MethodCall, result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        userId = call.argument<String>(ZendeskSdkChannel.Argument.USER_ID) ?: ""
        val tripId = call.argument<String>(ZendeskSdkChannel.Argument.TRIP_ID) ?: ""

        if (userId.isEmpty()) {
            result.error(ZendeskSdkErrorCodes.INVALID_ARGUMENTS, "Missing userId", null)
            return
        }
        if (tripId.isEmpty()) {
            result.error(ZendeskSdkErrorCodes.INVALID_ARGUMENTS, "Missing tripId", null)
            return
        }

        val currentActivity = requireActivity(result) ?: return
        val customFields = parseCustomFields(call)
        val tags = baseTags().toMutableList()
        tags.add("trip_id:$tripId")

        val config = RequestActivity.builder()
            .apply {
                if (customFields.isNotEmpty()) {
                    withCustomFields(customFields)
                }
            }
            .withTags(tags)
            .intent(currentActivity)

        currentActivity.startActivity(config)
        result.success(null)
    }

    private fun showListOfTickets(result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        try {
            val currentActivity = requireActivity(result) ?: return

            val requestProvider = Support.INSTANCE.provider()?.requestProvider()
            requestProvider?.getAllRequests(object : ZendeskCallback<List<Request>>() {
                override fun onSuccess(requests: List<Request>?) {
                    requests?.forEach {
                        Log.d("ZENDESK", "Ticket ${it.id} - ${it.subject}")
                    }
                    RequestListActivity.builder().show(currentActivity)
                }

                override fun onError(errorResponse: ErrorResponse?) {
                    Log.e("ZENDESK", errorResponse?.reason ?: "Unknown error")
                    RequestListActivity.builder().show(currentActivity)
                }
            })
            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.LAUNCH_FAILED, e.localizedMessage, null)
        }
    }

    private fun startChat(call: MethodCall, result: MethodChannel.Result) {
        val channelId = call.argument<String>(ZendeskSdkChannel.Argument.CHANNEL_ID) ?: ""
        if (channelId.isBlank()) {
            result.error(ZendeskSdkErrorCodes.INVALID_ARGUMENTS, "Missing channelId", null)
            return
        }

        try {
            val currentActivity = requireActivity(result) ?: return

            ZendeskMessaging.initialize(
                context = currentActivity,
                channelKey = channelId,
                successCallback = { zendesk ->
                    messagingZendesk = zendesk
                    applyMessagingVisitorInfo(zendesk)
                    zendesk.messaging.showMessaging(currentActivity)
                    result.success(null)
                },
                failureCallback = { error ->
                    result.error(ZendeskSdkErrorCodes.CHAT_INIT_FAILED, error.message, null)
                },
                messagingFactory = DefaultMessagingFactory(),
            )
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.CHAT_ENGINE_FAILED, e.localizedMessage, null)
        }
    }

    private fun applyMessagingVisitorInfo(zendesk: ZendeskMessaging) {
        val fields = mutableMapOf<String, String>()
        if (visitorName.isNotBlank()) {
            fields["name"] = visitorName
        }
        if (visitorEmail.isNotBlank()) {
            fields["email"] = visitorEmail
        }
        if (fields.isNotEmpty()) {
            try {
                zendesk.messaging.setConversationFields(fields)
            } catch (e: Exception) {
                Log.w("ZENDESK", "Unable to set conversation fields: ${e.message}")
            }
        }

        val tags = mutableListOf<String>()
        if (userId.isNotBlank()) {
            tags.add("user_id:$userId")
        }
        if (userType.isNotBlank()) {
            tags.add("user_type:$userType")
        }
        if (tags.isNotEmpty()) {
            try {
                zendesk.messaging.setConversationTags(tags)
            } catch (e: Exception) {
                Log.w("ZENDESK", "Unable to set conversation tags: ${e.message}")
            }
        }
    }

    private fun startChatBot(result: MethodChannel.Result) {
        if (!requireInitialized(result)) return

        try {
            val currentActivity = requireActivity(result) ?: return
            MessagingActivity.builder()
                .withEngines(AnswerBotEngine.engine())
                .show(currentActivity)
            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.ANSWERBOT_ERROR, e.localizedMessage, null)
        }
    }

    private fun getUnreadMessageCount(result: MethodChannel.Result) {
        try {
            val count = messagingZendesk?.messaging?.getUnreadMessageCount()
                ?: ZendeskMessaging.instance?.messaging?.getUnreadMessageCount()
                ?: 0
            result.success(count)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.UNREAD_COUNT_FAILED, e.localizedMessage, null)
        }
    }

    private fun updatePushNotificationToken(call: MethodCall, result: MethodChannel.Result) {
        val token = call.argument<String>(ZendeskSdkChannel.Argument.PUSH_TOKEN) ?: ""
        if (token.isBlank()) {
            result.error(ZendeskSdkErrorCodes.INVALID_ARGUMENTS, "Missing push token", null)
            return
        }

        try {
            PushNotifications.updatePushNotificationToken(token)
            result.success(null)
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.PUSH_TOKEN_FAILED, e.localizedMessage, null)
        }
    }

    private fun handlePushNotification(call: MethodCall, result: MethodChannel.Result) {
        val appContext = context
            ?: return result.error(
                ZendeskSdkErrorCodes.NO_UI_CONTEXT,
                "Application context is unavailable",
                null,
            )

        @Suppress("UNCHECKED_CAST")
        val payload = call.argument<Map<String, Any>>(
            ZendeskSdkChannel.Argument.PUSH_NOTIFICATION_DATA,
        ) ?: emptyMap()

        val messageData = payload.mapValues { it.value.toString() }

        try {
            when (PushNotifications.shouldBeDisplayed(messageData)) {
                PushResponsibility.MESSAGING_SHOULD_DISPLAY -> {
                    PushNotifications.displayNotification(appContext, messageData)
                    result.success(true)
                }

                PushResponsibility.MESSAGING_SHOULD_NOT_DISPLAY -> {
                    result.success(true)
                }

                PushResponsibility.NOT_FROM_MESSAGING -> {
                    result.success(false)
                }

                else -> result.success(false)
            }
        } catch (e: Exception) {
            result.error(ZendeskSdkErrorCodes.PUSH_NOTIFICATION_FAILED, e.localizedMessage, null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    @Suppress("UNCHECKED_CAST")
    private fun parseCustomFields(call: MethodCall): List<CustomField> {
        val customFieldsArg =
            call.argument<List<Map<String, Any>>>(ZendeskSdkChannel.Argument.CUSTOM_FIELDS)
                ?: return emptyList()

        return customFieldsArg.mapNotNull { field ->
            val fieldId = (field[ZendeskSdkChannel.Argument.FIELD_ID] as? Number)?.toLong()
                ?: return@mapNotNull null
            val value = field[ZendeskSdkChannel.Argument.VALUE] as? String
                ?: return@mapNotNull null
            CustomField(fieldId, value)
        }
    }
}
