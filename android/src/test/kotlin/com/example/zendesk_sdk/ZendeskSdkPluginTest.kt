package com.example.zendesk_sdk

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

internal class ZendeskSdkPluginTest {
    @Test
    fun onMethodCall_isInitialized_returnsFalseBeforeInitialize() {
        val plugin = ZendeskSdkPlugin()
        val call = MethodCall(ZendeskSdkChannel.Method.IS_INITIALIZED, null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success(false)
    }
}
