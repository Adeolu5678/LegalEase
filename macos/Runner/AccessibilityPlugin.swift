import Cocoa
import FlutterMacOS
import ApplicationServices

class AccessibilityPlugin: NSObject, FlutterStreamHandler {
    private var methodChannel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?
    private var isMonitoring = false
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = AccessibilityPlugin()
        
        instance.methodChannel = FlutterMethodChannel(
            name: "legalease_macos_accessibility",
            binaryMessenger: registrar.messenger
        )
        
        instance.eventChannel = FlutterEventChannel(
            name: "legalease_macos_accessibility_events",
            binaryMessenger: registrar.messenger
        )
        
        instance.eventChannel?.setStreamHandler(instance)
        
        registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAccessibilityEnabled":
            handleIsAccessibilityEnabled(result: result)
            
        case "requestAccessibilityPermission":
            handleRequestAccessibilityPermission(result: result)
            
        case "extractScreenText":
            handleExtractScreenText(result: result)
            
        case "getFocusedApplication":
            handleGetFocusedApplication(result: result)
            
        case "startMonitoring":
            handleStartMonitoring(result: result)
            
        case "stopMonitoring":
            handleStopMonitoring(result: result)
            
        case "getFocusedUIElement":
            handleGetFocusedUIElement(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleIsAccessibilityEnabled(result: @escaping FlutterResult) {
        let isEnabled = AccessibilityService.shared.isAccessibilityEnabled()
        result(isEnabled)
    }
    
    private func handleRequestAccessibilityPermission(result: @escaping FlutterResult) {
        let granted = AccessibilityService.shared.requestAccessibilityPermission()
        result(granted)
    }
    
    private func handleExtractScreenText(result: @escaping FlutterResult) {
        guard AccessibilityService.shared.isAccessibilityEnabled() else {
            result(FlutterError(
                code: "ACCESSIBILITY_DISABLED",
                message: "Accessibility permissions are not enabled",
                details: nil
            ))
            return
        }
        
        guard let content = AccessibilityService.shared.extractScreenText() else {
            result(FlutterError(
                code: "EXTRACTION_FAILED",
                message: "Failed to extract text from the focused application",
                details: nil
            ))
            return
        }
        
        let elementsData = content.elements.map { element -> [String: Any] in
            return [
                "text": element.text,
                "elementRole": element.elementRole,
                "elementTitle": element.elementTitle ?? "",
                "hasKeywords": element.hasKeywords,
                "matchedKeywords": element.matchedKeywords
            ]
        }
        
        let resultData: [String: Any] = [
            "fullText": content.fullText,
            "elements": elementsData,
            "detectedKeywords": content.detectedKeywords,
            "applicationName": content.applicationName,
            "windowTitle": content.windowTitle ?? ""
        ]
        
        result(resultData)
    }
    
    private func handleGetFocusedApplication(result: @escaping FlutterResult) {
        guard AccessibilityService.shared.isAccessibilityEnabled() else {
            result(FlutterError(
                code: "ACCESSIBILITY_DISABLED",
                message: "Accessibility permissions are not enabled",
                details: nil
            ))
            return
        }
        
        guard let appName = AccessibilityService.shared.getFocusedApplication() else {
            result(FlutterError(
                code: "NO_FOCUSED_APP",
                message: "Could not determine the focused application",
                details: nil
            ))
            return
        }
        
        result(appName)
    }
    
    private func handleStartMonitoring(result: @escaping FlutterResult) {
        guard AccessibilityService.shared.isAccessibilityEnabled() else {
            result(FlutterError(
                code: "ACCESSIBILITY_DISABLED",
                message: "Accessibility permissions are not enabled",
                details: nil
            ))
            return
        }
        
        if isMonitoring {
            result(true)
            return
        }
        
        let success = AccessibilityService.shared.startMonitoring { [weak self] in
            self?.sendChangeEvent()
        }
        
        isMonitoring = success
        
        result(success)
    }
    
    private func handleStopMonitoring(result: @escaping FlutterResult) {
        AccessibilityService.shared.stopMonitoring()
        isMonitoring = false
        result(nil)
    }
    
    private func handleGetFocusedUIElement(result: @escaping FlutterResult) {
        guard AccessibilityService.shared.isAccessibilityEnabled() else {
            result(FlutterError(
                code: "ACCESSIBILITY_DISABLED",
                message: "Accessibility permissions are not enabled",
                details: nil
            ))
            return
        }
        
        guard let elementInfo = AccessibilityService.shared.getFocusedUIElement() else {
            result(FlutterError(
                code: "NO_FOCUSED_ELEMENT",
                message: "Could not determine the focused UI element",
                details: nil
            ))
            return
        }
        
        result(elementInfo)
    }
    
    private func sendChangeEvent() {
        guard let sink = eventSink else { return }
        
        if let content = AccessibilityService.shared.extractScreenText() {
            let elementsData = content.elements.map { element -> [String: Any] in
                return [
                    "text": element.text,
                    "elementRole": element.elementRole,
                    "elementTitle": element.elementTitle ?? "",
                    "hasKeywords": element.hasKeywords,
                    "matchedKeywords": element.matchedKeywords
                ]
            }
            
            let eventData: [String: Any] = [
                "type": "contentChanged",
                "fullText": content.fullText,
                "elements": elementsData,
                "detectedKeywords": content.detectedKeywords,
                "applicationName": content.applicationName,
                "windowTitle": content.windowTitle ?? ""
            ]
            
            sink(eventData)
        }
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}