package com.example.zendesk_sdk

import com.example.zendesk_sdk.commands.InitializeCommand
import com.example.zendesk_sdk.commands.IsInitializedCommand
import com.example.zendesk_sdk.commands.ZendeskCommandFactory
import com.example.zendesk_sdk.commands.ZendeskCommandParseResult
import io.flutter.plugin.common.MethodCall
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

internal class ZendeskCommandFactoryTest {
    @Test
    fun parse_isInitialized_returnsCommand() {
        val call = MethodCall(ZendeskSdkChannel.Method.IS_INITIALIZED, null)

        val parsed = ZendeskCommandFactory.parse(call)

        assertIs<ZendeskCommandParseResult.Success>(parsed)
        assertIs<IsInitializedCommand>(parsed.command)
    }

    @Test
    fun parse_initialize_withMissingArgs_returnsInvalidArguments() {
        val call = MethodCall(
            ZendeskSdkChannel.Method.INITIALIZE,
            mapOf(ZendeskSdkChannel.Argument.ZENDESK_URL to "https://example.zendesk.com"),
        )

        val parsed = ZendeskCommandFactory.parse(call)

        assertEquals(ZendeskCommandParseResult.InvalidArguments, parsed)
    }

    @Test
    fun parse_initialize_withValidArgs_returnsCommand() {
        val call = MethodCall(
            ZendeskSdkChannel.Method.INITIALIZE,
            mapOf(
                ZendeskSdkChannel.Argument.ZENDESK_URL to "https://example.zendesk.com",
                ZendeskSdkChannel.Argument.APP_ID to "app-id",
                ZendeskSdkChannel.Argument.CLIENT_ID to "client-id",
                ZendeskSdkChannel.Argument.NAME to "Jane",
                ZendeskSdkChannel.Argument.EMAIL_ID to "jane@example.com",
                ZendeskSdkChannel.Argument.USER_ID to "user-1",
                ZendeskSdkChannel.Argument.USER_TYPE to "RIDER",
            ),
        )

        val parsed = ZendeskCommandFactory.parse(call)

        assertIs<ZendeskCommandParseResult.Success>(parsed)
        val command = parsed.command as InitializeCommand
        assertEquals("https://example.zendesk.com", command.config.url)
        assertEquals("Jane", command.user.name)
        assertEquals("user-1", command.user.userId)
    }

    @Test
    fun parse_unknownMethod_returnsNotImplemented() {
        val call = MethodCall("unknownMethod", null)

        val parsed = ZendeskCommandFactory.parse(call)

        assertEquals(ZendeskCommandParseResult.NotImplemented, parsed)
    }

    @Test
    fun zendeskUser_baseTags_includesUserTypeAndTripId() {
        val user = com.example.zendesk_sdk.models.ZendeskUser(
            name = "Jane",
            emailId = "jane@example.com",
            userId = "user-1",
            userType = "RIDER",
        )

        val tags = user.baseTags(tripId = "trip-42")

        assertTrue(tags.contains("user_id:user-1"))
        assertTrue(tags.contains("user_type:RIDER"))
        assertTrue(tags.contains("trip_id:trip-42"))
        assertTrue(tags.contains("mobile_app"))
    }
}
