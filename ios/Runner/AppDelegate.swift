import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    private let keyboardChannel = "legalease_ios_keyboard"
    private let appGroupIdentifier = "group.com.legalease.shared"
    private var sharedDataKey = "keyboard_shared_data"
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    setupKeyboardChannel()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func setupKeyboardChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return
        }
        
        let channel = FlutterMethodChannel(
            name: keyboardChannel,
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "isKeyboardEnabled":
                result(self?.isKeyboardExtensionEnabled())
            case "hasFullAccess":
                result(self?.hasFullAccessEnabled())
            case "openKeyboardSettings":
                self?.openKeyboardSettings()
                result(nil)
            case "getSharedData":
                result(self?.getSharedData())
            case "clearSharedData":
                self?.clearSharedData()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func isKeyboardExtensionEnabled() -> Bool {
        guard let keyboards = UserDefaults.standard.array(forKey: "AppleKeyboards") as? [String] else {
            return false
        }
        return keyboards.contains { $0.contains("KeyboardExtension") }
    }
    
    private func hasFullAccessEnabled() -> Bool {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        return sharedDefaults?.bool(forKey: "has_full_access") ?? false
    }
    
    private func openKeyboardSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func getSharedData() -> [String: Any]? {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        return sharedDefaults?.dictionary(forKey: sharedDataKey)
    }
    
    private func clearSharedData() {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        sharedDefaults?.removeObject(forKey: sharedDataKey)
        sharedDefaults?.synchronize()
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let scheme = components.scheme,
              scheme == "legalease" else {
            return false
        }
        
        let action = components.host
        let queryItems = components.queryItems
        
        let isFromKeyboard = queryItems?.contains { $0.name == "from" && $0.value == "keyboard" } ?? false
        
        if isFromKeyboard {
            NotificationCenter.default.post(
                name: Notification.Name("KeyboardDataReceived"),
                object: nil,
                userInfo: ["action": action ?? "unknown"]
            )
        }
        
        return super.application(app, open: url, options: options) || true
    }
}
