package com.example.zendesk_sdk.models

import com.example.zendesk_sdk.ZendeskSdkChannel
import io.flutter.plugin.common.MethodCall

/// Immutable end-user identity passed to Zendesk (Value Object).
data class ZendeskUser(
    val name: String,
    val emailId: String,
    val userId: String,
    val userType: String,
) {
    val combinedName: String
        get() = "$name | UserID: $userId"

    fun baseTags(tripId: String? = null): List<String> {
        val tags = mutableListOf("user_id:$userId", "mobile_app")
        if (userType.isNotBlank()) {
            tags.add("user_type:$userType")
        }
        if (!tripId.isNullOrBlank()) {
            tags.add("trip_id:$tripId")
        }
        return tags
    }

    companion object {
        val EMPTY = ZendeskUser(name = "", emailId = "", userId = "", userType = "")

        fun fromMethodCall(call: MethodCall): ZendeskUser {
            return ZendeskUser(
                name = call.argument<String>(ZendeskSdkChannel.Argument.NAME) ?: "",
                emailId = call.argument<String>(ZendeskSdkChannel.Argument.EMAIL_ID) ?: "",
                userId = call.argument<String>(ZendeskSdkChannel.Argument.USER_ID) ?: "",
                userType = call.argument<String>(ZendeskSdkChannel.Argument.USER_TYPE) ?: "",
            )
        }
    }
}
