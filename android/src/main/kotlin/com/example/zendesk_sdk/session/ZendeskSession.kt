package com.example.zendesk_sdk.session

import com.example.zendesk_sdk.models.ZendeskUser
import zendesk.android.Zendesk as ZendeskMessaging

/// Mutable plugin session state shared across native handlers.
class ZendeskSession {
    var user: ZendeskUser = ZendeskUser.EMPTY
    var isSupportInitialized: Boolean = false
    var messagingZendesk: ZendeskMessaging? = null

    fun clear() {
        user = ZendeskUser.EMPTY
        messagingZendesk = null
        isSupportInitialized = false
    }
}
