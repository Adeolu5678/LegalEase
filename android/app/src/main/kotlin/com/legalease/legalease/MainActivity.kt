package com.legalease.legalease

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.legalease.legalease.channels.AccessibilityMethodChannel

class MainActivity : FlutterActivity() {
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        AccessibilityMethodChannel.register(this, flutterEngine.dartExecutor.binaryMessenger)
    }
}
