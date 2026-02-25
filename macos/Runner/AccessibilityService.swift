import Cocoa
import ApplicationServices

struct AccessibilityTextResult {
    let text: String
    let elementRole: String
    let elementTitle: String?
    let hasKeywords: Bool
    let matchedKeywords: [String]
}

struct ExtractedContent {
    let fullText: String
    let elements: [AccessibilityTextResult]
    let detectedKeywords: [String]
    let applicationName: String
    let windowTitle: String?
}

class AccessibilityService {
    static let shared = AccessibilityService()
    
    private let tcKeywords = [
        "terms and conditions",
        "terms of service",
        "terms of use",
        "user agreement",
        "end user license agreement",
        "eula",
        "terms & conditions",
        "terms & service",
        "legal terms",
        "service agreement",
        "subscription agreement",
        "member agreement",
        "account agreement",
        "platform agreement"
    ]
    
    private let privacyKeywords = [
        "privacy policy",
        "privacy notice",
        "privacy statement",
        "data protection",
        "data collection",
        "personal data",
        "information we collect",
        "how we use your information",
        "privacy practices",
        "cookie policy",
        "privacy & cookies",
        "privacy and cookies",
        "data privacy"
    ]
    
    private var observer: AXObserver?
    private var monitoredElement: AXUIElement?
    private var onContentChanged: (() -> Void)?
    
    private init() {}
    
    func isAccessibilityEnabled() -> Bool {
        return AXIsProcessTrusted()
    }
    
