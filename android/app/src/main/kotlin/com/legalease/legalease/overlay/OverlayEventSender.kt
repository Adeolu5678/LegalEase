package com.legalease.legalease.overlay

import io.flutter.plugin.common.EventChannel

object OverlayEventSender {
    
    private var eventSink: EventChannel.EventSink? = null
    
    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }
    
    fun sendEvent(eventType: String, data: Any) {
        eventSink?.success(mapOf(
            "type" to eventType,
            "data" to data
        ))
    }
    
    fun sendError(errorCode: String, message: String, details: Any? = null) {
        eventSink?.error(errorCode, message, details)
    }
}
