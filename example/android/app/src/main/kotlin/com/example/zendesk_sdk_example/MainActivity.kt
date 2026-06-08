package com.example.zendesk_sdk_example

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ZendeskConfigChannel.NAME
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                ZendeskConfigChannel.METHOD_GET_CONFIG -> {
                    result.success(readZendeskConfig())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun readZendeskConfig(): Map<String, String> {
        val appInfo = packageManager.getApplicationInfo(
            packageName,
            PackageManager.GET_META_DATA
        )
        val metadata = appInfo.metaData ?: return emptyMap()

        return mapOf(
            ZendeskConfigChannel.KEY_URL to metadata.getString(ZendeskConfigChannel.KEY_URL).orEmpty(),
            ZendeskConfigChannel.KEY_APP_ID to metadata.getString(ZendeskConfigChannel.KEY_APP_ID).orEmpty(),
            ZendeskConfigChannel.KEY_CLIENT_ID to metadata.getString(ZendeskConfigChannel.KEY_CLIENT_ID).orEmpty(),
            ZendeskConfigChannel.KEY_CHANNEL_ID to metadata.getString(ZendeskConfigChannel.KEY_CHANNEL_ID).orEmpty(),
        )
    }
}

object ZendeskConfigChannel {
    const val NAME = "zendesk_config"
    const val METHOD_GET_CONFIG = "getZendeskConfig"

    const val KEY_URL = "ZENDESK_URL"
    const val KEY_APP_ID = "ZENDESK_APP_ID"
    const val KEY_CLIENT_ID = "ZENDESK_CLIENT_ID"
    const val KEY_CHANNEL_ID = "ZENDESK_CHANNEL_ID"
}