    func requestAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func getFocusedApplication() -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedApp: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedApp)
        
        guard result == .success, let app = focusedApp else {
            return nil
        }
        
        var appName: CFTypeRef?
        AXUIElementCopyAttributeValue(app as! AXUIElement, kAXTitleAttribute as CFString, &appName)
        
        if let name = appName as? String {
            return name
        }
        
        if let pidRef = getPIDForAXUIElement(app as! AXUIElement) {
            if let runningApp = NSRunningApplication(processIdentifier: pidRef) {
                return runningApp.localizedName
            }
        }
        
        return nil
    }
    
    func extractScreenText() -> ExtractedContent? {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedApp: CFTypeRef?
        let appResult = AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedApp)
        
        guard appResult == .success, let app = focusedApp else {
            return nil
        }
        
        let appElement = app as! AXUIElement
        
        var appName = ""
        var appNameRef: CFTypeRef?
        AXUIElementCopyAttributeValue(appElement, kAXTitleAttribute as CFString, &appNameRef)
        if let name = appNameRef as? String {
            appName = name
        } else if let pidRef = getPIDForAXUIElement(appElement) {
            if let runningApp = NSRunningApplication(processIdentifier: pidRef) {
                appName = runningApp.localizedName ?? ""
            }
        }
        
        var windowTitle: String?
        var focusedWindow: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow) == .success {
            var titleRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(focusedWindow as! AXUIElement, kAXTitleAttribute as CFString, &titleRef) == .success {
                windowTitle = titleRef as? String
            }
        }
        
        var allTextElements: [AccessibilityTextResult] = []
        var allText = ""
        var allKeywords: Set<String> = []
        
        traverseElement(appElement, results: &allTextElements, allText: &allText, allKeywords: &allKeywords)
        
        let fullText = allText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return ExtractedContent(
            fullText: fullText,
            elements: allTextElements,
            detectedKeywords: Array(allKeywords).sorted(),
            applicationName: appName,
            windowTitle: windowTitle
        )
    }
    
    private func traverseElement(_ element: AXUIElement, results: inout [AccessibilityTextResult], allText: inout String, allKeywords: inout Set<String>, depth: Int = 0) {
        let maxDepth = 50
        guard depth < maxDepth else { return }
        
        var role: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        let roleString = (role as? String) ?? "unknown"
        
        let textContent = extractTextFromElement(element)
        
        if !textContent.isEmpty {
            let (hasKeywords, matchedKeywords) = detectKeywords(in: textContent)
            
            var title: String?
            var titleRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &titleRef) == .success {
                title = titleRef as? String
            }
            
            let result = AccessibilityTextResult(
                text: textContent,
                elementRole: roleString,
                elementTitle: title,
                hasKeywords: hasKeywords,
                matchedKeywords: matchedKeywords
            )
            
            results.append(result)
            allText += textContent + " "
            allKeywords.formUnion(matchedKeywords)
        }
        
        var children: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children) == .success {
            if let childrenArray = children as? [AXUIElement] {
                for child in childrenArray {
                    traverseElement(child, results: &results, allText: &allText, allKeywords: &allKeywords, depth: depth + 1)
                }
            }
        }
        
        var visibleChildren: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXVisibleChildrenAttribute as CFString, &visibleChildren) == .success {
            if let childrenArray = visibleChildren as? [AXUIElement] {
                for child in childrenArray {
                    traverseElement(child, results: &results, allText: &allText, allKeywords: &allKeywords, depth: depth + 1)
                }
            }
        }
    }
    
    private func extractTextFromElement(_ element: AXUIElement) -> String {
        var textParts: [String] = []
        
        var value: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value) == .success {
            if let stringValue = value as? String, !stringValue.isEmpty {
                textParts.append(stringValue)
            }
        }
        
        var title: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title) == .success {
            if let titleString = title as? String, !titleString.isEmpty {
                textParts.append(titleString)
            }
        }
        
        var description: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXDescriptionAttribute as CFString, &description) == .success {
            if let descString = description as? String, !descString.isEmpty {
                textParts.append(descString)
            }
        }
        
        var help: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXHelpAttribute as CFString, &help) == .success {
            if let helpString = help as? String, !helpString.isEmpty {
                textParts.append(helpString)
            }
        }
        
        var placeholderValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXPlaceholderValueAttribute as CFString, &placeholderValue) == .success {
            if let placeholderString = placeholderValue as? String, !placeholderString.isEmpty {
                textParts.append(placeholderString)
            }
        }
        
        return textParts.joined(separator: " ")
    }
    
    private func detectKeywords(in text: String) -> (Bool, [String]) {
        let lowercasedText = text.lowercased()
        var matchedKeywords: [String] = []
        
        let allKeywords = tcKeywords + privacyKeywords
        
        for keyword in allKeywords {
            if lowercasedText.contains(keyword.lowercased()) {
                matchedKeywords.append(keyword)
            }
        }
        
        return (!matchedKeywords.isEmpty, matchedKeywords)
    }
    
    func startMonitoring(onChange: @escaping () -> Void) -> Bool {
        guard isAccessibilityEnabled() else {
            return false
        }
        
        stopMonitoring()
        
        onContentChanged = onChange
        
        let systemWide = AXUIElementCreateSystemWide()
        monitoredElement = systemWide
        
        var observer: AXObserver?
        let result = AXObserverCreate(getpid(), { (observer, element, notification, refcon) in
            guard let refcon = refcon else { return }
            let service = Unmanaged<AccessibilityService>.fromOpaque(refcon).takeUnretainedValue()
            DispatchQueue.main.async {
                service.onContentChanged?()
            }
        }, &observer)
        
        guard result == .success, let axObserver = observer else {
            return false
        }
        
        self.observer = axObserver
        
        let refCon = Unmanaged.passUnretained(self).toOpaque()
        
        let notifications = [
            kAXFocusedWindowChangedNotification,
            kAXFocusedUIElementChangedNotification,
            kAXWindowCreatedNotification,
            kAXWindowMovedNotification,
            kAXWindowResizedNotification,
            kAXValueChangedNotification,
            kAXTitleChangedNotification
        ]
        
        for notification in notifications {
            AXObserverAddNotification(axObserver, systemWide, notification as CFString, refCon)
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(axObserver), .defaultMode)
        
        return true
    }
    
    func stopMonitoring() {
        guard let observer = observer else { return }
        
        let systemWide = AXUIElementCreateSystemWide()
        
        let notifications = [
            kAXFocusedWindowChangedNotification,
            kAXFocusedUIElementChangedNotification,
            kAXWindowCreatedNotification,
            kAXWindowMovedNotification,
            kAXWindowResizedNotification,
            kAXValueChangedNotification,
            kAXTitleChangedNotification
        ]
        
        for notification in notifications {
            AXObserverRemoveNotification(observer, systemWide, notification as CFString)
        }
        
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), .defaultMode)
        
        self.observer = nil
        self.monitoredElement = nil
        self.onContentChanged = nil
    }
    
    private func getPIDForAXUIElement(_ element: AXUIElement) -> pid_t? {
        var pid: pid_t = 0
        let result = AXUIElementGetPid(element, &pid)
        return result == .success ? pid : nil
    }
    
    func getFocusedUIElement() -> [String: Any]? {
        let systemWide = AXUIElementCreateSystemWide()
        
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard result == .success, let element = focusedElement else {
            return nil
        }
        
        let axElement = element as! AXUIElement
        
        var info: [String: Any] = [:]
        
        var role: CFTypeRef?
        if AXUIElementCopyAttributeValue(axElement, kAXRoleAttribute as CFString, &role) == .success {
            info["role"] = role as? String
        }
        
        var title: CFTypeRef?
        if AXUIElementCopyAttributeValue(axElement, kAXTitleAttribute as CFString, &title) == .success {
            info["title"] = title as? String
        }
        
        var value: CFTypeRef?
        if AXUIElementCopyAttributeValue(axElement, kAXValueAttribute as CFString, &value) == .success {
            info["value"] = value as? String
        }
        
        var description: CFTypeRef?
        if AXUIElementCopyAttributeValue(axElement, kAXDescriptionAttribute as CFString, &description) == .success {
            info["description"] = description as? String
        }
        
        return info
    }
}
