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
import zendesk.chat.Chat
import zendesk.core.*
import zendesk.messaging.android.DefaultMessagingFactory
import zendesk.support.*
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity
import zendesk.android.Zendesk as zendeskV3

class ZendeskSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var userId: String = ""

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, ZendeskSdkChannel.NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            ZendeskSdkChannel.Method.INITIALIZE -> initialize(call, result)
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER -> showHelpCenter(call, result)
            ZendeskSdkChannel.Method.SEND_USER_INFORMATION_FOR_TICKET ->
                sendUserInformationForTicket(call, result)
            ZendeskSdkChannel.Method.SHOW_LIST_OF_TICKETS -> showListOfTickets(result)
            ZendeskSdkChannel.Method.START_CHAT -> startChat(call, result)
            ZendeskSdkChannel.Method.START_CHAT_BOT -> startChatBot(result)
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_ARTICLE_ID,
            ZendeskSdkChannel.Method.SHOW_HELP_CENTER_CATEGORY_ID ->
                result.notImplemented()
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
        val combinedName = "$name | UserID: $userId"

        if (url.isNullOrBlank() || appId.isNullOrBlank() || clientId.isNullOrBlank()) {
            result.error("INVALID_ARGUMENTS", "Missing required initialization parameters", null)
            return
        }

        try {
            val appContext = context
            if (appContext == null) {
                result.error("NO_CONTEXT", "Context is null", null)
                return
            }

            Zendesk.INSTANCE.init(appContext, url, appId, clientId)
            Support.INSTANCE.init(Zendesk.INSTANCE)
            val identity = AnonymousIdentity.Builder()
                .withNameIdentifier(combinedName)
                .withEmailIdentifier(emailId)
                .build()
            AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE)
            Zendesk.INSTANCE.setIdentity(identity)
            Chat.INSTANCE.init(appContext, clientId, appId)
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_FAILED", e.localizedMessage, null)
        }
    }

    private fun showHelpCenter(call: MethodCall, result: MethodChannel.Result) {
        try {
            val categoryIdList =
                call.argument<List<Long>>(ZendeskSdkChannel.Argument.CATEGORY_ID_LIST) ?: emptyList()
            val currentActivity = activity
                ?: return result.error("NO_ACTIVITY", "No activity attached", null)

            val requestActivityConfig = RequestActivity.builder()
                .withTags(listOf("user_id:$userId", "mobile_app"))
                .config()

            HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryIdList)
                .withContactUsButtonVisible(true)
                .show(currentActivity, requestActivityConfig)

            result.success(null)
        } catch (e: Exception) {
            result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
    }

    private fun sendUserInformationForTicket(call: MethodCall, result: MethodChannel.Result) {
        userId = call.argument<String>(ZendeskSdkChannel.Argument.USER_ID) ?: ""
        val tripId = call.argument<String>(ZendeskSdkChannel.Argument.TRIP_ID) ?: ""

        if (userId.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Missing userId!", null)
            return
        }
        if (tripId.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Missing tripId!", null)
            return
        }

        val currentActivity = activity
            ?: return result.error("NO_ACTIVITY", "No activity attached", null)

        val customFields = parseCustomFields(call)

        val config = RequestActivity.builder()
            .apply {
                if (customFields.isNotEmpty()) {
                    withCustomFields(customFields)
                }
            }
            .withTags(listOf("user_id:$userId", "trip_id:$tripId"))
            .intent(currentActivity)

        currentActivity.startActivity(config)
        result.success(null)
    }

    private fun showListOfTickets(result: MethodChannel.Result) {
        try {
            val currentActivity = activity
                ?: return result.error("NO_ACTIVITY", "No activity attached", null)

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
            result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
    }

    private fun startChat(call: MethodCall, result: MethodChannel.Result) {
        val channelId = call.argument<String>(ZendeskSdkChannel.Argument.CHANNEL_ID) ?: ""
        if (channelId.isBlank()) {
            result.error("INVALID_ARGUMENTS", "Missing channelId", null)
            return
        }

        try {
            val currentActivity = activity
                ?: return result.error("NO_ACTIVITY", "No activity attached", null)

            zendeskV3.initialize(
                context = currentActivity,
                channelKey = channelId,
                successCallback = { zendesk ->
                    zendesk.messaging.showMessaging(currentActivity)
                    result.success(null)
                },
                failureCallback = { error ->
                    result.error("CHAT_INIT_FAILED", error.localizedMessage, null)
                },
                messagingFactory = DefaultMessagingFactory()
            )
        } catch (e: Exception) {
            result.error("CHAT_ENGINE_FAILED", e.localizedMessage, null)
        }
    }

    private fun startChatBot(result: MethodChannel.Result) {
        result.notImplemented()
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
