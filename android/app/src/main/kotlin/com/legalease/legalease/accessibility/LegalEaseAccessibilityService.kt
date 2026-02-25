package com.legalease.legalease.accessibility

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.provider.Settings
import com.legalease.legalease.overlay.OverlayService

class LegalEaseAccessibilityService : AccessibilityService() {
    
    companion object {
        var instance: LegalEaseAccessibilityService? = null
        var isServiceEnabled = false
        
        fun getInstance(): LegalEaseAccessibilityService? = instance
    }
    
    private val tcKeywords = listOf(
        "terms and conditions", "terms of service", "terms of use",
        "privacy policy", "eula", "end user license agreement",
        "user agreement", "legal notice", "disclaimer"
    )
    
    private var lastDetectedText: String = ""
    private var lastDetectionTime: Long = 0
    private val detectionCooldownMs: Long = 5000
    
    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        isServiceEnabled = true
        
        serviceInfo = serviceInfo.apply {
            eventTypes = AccessibilityEvent.TYPES_ALL_MASK
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REQUEST_ENHANCED_WEB_ACCESSIBILITY or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            notificationTimeout = 100
            packageNames = null
        }
    }
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        
        val rootNode = rootInActiveWindow
        rootNode?.let { node ->
            val screenText = extractAllText(node)
            if (containsTcContent(screenText) && shouldNotify(screenText)) {
                lastDetectedText = screenText
                lastDetectionTime = System.currentTimeMillis()
                notifyTcDetected(screenText, event.packageName?.toString() ?: "")
            }
        }
    }
    
    override fun onInterrupt() {
    }
    
    override fun onDestroy() {
        super.onDestroy()
        instance = null
        isServiceEnabled = false
    }
    
    private fun extractAllText(node: AccessibilityNodeInfo): String {
        val textBuilder = StringBuilder()
        extractTextRecursive(node, textBuilder)
        return textBuilder.toString()
    }
    
    private fun extractTextRecursive(node: AccessibilityNodeInfo, builder: StringBuilder) {
        node.text?.let { builder.append(it).append(" ") }
        node.contentDescription?.let { builder.append(it).append(" ") }
        
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { child ->
                extractTextRecursive(child, builder)
                child.recycle()
            }
        }
    }
    
    private fun containsTcContent(text: String): Boolean {
        val lowerText = text.lowercase()
        return tcKeywords.any { keyword -> lowerText.contains(keyword) }
    }
    
    private fun shouldNotify(currentText: String): Boolean {
        val now = System.currentTimeMillis()
        if (now - lastDetectionTime < detectionCooldownMs) {
            return false
        }
        return currentText != lastDetectedText
    }
    
    private fun notifyTcDetected(text: String, packageName: String) {
        AccessibilityEventSender.sendEvent("tc_detected", mapOf(
            "text" to text,
            "packageName" to packageName,
            "timestamp" to System.currentTimeMillis()
        ))
        
        if (Settings.canDrawOverlays(this)) {
            OverlayService.showOverlay(this, text)
        }
    }
    
    fun extractScreenText(): String {
        val rootNode = rootInActiveWindow ?: return ""
        return extractAllText(rootNode)
    }
    
    fun getCurrentPackageName(): String {
        return rootInActiveWindow?.packageName?.toString() ?: ""
    }
}
