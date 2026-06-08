package com.example.zendesk_sdk.result

import io.flutter.plugin.common.MethodChannel

/// Typed native result mirroring Dart [ZendeskResult].
sealed class ZendeskResult<out T> {
    data class Success<T>(val value: T) : ZendeskResult<T>()
    data class Failure(val code: String, val message: String?) : ZendeskResult<Nothing>()

    fun complete(result: MethodChannel.Result) {
        when (this) {
            is Success -> result.success(value)
            is Failure -> result.error(code, message, null)
        }
    }
}
