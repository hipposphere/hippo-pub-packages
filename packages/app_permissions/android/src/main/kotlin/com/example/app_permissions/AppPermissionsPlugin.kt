package com.example.app_permissions

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** AppPermissionsPlugin */
class AppPermissionsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var pendingResult: Result? = null

    companion object {
        private const val MICROPHONE_PERMISSION_CODE = 1001
        private const val PERMISSION_MICROPHONE = Manifest.permission.RECORD_AUDIO
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app_permissions")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isAccessibilityGranted" -> {
                // Android doesn't have accessibility permission in the same way as macOS
                result.success(true)
            }
            "requestAccessibility" -> {
                // Android doesn't have accessibility permission in the same way as macOS
                result.success(true)
            }
            "getAccessibilityStatus" -> {
                result.success("notRequired")
            }
            "isInputMonitoringGranted" -> {
                // Android doesn't have input monitoring permission in the same way as macOS
                result.success(true)
            }
            "requestInputMonitoring" -> {
                // Android doesn't have input monitoring permission in the same way as macOS
                result.success(true)
            }
            "getInputMonitoringStatus" -> {
                result.success("notRequired")
            }
            "isMicrophoneGranted" -> {
                result.success(isMicrophoneGranted())
            }
            "requestMicrophone" -> {
                requestMicrophone(result)
            }
            "getMicrophoneStatus" -> {
                result.success(getMicrophoneStatus())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    // MARK: - Microphone Permission Methods

    private fun isMicrophoneGranted(): Boolean {
        val ctx = context ?: return false
        return ContextCompat.checkSelfPermission(
            ctx,
            PERMISSION_MICROPHONE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun getMicrophoneStatus(): String {
        val ctx = context ?: return "notRequired"

        return when {
            ContextCompat.checkSelfPermission(
                ctx,
                PERMISSION_MICROPHONE
            ) == PackageManager.PERMISSION_GRANTED -> "granted"

            activity?.let {
                ActivityCompat.shouldShowRequestPermissionRationale(it, PERMISSION_MICROPHONE)
            } == true -> "denied"

            else -> "notDetermined"
        }
    }

    private fun requestMicrophone(result: Result) {
        val currentActivity = activity

        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null)
            return
        }

        // Check if already granted
        if (isMicrophoneGranted()) {
            result.success(true)
            return
        }

        // Store the result to respond later
        pendingResult = result

        // Request the permission
        ActivityCompat.requestPermissions(
            currentActivity,
            arrayOf(PERMISSION_MICROPHONE),
            MICROPHONE_PERMISSION_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == MICROPHONE_PERMISSION_CODE) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED

            pendingResult?.success(granted)
            pendingResult = null
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
