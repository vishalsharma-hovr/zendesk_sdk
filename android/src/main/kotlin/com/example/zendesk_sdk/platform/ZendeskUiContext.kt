package com.example.zendesk_sdk.platform

import android.app.Activity
import android.content.Context

/// Provides Android [Context] and [Activity] to handlers (DIP).
class ZendeskUiContext(
    private val applicationContext: Context,
    private val activityProvider: () -> Activity?,
) {
    fun applicationContext(): Context = applicationContext

    fun currentActivity(): Activity? = activityProvider()
}
