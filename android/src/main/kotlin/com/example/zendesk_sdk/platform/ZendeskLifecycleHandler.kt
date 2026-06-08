package com.example.zendesk_sdk.platform

import com.example.zendesk_sdk.models.ZendeskConfig
import com.example.zendesk_sdk.models.ZendeskUser
import com.example.zendesk_sdk.result.ZendeskResult

/// Lifecycle operations: initialize, logout, isInitialized (ISP).
interface ZendeskLifecycleHandler {
    fun initialize(config: ZendeskConfig, user: ZendeskUser): ZendeskResult<Unit>
    fun logout(): ZendeskResult<Unit>
    fun isInitialized(): ZendeskResult<Boolean>
}
