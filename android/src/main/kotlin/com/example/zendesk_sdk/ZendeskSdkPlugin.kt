package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.classic.messaging.MessagingActivity
import zendesk.core.AnonymousIdentity
import zendesk.core.Identity
import zendesk.core.Zendesk
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity
import zendesk.answerbot.AnswerBot;
import zendesk.answerbot.AnswerBotEngine
import zendesk.classic.messaging.MessagingConfiguration
import zendesk.support.request.RequestActivity

class ZendeskSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var context: Context? = null
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "zendesk_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "initialize" -> {
        val url = call.argument<String>("zendeskUrl")
        val appId = call.argument<String>("appId")
        val clientId = call.argument<String>("clientId")

        if (url.isNullOrBlank() || appId.isNullOrBlank() || clientId.isNullOrBlank()) {
          result.error("INVALID_ARGUMENTS", "Missing required initialization parameters", null)
          return
        }

        try {
          context?.let {
            Zendesk.INSTANCE.init(it, url, appId, clientId)
            Support.INSTANCE.init(Zendesk.INSTANCE)
            val identity: Identity = AnonymousIdentity()
            Zendesk.INSTANCE.setIdentity(identity)
            result.success(null)
          }
                  ?: result.error("NO_CONTEXT", "Context is null", null)
        } catch (e: Exception) {
          result.error("INIT_FAILED", e.localizedMessage, null)
        }
      }
      "showHelpCenter" -> {
        val categoryId = call.argument<Long>("articleId")
        try {
          val name = call.argument<String>("name") ?: ""
          val userId = call.argument<String>("userId") ?: ""

          if (name.isEmpty() || userId.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Missing name, userId,", null)
            return
          }

//          val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

          // ✅ Combine all info into name or include in tags
          val combinedName = "$name | UserID: $userId"

          val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

          // ✅ 1. Set Zendesk Identity (required before launching any screens)
          val identity = AnonymousIdentity.Builder()
            .withNameIdentifier(combinedName)
//            .withEmailIdentifier()
            .build()
          Zendesk.INSTANCE.setIdentity(identity)

          // ✅ 2. Configure default ticket settings (applies when "Contact Us" is pressed)
          RequestActivity.builder()
            .withTags(listOf("user_id:$userId", "mobile_app")) // Tags for new tickets
            .config() // Apply globally

          // ✅ 3. Launch Help Center with Contact Button enabled
          HelpCenterActivity.builder()
            .withArticlesForCategoryIds(listOf(categoryId)) // Show specific category
            .withContactUsButtonVisible(true) // Allow ticket creation
            .show(context)

          result.success(null)
        } catch (e: Exception) {
          result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
      }

      "sendUserInformationForTicket" -> {
        val name = call.argument<String>("name") ?: ""
        val userId = call.argument<String>("userId") ?: ""
        val tripId = call.argument<String>("tripId") ?: ""

        if (name.isEmpty() || userId.isEmpty() || tripId.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Missing name, userId, or tripId", null)
          return
        }

        val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

        // ✅ Combine all info into name or include in tags
        val combinedName = "$name | UserID: $userId | TripID: $tripId"

        // ✅ Set identity for Support SDK
        val identity = AnonymousIdentity.Builder()
          .withNameIdentifier(combinedName)
          .withEmailIdentifier(userId)
          .build()
        Zendesk.INSTANCE.setIdentity(identity)

        // ✅ Launch RequestActivity (Support SDK ticket form)
        val config = RequestActivity.builder()
//          .withRequestSubject("Trip Support Request")
          .withTags(listOf("user_id:$userId", "trip_id:$tripId"))
          .intent(context)

        context.startActivity(config)
        result.success(null)
      }


//      "startChatBot" -> {
//        try {
//          val ctx = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)
//
//          // Initialize AnswerBot
//          AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE)
//          val answerBotEngine = AnswerBotEngine.engine()
////          val messagingConfig = MessagingConfiguration.builder().build()
//
//          // Show AnswerBot chat
//          MessagingActivity.builder()
//            .withEngines(answerBotEngine)
////            .withConfigs(messagingConfig)
//            .show(ctx)
//
//          result.success(null)
//        } catch (e: Exception) {
//          result.error("LAUNCH_FAILED", e.localizedMessage, null)
//        }
//      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
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
