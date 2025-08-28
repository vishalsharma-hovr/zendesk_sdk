package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.zendesk.service.ErrorResponse
import com.zendesk.service.ZendeskCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.core.*
import zendesk.support.*
import zendesk.support.guide.HelpCenterActivity
import zendesk.support.request.RequestActivity
import zendesk.support.requestlist.RequestListActivity

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
        try {
          val name = call.argument<String>("name") ?: ""
          val userId = call.argument<String>("userId") ?: ""
          val emailId  = call.argument<String>("emailId") ?: ""
          val categoryIdList = call.argument<List<Long>>("categoryIdList") ?: emptyList()

          if (name.isEmpty()) {
            result.error("INVALID_ARGUMENTS", "Missing name!", null)
            return
          }

          if (userId.isEmpty()){
            result.error("INVALID_ARGUMENTS", "Missing userId!", null)
            return
          }

          if (emailId.isEmpty()){
            result.error("INVALID_ARGUMENTS", "Missing emailId!", null)
            return
          }

          val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

          // ✅ Combine all info into name or include in tags
          val combinedName = "$name | UserID: $userId"

          // ✅ 1. Set Zendesk Identity (required before launching any screens)
          val identity = AnonymousIdentity.Builder()
            .withNameIdentifier(combinedName)
            .withEmailIdentifier(emailId)
            .build()
          Zendesk.INSTANCE.setIdentity(identity)

          // ✅ 2. Configure default ticket settings (applies when "Contact Us" is pressed)
          val requestActivityConfig = RequestActivity.builder()
            .withTags(listOf("user_id:$userId", "mobile_app")) // Tags for new tickets
            .config() // Apply globally

          // ✅ 3. Use RequestProvider to get user's requests and show the most recent one
          val requestProvider = Support.INSTANCE.provider()?.requestProvider()

          requestProvider?.getAllRequests(object : ZendeskCallback<List<Request>>() {
            override fun onSuccess(requests: List<Request>?) {
              if (!requests.isNullOrEmpty()) {
                // Sort by creation date descending (most recent first)
                val sortedRequests = requests.sortedByDescending { it.createdAt?.time }
                val lastTicket = sortedRequests.first()

                // ✅ Fix: Check if ticket ID is not null before using it
                lastTicket.id?.let { ticketId ->
                  RequestActivity.builder()
                    .withRequestId(ticketId)
                    .show(context, requestActivityConfig)
                } ?: run {
                  // ✅ Handle case where ticket ID is null - show help center
                  HelpCenterActivity.builder()
                    .withArticlesForCategoryIds(categoryIdList)
                    .withContactUsButtonVisible(true)
                    .show(context, requestActivityConfig)
                }

              } else {
                // ✅ No tickets exist - show help center to create first ticket
                HelpCenterActivity.builder()
                  .withArticlesForCategoryIds(categoryIdList)
                  .withContactUsButtonVisible(true)
                  .show(context, requestActivityConfig)
              }

              // Return success to Flutter
              result.success("Last ticket displayed successfully")
            }

            override fun onError(errorResponse: ErrorResponse?) {
              // Log error for debugging
              Log.e("ZendeskSDK", "Error fetching requests: ${errorResponse?.reason}")

              // ✅ Fallback to help center on error
              HelpCenterActivity.builder()
                .withArticlesForCategoryIds(categoryIdList)
                .withContactUsButtonVisible(true)
                .show(context, requestActivityConfig)

              // Return error to Flutter
              result.error("ZENDESK_ERROR", "Failed to fetch tickets: ${errorResponse?.reason}", null)
            }
          })


          // ✅ Optional: Check for ticket updates (as mentioned in documentation)
          requestProvider?.getUpdatesForDevice(object : ZendeskCallback<RequestUpdates>() {
            override fun onSuccess(requestUpdates: RequestUpdates?) {
              if (requestUpdates?.hasUpdatedRequests() == true) {
                Log.d("ZendeskSDK", "User has ${requestUpdates.requestUpdates.size} updated tickets")
                // You can use this information to show notifications or badges
              }
            }

            override fun onError(errorResponse: ErrorResponse?) {
              Log.e("ZendeskSDK", "Error checking for updates: ${errorResponse?.reason}")
            }
          })

        } catch (e: Exception) {
          result.error("LAUNCH_FAILED", e.localizedMessage, null)
        }
      }

      "sendUserInformationForTicket" -> {
        val name = call.argument<String>("name") ?: ""
        val userId = call.argument<String>("userId") ?: ""
        val tripId = call.argument<String>("tripId") ?: ""
        val emailId = call.argument<String>("emailId") ?:""

        if (name.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Missing name!", null)
          return
        }
        if (userId.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Missing userId!", null)
          return
        }
        if (tripId.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Missing tripId!", null)
          return
        }
        if (emailId.isEmpty()) {
          result.error("INVALID_ARGUMENTS", "Missing emailId!", null)
          return
        }

        val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

        // ✅ Combine all info into name or include in tags
        val combinedName = "$name | UserID: $userId | TripID: $tripId"

        // ✅ Set identity for Support SDK
        val identity = AnonymousIdentity.Builder()
          .withNameIdentifier(combinedName)
          .withEmailIdentifier(emailId)
          .build()
        Zendesk.INSTANCE.setIdentity(identity)

        // ✅ Launch RequestActivity (Support SDK ticket form)
        val config = RequestActivity.builder()
          .withTags(listOf("user_id:$userId", "trip_id:$tripId"))
          .intent(context)

        context.startActivity(config)
        result.success(null)
      }

      // ✅ Optional: Add method to show all tickets if needed
      "showAllTickets" -> {
        try {
          val context = activity ?: return result.error("NO_ACTIVITY", "No activity attached", null)

          RequestListActivity.builder()
            .show(context)

          result.success("Ticket list displayed successfully")
        } catch (e: Exception) {
          result.error("LAUNCH_FAILED", e.localizedMessage, null)
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
