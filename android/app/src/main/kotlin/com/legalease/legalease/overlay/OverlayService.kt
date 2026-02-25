package com.legalease.legalease.overlay

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Button
import com.legalease.legalease.R

class OverlayService : Service() {
    
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var isExpanded = false
    private var currentText: String = ""
    
    companion object {
        var isActive = false
        var instance: OverlayService? = null
        
        fun showOverlay(context: android.content.Context, text: String) {
            val intent = Intent(context, OverlayService::class.java).apply {
                action = "SHOW_OVERLAY"
                putExtra("text", text)
            }
            context.startService(intent)
        }
        
        fun hideOverlay(context: android.content.Context) {
            val intent = Intent(context, OverlayService::class.java).apply {
                action = "HIDE_OVERLAY"
            }
            context.startService(intent)
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        instance = this
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "SHOW_OVERLAY" -> {
                currentText = intent.getStringExtra("text") ?: ""
                showFloatingButton()
            }
            "HIDE_OVERLAY" -> hideOverlay()
            "EXPAND_OVERLAY" -> expandOverlay()
            "COLLAPSE_OVERLAY" -> collapseOverlay()
        }
        return START_NOT_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        hideOverlay()
        instance = null
    }
    
    private fun showFloatingButton() {
        if (overlayView != null || windowManager == null) return
        
        isActive = true
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
            else 
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 200
        }
        
        overlayView = createFloatingButton()
        windowManager?.addView(overlayView, params)
        
        setupDragListener(params)
    }
    
    private fun createFloatingButton(): View {
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 16, 16, 16)
        }
        
        val button = LinearLayout(this).apply {
            setBackgroundResource(R.drawable.overlay_button_background)
            setPadding(24, 16, 24, 16)
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            
            setOnClickListener {
                toggleOverlay()
            }
        }
        
        val icon = TextView(this).apply {
            text = "\uD83D\uDEE1\uFE0F"
            textSize = 20f
        }
        
        val label = TextView(this).apply {
            text = " LegalEase"
            setTextColor(resources.getColor(android.R.color.white, null))
            textSize = 14f
        }
        
        button.addView(icon)
        button.addView(label)
        container.addView(button)
        
        return container
    }
    
    private fun toggleOverlay() {
        if (isExpanded) {
            collapseOverlay()
        } else {
            expandOverlay()
        }
    }
    
    private fun expandOverlay() {
        if (overlayView == null || windowManager == null) return
        isExpanded = true
        
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) 
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY 
            else 
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.CENTER
        }
        
        windowManager?.removeView(overlayView)
        overlayView = createExpandedView()
        windowManager?.addView(overlayView, params)
        
        OverlayEventSender.sendEvent("overlay_expanded", mapOf(
            "text" to currentText
        ))
        
        setupOutsideTouchListener(params)
    }
    
    private fun collapseOverlay() {
        if (overlayView == null || windowManager == null) return
        isExpanded = false
        
        windowManager?.removeView(overlayView)
        overlayView = null
        showFloatingButton()
    }
    
    private fun createExpandedView(): View {
        return LayoutInflater.from(this).inflate(R.layout.overlay_expanded, null).apply {
            findViewById<ImageView>(R.id.btnClose)?.setOnClickListener {
                collapseOverlay()
            }
            
            findViewById<Button>(R.id.btnAnalyze)?.setOnClickListener {
                openMainActivity("analyze")
            }
            
            findViewById<Button>(R.id.btnSummarize)?.setOnClickListener {
                openMainActivity("summarize")
            }
            
            findViewById<Button>(R.id.btnTranslate)?.setOnClickListener {
                openMainActivity("translate")
            }
            
            findViewById<TextView>(R.id.tvPreview)?.text = 
                if (currentText.length > 150) "${currentText.take(150)}..." else currentText
        }
    }
    
    private fun openMainActivity(action: String) {
        val intent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("action", action)
            putExtra("text", currentText)
        }
        startActivity(intent)
        hideOverlay()
    }
    
    private fun hideOverlay() {
        if (overlayView != null && windowManager != null) {
            try {
                windowManager?.removeView(overlayView)
            } catch (e: Exception) {
                // View may already be removed
            }
            overlayView = null
            isActive = false
            isExpanded = false
        }
    }
    
    private fun setupDragListener(params: WindowManager.LayoutParams) {
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        
        overlayView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(overlayView, params)
                    true
                }
                else -> false
            }
        }
    }
    
    private fun setupOutsideTouchListener(params: WindowManager.LayoutParams) {
        overlayView?.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_OUTSIDE) {
                collapseOverlay()
                true
            } else {
                false
            }
        }
    }
}
