package com.example.zendesk_sdk.models

import com.example.zendesk_sdk.ZendeskSdkChannel
import io.flutter.plugin.common.MethodCall
import zendesk.support.CustomField

/// Ticket custom field value object.
data class ZendeskCustomField(
    val fieldId: Long,
    val value: String,
) {
    fun toNative(): CustomField = CustomField(fieldId, value)

    companion object {
        @Suppress("UNCHECKED_CAST")
        fun listFromMethodCall(call: MethodCall): List<ZendeskCustomField> {
            val customFieldsArg =
                call.argument<List<Map<String, Any>>>(ZendeskSdkChannel.Argument.CUSTOM_FIELDS)
                    ?: return emptyList()

            return customFieldsArg.mapNotNull { field ->
                val fieldId = (field[ZendeskSdkChannel.Argument.FIELD_ID] as? Number)?.toLong()
                    ?: return@mapNotNull null
                val value = field[ZendeskSdkChannel.Argument.VALUE] as? String
                    ?: return@mapNotNull null
                ZendeskCustomField(fieldId = fieldId, value = value)
            }
        }
    }
}
