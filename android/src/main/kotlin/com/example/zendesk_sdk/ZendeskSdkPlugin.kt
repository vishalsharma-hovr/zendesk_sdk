package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import zendesk.core.AnonymousIdentity
import zendesk.core.Identity
import zendesk.core.Zendesk
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity

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
    if (activity != null) {
        val intent: Intent = HelpCenterActivity.builder().intent(activity!!)
        activity!!.startActivity(intent)
        result.success(null)
    } else {
        result.error("NO_ACTIVITY", "No activity attached", null)
    }
}
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
