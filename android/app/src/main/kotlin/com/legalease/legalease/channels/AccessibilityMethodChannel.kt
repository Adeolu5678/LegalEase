package com.legalease.legalease.channels

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.legalease.legalease.accessibility.LegalEaseAccessibilityService
import com.legalease.legalease.accessibility.AccessibilityEventSender
import io.flutter.plugin.common.EventChannel

class AccessibilityMethodChannel(private val context: Context) : MethodCallHandler {
    
    companion object {
        const val CHANNEL_NAME = "legalease_android_accessibility"
        const val EVENT_CHANNEL_NAME = "legalease_android_accessibility_events"
        
        fun register(context: Context, messenger: io.flutter.plugin.common.BinaryMessenger) {
            val methodChannel = MethodChannel(messenger, CHANNEL_NAME)
            methodChannel.setMethodCallHandler(AccessibilityMethodChannel(context))
            
            val eventChannel = EventChannel(messenger, EVENT_CHANNEL_NAME)
            eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    AccessibilityEventSender.setEventSink(events)
                }
                
                override fun onCancel(arguments: Any?) {
                    AccessibilityEventSender.setEventSink(null)
                }
            })
        }
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isAccessibilityEnabled" -> {
                result.success(isAccessibilityServiceEnabled())
            }
            "openAccessibilitySettings" -> {
                openAccessibilitySettings()
                result.success(true)
            }
            "extractScreenText" -> {
                val text = LegalEaseAccessibilityService.getInstance()?.extractScreenText() ?: ""
                result.success(text)
            }
            "getCurrentPackage" -> {
                val packageName = LegalEaseAccessibilityService.getInstance()?.getCurrentPackageName() ?: ""
                result.success(packageName)
            }
            "hasOverlayPermission" -> {
                result.success(Settings.canDrawOverlays(context))
            }
            "requestOverlayPermission" -> {
                requestOverlayPermission()
                result.success(true)
            }
            "isServiceRunning" -> {
                result.success(LegalEaseAccessibilityService.isServiceEnabled)
            }
            else -> result.notImplemented()
        }
    }
    
    private fun isAccessibilityServiceEnabled(): Boolean {
        val serviceName = "${context.packageName}/${LegalEaseAccessibilityService::class.java.canonicalName}"
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        return enabledServices.contains(serviceName)
    }
    
    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
    
    private fun requestOverlayPermission() {
        val intent = Intent(
            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
            Uri.parse("package:${context.packageName}")
        )
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}
