package com.example.app_permissions

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

internal class AppPermissionsPluginTest {
    @Test
    fun onMethodCall_getAccessibilityStatus_returnsNotRequired() {
        val plugin = AppPermissionsPlugin()

        val call = MethodCall("getAccessibilityStatus", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).success("notRequired")
    }
}
