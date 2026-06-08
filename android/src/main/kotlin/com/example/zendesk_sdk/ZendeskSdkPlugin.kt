package com.example.zendesk_sdk

import android.app.Activity
import com.example.zendesk_sdk.handlers.ZendeskLifecycleHandlerImpl
import com.example.zendesk_sdk.handlers.ZendeskMessagingHandlerImpl
import com.example.zendesk_sdk.handlers.ZendeskSupportHandlerImpl
import com.example.zendesk_sdk.platform.ZendeskUiContext
import com.example.zendesk_sdk.session.ZendeskSession
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/// Thin plugin entry point: wires Flutter channel to [ZendeskMethodDispatcher].
class ZendeskSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var dispatcher: ZendeskMethodDispatcher

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val session = ZendeskSession()
        val uiContext = ZendeskUiContext(
            applicationContext = binding.applicationContext,
            activityProvider = { activity },
        )
        val lifecycleHandler = ZendeskLifecycleHandlerImpl(session, uiContext)
        val supportHandler = ZendeskSupportHandlerImpl(session, uiContext)
        val messagingHandler = ZendeskMessagingHandlerImpl(session, uiContext)
        val service = ZendeskNativeService(
            lifecycle = lifecycleHandler,
            support = supportHandler,
            messaging = messagingHandler,
        )
        dispatcher = ZendeskMethodDispatcher(
            service = service,
            lifecycleHandler = lifecycleHandler,
            messagingHandler = messagingHandler,
        )
        channel = MethodChannel(binding.binaryMessenger, ZendeskSdkChannel.NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        dispatcher.dispatch(call, result)
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
