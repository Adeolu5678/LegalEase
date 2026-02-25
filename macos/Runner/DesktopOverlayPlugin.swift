import Cocoa
import FlutterMacOS

class DesktopOverlayPlugin: NSObject, FlutterStreamHandler {
    private var methodChannel: FlutterMethodChannel?
    private var selectionEventChannel: FlutterEventChannel?
    private var clipboardEventChannel: FlutterEventChannel?
    private var selectionEventSink: FlutterEventSink?
    private var clipboardEventSink: FlutterEventSink?
    
    private var overlayWindow: DesktopOverlayWindow?
    private var clipboardChangeTimer: Timer?
    private var lastClipboardContent: String = ""
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = DesktopOverlayPlugin()
        
        instance.methodChannel = FlutterMethodChannel(
            name: "legalease_desktop_overlay",
            binaryMessenger: registrar.messenger
        )
        
        instance.selectionEventChannel = FlutterEventChannel(
            name: "legalease_desktop_overlay_events/selection",
            binaryMessenger: registrar.messenger
        )
        
        instance.clipboardEventChannel = FlutterEventChannel(
            name: "legalease_desktop_overlay_events/clipboard",
            binaryMessenger: registrar.messenger
        )
        
        instance.selectionEventChannel?.setStreamHandler(instance)
        instance.clipboardEventChannel?.setStreamHandler(instance)
        
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showOverlay":
            handleShowOverlay(result: result)
            
        case "hideOverlay":
            handleHideOverlay(result: result)
            
        case "setPosition":
            handleSetPosition(call: call, result: result)
            
        case "setSize":
            handleSetSize(call: call, result: result)
            
        case "setAlwaysOnTop":
            handleSetAlwaysOnTop(call: call, result: result)
            
        case "minimize":
            handleMinimize(result: result)
            
        case "expand":
            handleExpand(result: result)
            
        case "isOverlayVisible":
            handleIsOverlayVisible(result: result)
            
        case "updateContent":
            handleUpdateContent(call: call, result: result)
            
        case "getPosition":
            handleGetPosition(result: result)
            
        case "getSize":
            handleGetSize(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleShowOverlay(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                result(false)
                return
            }
            
            if self.overlayWindow == nil {
                let frame = NSRect(x: 100, y: 100, width: 400, height: 500)
                self.overlayWindow = DesktopOverlayWindow(frame: frame)
            }
            
            self.overlayWindow?.showOverlay()
            result(true)
        }
    }
    
    private func handleHideOverlay(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.hideOverlay()
            result(true)
        }
    }
    
    private func handleSetPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let x = args["x"] as? Double,
              let y = args["y"] as? Double else {
            result(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            let point = NSPoint(x: x, y: y)
            self?.overlayWindow?.setPosition(point)
            result(true)
        }
    }
    
    private func handleSetSize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let width = args["width"] as? Double,
              let height = args["height"] as? Double else {
            result(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            let size = NSSize(width: width, height: height)
            self?.overlayWindow?.setSize(size)
            result(true)
        }
    }
    
    private func handleSetAlwaysOnTop(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let alwaysOnTop = args["alwaysOnTop"] as? Bool else {
            result(false)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.setAlwaysOnTop(alwaysOnTop)
            result(true)
        }
    }
    
    private func handleMinimize(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.minimize()
            result(true)
        }
    }
    
    private func handleExpand(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.expand()
            result(true)
        }
    }
    
    private func handleIsOverlayVisible(result: @escaping FlutterResult) {
        result(overlayWindow?.isOverlayVisible() ?? false)
    }
    
    private func handleUpdateContent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Content is managed by Flutter, no native action needed
        result(true)
    }
    
    private func handleGetPosition(result: @escaping FlutterResult) {
        guard let window = overlayWindow else {
            result(nil)
            return
        }
        
        let frame = window.frame
        result([
            "x": frame.origin.x,
            "y": frame.origin.y
        ])
    }
    
    private func handleGetSize(result: @escaping FlutterResult) {
        guard let window = overlayWindow else {
            result(nil)
            return
        }
        
        let frame = window.frame
        result([
            "width": frame.size.width,
            "height": frame.size.height
        ])
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        guard let args = arguments as? String else {
            // Default to selection events
            selectionEventSink = events
            return nil
        }
        
        if args == "selectionEvent" {
            selectionEventSink = events
            startSelectionMonitoring()
        } else if args == "clipboardEvent" {
            clipboardEventSink = events
            startClipboardMonitoring()
        }
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        guard let args = arguments as? String else {
            selectionEventSink = nil
            return nil
        }
        
        if args == "selectionEvent" {
            selectionEventSink = nil
            stopSelectionMonitoring()
        } else if args == "clipboardEvent" {
            clipboardEventSink = nil
            stopClipboardMonitoring()
        }
        
        return nil
    }
    
    private func startSelectionMonitoring() {
        // Monitor for text selection changes via accessibility API
        // This would integrate with the existing AccessibilityService
    }
    
    private func stopSelectionMonitoring() {
        // Stop monitoring
    }
    
    private func startClipboardMonitoring() {
        clipboardChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let pasteboard = NSPasteboard(name: .find),
               let content = pasteboard.string(forType: .string),
               content != self.lastClipboardContent {
                self.lastClipboardContent = content
                self.sendClipboardEvent(text: content)
            }
        }
    }
    
    private func stopClipboardMonitoring() {
        clipboardChangeTimer?.invalidate()
        clipboardChangeTimer = nil
    }
    
    private func sendSelectionEvent(text: String, start: Int, end: Int) {
        guard let sink = selectionEventSink else { return }
        
        let event: [String: Any] = [
            "type": "selection",
            "text": text,
            "start": start,
            "end": end
        ]
        
        sink(event)
    }
    
    private func sendClipboardEvent(text: String) {
        guard let sink = clipboardEventSink else { return }
        
        let event: [String: Any] = [
            "type": "clipboard",
            "text": text
        ]
        
        sink(event)
    }
}
