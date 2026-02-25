#include "accessibility_plugin.h"
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>
#include <sstream>

static const char* kMethodChannelName = "legalease_windows_accessibility";
static const char* kEventChannelName = "legalease_windows_accessibility_events";

static const char* kMethodIsAccessibilityEnabled = "isAccessibilityEnabled";
static const char* kMethodExtractScreenText = "extractScreenText";
static const char* kMethodGetForegroundWindow = "getForegroundWindow";
static const char* kMethodHasOverlayPermission = "hasOverlayPermission";
static const char* kMethodStartMonitoring = "startMonitoring";
static const char* kMethodStopMonitoring = "stopMonitoring";

static std::string WstringToString(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.length()), nullptr, 0, nullptr, nullptr);
    std::string result(sizeNeeded, 0);
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.length()), &result[0], sizeNeeded, nullptr, nullptr);
    return result;
}

void AccessibilityPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
    auto methodChannel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(),
        kMethodChannelName,
        &flutter::StandardMethodCodec::GetInstance()
    );

    auto eventChannel = std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
        registrar->messenger(),
        kEventChannelName,
        &flutter::StandardMethodCodec::GetInstance()
    );

    auto plugin = std::make_unique<AccessibilityPlugin>();

    plugin->uiAutomation_ = std::make_unique<UIAutomation>();
    if (!plugin->uiAutomation_->Initialize()) {
        OutputDebugStringW(L"Warning: UI Automation initialization failed\n");
    }

    auto handler = std::make_unique<AccessibilityStreamHandler>(plugin->uiAutomation_.get());
    eventChannel->SetStreamHandler(std::move(handler));

    methodChannel->SetMethodCallHandler(
        [plugin_ptr = plugin.get()](const auto& call, auto result) {
            plugin_ptr->HandleMethodCall(call, std::move(result));
        }
    );

    registrar->AddPlugin(std::move(plugin));
}

AccessibilityPlugin::AccessibilityPlugin() {}

AccessibilityPlugin::~AccessibilityPlugin() {}

void AccessibilityPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
    const std::string& method_name = method_call.method_name();

    if (method_name == kMethodIsAccessibilityEnabled) {
        result->Success(IsAccessibilityEnabled());
    } else if (method_name == kMethodExtractScreenText) {
        result->Success(ExtractScreenText());
    } else if (method_name == kMethodGetForegroundWindow) {
        result->Success(GetForegroundWindow());
    } else if (method_name == kMethodHasOverlayPermission) {
        result->Success(HasOverlayPermission());
    } else if (method_name == kMethodStartMonitoring) {
        result->Success(StartMonitoring());
    } else if (method_name == kMethodStopMonitoring) {
        result->Success(StopMonitoring());
    } else {
        result->NotImplemented();
    }
}

flutter::EncodableValue AccessibilityPlugin::IsAccessibilityEnabled() {
    return flutter::EncodableValue(true);
}

flutter::EncodableValue AccessibilityPlugin::ExtractScreenText() {
    if (!uiAutomation_ || !uiAutomation_->IsInitialized()) {
        return flutter::EncodableValue("");
    }

    std::wstring text = uiAutomation_->ExtractTextFromForegroundWindow();
    return flutter::EncodableValue(WstringToString(text));
}

flutter::EncodableValue AccessibilityPlugin::GetForegroundWindow() {
    flutter::EncodableMap result;
    
    if (!uiAutomation_) {
        result[flutter::EncodableValue("title")] = flutter::EncodableValue("");
        result[flutter::EncodableValue("handle")] = flutter::EncodableValue(0);
        return flutter::EncodableValue(result);
    }

    std::wstring title = uiAutomation_->GetForegroundWindowTitle();
    HWND handle = uiAutomation_->GetForegroundWindowHandle();

    result[flutter::EncodableValue("title")] = flutter::EncodableValue(WstringToString(title));
    result[flutter::EncodableValue("handle")] = flutter::EncodableValue(static_cast<int64_t>(reinterpret_cast<intptr_t>(handle)));
    result[flutter::EncodableValue("hasTCKeywords")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("hasPrivacyKeywords")] = flutter::EncodableValue(false);

    if (uiAutomation_->IsInitialized()) {
        std::wstring text = uiAutomation_->ExtractTextFromForegroundWindow();
        result[flutter::EncodableValue("hasTCKeywords")] = flutter::EncodableValue(uiAutomation_->ContainsTCKewords(text));
        result[flutter::EncodableValue("hasPrivacyKeywords")] = flutter::EncodableValue(uiAutomation_->ContainsPrivacyKeywords(text));
    }

    return flutter::EncodableValue(result);
}

flutter::EncodableValue AccessibilityPlugin::HasOverlayPermission() {
    return flutter::EncodableValue(true);
}

flutter::EncodableValue AccessibilityPlugin::StartMonitoring() {
    if (uiAutomation_) {
        uiAutomation_->StartMonitoring();
    }
    return flutter::EncodableValue(true);
}

flutter::EncodableValue AccessibilityPlugin::StopMonitoring() {
    if (uiAutomation_) {
        uiAutomation_->StopMonitoring();
    }
    return flutter::EncodableValue(true);
}

AccessibilityStreamHandler::AccessibilityStreamHandler(UIAutomation* uiAutomation)
    : uiAutomation_(uiAutomation), sink_(nullptr) {}

AccessibilityStreamHandler::~AccessibilityStreamHandler() {}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> AccessibilityStreamHandler::OnListenInternal(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
    
    sink_ = std::move(events);

    if (uiAutomation_) {
        uiAutomation_->SetForegroundWindowChangedCallback(
            [this](HWND hwnd, const std::wstring& title) {
                if (sink_) {
                    flutter::EncodableMap event;
                    event[flutter::EncodableValue("type")] = flutter::EncodableValue("foregroundWindowChanged");
                    event[flutter::EncodableValue("title")] = flutter::EncodableValue(WstringToString(title));
                    event[flutter::EncodableValue("handle")] = flutter::EncodableValue(static_cast<int64_t>(reinterpret_cast<intptr_t>(hwnd)));
                    sink_->Success(flutter::EncodableValue(event));
                }
            }
        );
        uiAutomation_->StartMonitoring();
    }

    return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> AccessibilityStreamHandler::OnCancelInternal(
    const flutter::EncodableValue* arguments) {
    
    if (uiAutomation_) {
        uiAutomation_->StopMonitoring();
        uiAutomation_->SetForegroundWindowChangedCallback(nullptr);
    }
    sink_.reset();
    
    return nullptr;
}