package com.example.zendesk_sdk.models

import com.example.zendesk_sdk.ZendeskSdkChannel
import io.flutter.plugin.common.MethodCall

/// Immutable Zendesk account configuration (Value Object).
data class ZendeskConfig(
    val url: String,
    val appId: String,
    val clientId: String,
) {
    companion object {
        fun fromMethodCall(call: MethodCall): ZendeskConfig? {
            val url = call.argument<String>(ZendeskSdkChannel.Argument.ZENDESK_URL)
            val appId = call.argument<String>(ZendeskSdkChannel.Argument.APP_ID)
            val clientId = call.argument<String>(ZendeskSdkChannel.Argument.CLIENT_ID)
            if (url.isNullOrBlank() || appId.isNullOrBlank() || clientId.isNullOrBlank()) {
                return null
            }
            return ZendeskConfig(url = url, appId = appId, clientId = clientId)
        }
    }
}
