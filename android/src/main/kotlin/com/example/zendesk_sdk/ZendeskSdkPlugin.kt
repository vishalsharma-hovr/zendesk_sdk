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
import zendesk.chat.ChatConfiguration
import zendesk.chat.ChatEngine
import zendesk.chat.ChatProvidersConfiguration
import zendesk.chat.VisitorInfo
import zendesk.classic.messaging.Engine
import zendesk.classic.messaging.MessagingActivity
import zendesk.configurations.Configuration
import zendesk.core.*
import zendesk.support.*
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity


class ZendeskSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null
    private var userId: String = ""

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "zendesk_sdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                val url = call.argument<String>("zendeskUrl")
                val appId = call.argument<String>("appId")
                val clientId = call.argument<String>("clientId")
                val name = call.argument<String>("name") ?: ""
                val emailId = call.argument<String>("emailId") ?: ""
                userId = call.argument<String>("userId") ?: ""
                val combinedName = "$name | UserID: $userId"
                if (url.isNullOrBlank() || appId.isNullOrBlank() || clientId.isNullOrBlank()) {
                    result.error("INVALID_ARGUMENTS", "Missing required initialization parameters", null)
                    return
                }

                try {
                    context?.let {
                        Zendesk.INSTANCE.init(it, url, appId, clientId)
                        Support.INSTANCE.init(Zendesk.INSTANCE)
                        val identity = AnonymousIdentity.Builder()
                            .withNameIdentifier(combinedName)
                            .withEmailIdentifier(emailId)
                            .build()
                        Zendesk.INSTANCE.setIdentity(identity)
                        Chat.INSTANCE.init(it, clientId, appId)
                        result.success(null)
                    }
                        ?: result.error("NO_CONTEXT", "Context is null", null)
                } catch (e: Exception) {
                    result.error("INIT_FAILED", e.localizedMessage, null)
                }
            }

            "showHelpCenter" -> {
                try {
                    val categoryIdList = call.argument<List<Long>>("categoryIdList") ?: emptyList()
                    val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)
                    val requestActivityConfig = RequestActivity.builder()
                        .withTags(listOf("user_id:$userId", "mobile_app")) // Tags for new tickets
                        .config() // Apply globally
                    HelpCenterActivity.builder()
                        .withArticlesForCategoryIds(categoryIdList)
                        .withContactUsButtonVisible(true)
                        .show(context, requestActivityConfig)
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", e.localizedMessage, null)
                }
            }

            "sendUserInformationForTicket" -> {
                userId = call.argument<String>("userId") ?: ""
                val tripId = call.argument<String>("tripId") ?: ""

                if (userId.isEmpty()) {
                    result.error("INVALID_ARGUMENTS", "Missing userId!", null)
                }
                if (tripId.isEmpty()) {
                    result.error("INVALID_ARGUMENTS", "Missing tripId!", null)
                }

                val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)
                // ✅ Launch RequestActivity (Support SDK ticket form)
                val config = RequestActivity.builder()
                    .withTags(listOf("user_id:$userId", "trip_id:$tripId"))
                    .intent(context)

                context.startActivity(config)
                result.success(null)
            }

            // ✅ Optional: Add method to show all tickets if needed
            "showListOfTickets" -> {
                try {
                    val context = activity
                        ?: return result.error("NO_ACTIVITY", "No activity attached", null)
                    val requestProvider = Support.INSTANCE
                        .provider()
                        ?.requestProvider()
                    requestProvider?.getAllRequests(object : ZendeskCallback<List<Request>>() {
                        override fun onSuccess(requests: List<Request>?) {
                            requests?.forEach {
                                Log.d("ZENDESK", "Ticket ${it.id} - ${it.subject}")
                            }
                            // AFTER tickets loaded, show UI
                            RequestListActivity.builder().show(context)
                        }
                        override fun onError(errorResponse: ErrorResponse?) {
                            Log.e("ZENDESK", errorResponse?.reason ?: "Unknown error")
                            // Still show UI even if fetch fails
                            RequestListActivity.builder().show(context)
                        }
                    })
                    result.success(null)
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", e.localizedMessage, null)
                }
            }

            "startChat" -> {
                val name = call.argument<String>("name") ?: ""
                val emailId = call.argument<String>("emailId") ?: ""
                val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                try {
                    val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)
                    val chatConfiguration = ChatConfiguration.builder()
                        .withAgentAvailabilityEnabled(false)
                        .build()
                    val visitor = VisitorInfo.builder()
                        .withName(name)
                        .withEmail(emailId)
                        .withPhoneNumber(phoneNumber) // numeric string
                        .build()
                    val chatProvideConfig = ChatProvidersConfiguration.builder()
                        .withVisitorInfo(visitor)
                        .build()
                    Chat.INSTANCE.setChatProvidersConfiguration(chatProvideConfig)
                    MessagingActivity.builder()
                        .withEngines(ChatEngine.engine())
                        .withMultilineResponseOptionsEnabled(true)
                        .show(context, chatConfiguration)
                } catch (e: Exception) {
                    result.error("CHAT_ENGINE_FAILED", e.localizedMessage, null)
                    throw e
                }
            }

            else -> result.notImplemented()
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
}
