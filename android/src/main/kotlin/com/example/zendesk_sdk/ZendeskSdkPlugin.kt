package com.example.zendesk_sdk

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.zendesk.service.AnonymousIdentity
import com.zendesk.service.Identity
import zendesk.core.Zendesk
import zendesk.support.Support
import zendesk.support.guide.HelpCenterActivity
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
        val url = call.argument<String>("zendeskUrl") ?: return result.error("MISSING_URL", "Missing zendeskUrl", null)
        val appId = call.argument<String>("appId") ?: return result.error("MISSING_APPID", "Missing appId", null)
        val clientId = call.argument<String>("clientId") ?: return result.error("MISSING_CLIENTID", "Missing clientId", null)

        Zendesk.INSTANCE.init(context, url, appId, clientId)
        Support.INSTANCE.init(Zendesk.INSTANCE)

        val identity: Identity = AnonymousIdentity()
        Zendesk.INSTANCE.setIdentity(identity)

        result.success(null)
      }

      "showHelpCenter" -> {
        if (activity != null) {
          val intent: Intent = HelpCenterActivity.builder().intent(activity)
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
