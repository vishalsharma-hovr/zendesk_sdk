package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import zendesk.android.Zendesk
import zendesk.messaging.Messaging
import zendesk.messaging.MessagingActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ZendeskSdkPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
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
        val url = call.argument<String>("url")!!
        val appId = call.argument<String>("appId")!!
        val clientId = call.argument<String>("clientId")!!

        Zendesk.initialize(
          context = context!!,
          zendeskUrl = url,
          applicationId = appId,
          clientId = clientId
        )
        Messaging.setZendesk(Zendesk.instance)
        result.success(null)
      }
      "showHelpCenter" -> {
        activity?.let {
          MessagingActivity.builder().show(it)
        }
        result.success(null)
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