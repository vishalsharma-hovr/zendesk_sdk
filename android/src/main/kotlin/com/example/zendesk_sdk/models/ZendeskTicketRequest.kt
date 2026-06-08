package com.example.zendesk_sdk.models

import com.example.zendesk_sdk.ZendeskSdkChannel
import io.flutter.plugin.common.MethodCall

/// Ticket submission context combining [user], [tripId], and optional fields.
data class ZendeskTicketRequest(
    val user: ZendeskUser,
    val tripId: String,
    val customFields: List<ZendeskCustomField> = emptyList(),
) {
    companion object {
        fun fromMethodCall(call: MethodCall): ZendeskTicketRequest? {
            val user = ZendeskUser.fromMethodCall(call)
            val tripId = call.argument<String>(ZendeskSdkChannel.Argument.TRIP_ID) ?: ""
            if (user.userId.isEmpty() || tripId.isEmpty()) {
                return null
            }
            return ZendeskTicketRequest(
                user = user,
                tripId = tripId,
                customFields = ZendeskCustomField.listFromMethodCall(call),
            )
        }
    }
}
