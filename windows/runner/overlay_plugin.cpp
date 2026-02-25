#include "overlay_plugin.h"
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <string>
#include <sstream>

static const char* kMethodChannelName = "legalease_desktop_overlay";
static const char* kEventChannelName = "legalease_desktop_overlay_events";

static std::string WstringToString(const std::wstring& wstr) {
    if (wstr.empty()) return std::string();
    int sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.length()), nullptr, 0, nullptr, nullptr);
    std::string result(sizeNeeded, 0);
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.length()), &result[0], sizeNeeded, nullptr, nullptr);
    return result;
}

static std::wstring StringToWstring(const std::string& str) {
    if (str.empty()) return std::wstring();
    int sizeNeeded = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), static_cast<int>(str.length()), nullptr, 0);
    std::wstring result(sizeNeeded, 0);
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), static_cast<int>(str.length()), &result[0], sizeNeeded);
    return result;
}

void OverlayPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
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

    auto plugin = std::make_unique<OverlayPlugin>(registrar);

    auto selectionHandler = std::make_unique<OverlayStreamHandler>(plugin.get(), true);
    auto clipboardHandler = std::make_unique<OverlayStreamHandler>(plugin.get(), false);

    eventChannel->SetStreamHandler(std::move(selectionHandler));

    methodChannel->SetMethodCallHandler(
        [plugin_ptr = plugin.get()](const auto& call, auto result) {
            plugin_ptr->HandleMethodCall(call, std::move(result));
        }
    );

    registrar->AddPlugin(std::move(plugin));
}

OverlayPlugin::OverlayPlugin(flutter::PluginRegistrarWindows* registrar)
    : registrar_(registrar), overlay_(std::make_unique<DesktopOverlay>()) {}

OverlayPlugin::~OverlayPlugin() {}

void OverlayPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
    const std::string& method_name = method_call.method_name();

    if (method_name == "showOverlay") {
        if (!overlay_->IsVisible()) {
            int x = 100, y = 100, width = 400, height = 500;
            overlay_->Create(x, y, width, height);
            overlay_->Show();
        } else {
            overlay_->Show();
        }
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "hideOverlay") {
        overlay_->Hide();
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "setPosition") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (arguments) {
            auto x_it = arguments->find(flutter::EncodableValue("x"));
            auto y_it = arguments->find(flutter::EncodableValue("y"));
            if (x_it != arguments->end() && y_it != arguments->end()) {
                double x = std::get<double>(x_it->second);
                double y = std::get<double>(y_it->second);
                overlay_->SetPosition(static_cast<int>(x), static_cast<int>(y));
            }
        }
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "setSize") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (arguments) {
            auto width_it = arguments->find(flutter::EncodableValue("width"));
            auto height_it = arguments->find(flutter::EncodableValue("height"));
            if (width_it != arguments->end() && height_it != arguments->end()) {
                double width = std::get<double>(width_it->second);
                double height = std::get<double>(height_it->second);
                overlay_->SetSize(static_cast<int>(width), static_cast<int>(height));
            }
        }
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "setAlwaysOnTop") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (arguments) {
            auto always_it = arguments->find(flutter::EncodableValue("alwaysOnTop"));
            if (always_it != arguments->end()) {
                bool alwaysOnTop = std::get<bool>(always_it->second);
                overlay_->SetAlwaysOnTop(alwaysOnTop);
            }
        }
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "minimize") {
        overlay_->Minimize();
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "expand") {
        overlay_->Expand();
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "isOverlayVisible") {
        result->Success(flutter::EncodableValue(overlay_->IsVisible()));
    } else if (method_name == "updateContent") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (arguments) {
            auto text_it = arguments->find(flutter::EncodableValue("text"));
            if (text_it != arguments->end()) {
                std::string text = std::get<std::string>(text_it->second);
                // Content is managed by Flutter, no native action needed
            }
        }
        result->Success(flutter::EncodableValue(true));
    } else if (method_name == "getPosition") {
        int x, y;
        overlay_->GetPosition(x, y);
        flutter::EncodableMap position;
        position[flutter::EncodableValue("x")] = flutter::EncodableValue(static_cast<double>(x));
        position[flutter::EncodableValue("y")] = flutter::EncodableValue(static_cast<double>(y));
        result->Success(flutter::EncodableValue(position));
    } else if (method_name == "getSize") {
        int width, height;
        overlay_->GetSize(width, height);
        flutter::EncodableMap size;
        size[flutter::EncodableValue("width")] = flutter::EncodableValue(static_cast<double>(width));
        size[flutter::EncodableValue("height")] = flutter::EncodableValue(static_cast<double>(height));
        result->Success(flutter::EncodableValue(size));
    } else {
        result->NotImplemented();
    }
}

void OverlayPlugin::SendSelectionEvent(const std::string& text, int start, int end) {
    if (selection_sink_) {
        flutter::EncodableMap event;
        event[flutter::EncodableValue("type")] = flutter::EncodableValue("selection");
        event[flutter::EncodableValue("text")] = flutter::EncodableValue(text);
        event[flutter::EncodableValue("start")] = flutter::EncodableValue(start);
        event[flutter::EncodableValue("end")] = flutter::EncodableValue(end);
        selection_sink_->Success(flutter::EncodableValue(event));
    }
}

void OverlayPlugin::SendClipboardEvent(const std::string& text) {
    if (clipboard_sink_) {
        flutter::EncodableMap event;
        event[flutter::EncodableValue("type")] = flutter::EncodableValue("clipboard");
        event[flutter::EncodableValue("text")] = flutter::EncodableValue(text);
        clipboard_sink_->Success(flutter::EncodableValue(event));
    }
}

OverlayStreamHandler::OverlayStreamHandler(OverlayPlugin* plugin, bool is_selection)
    : plugin_(plugin), is_selection_(is_selection) {}

OverlayStreamHandler::~OverlayStreamHandler() {}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OverlayStreamHandler::OnListenInternal(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
    
    if (is_selection_) {
        plugin_->selection_sink_ = std::move(events);
    } else {
        plugin_->clipboard_sink_ = std::move(events);
    }
    
    return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OverlayStreamHandler::OnCancelInternal(
    const flutter::EncodableValue* arguments) {
    
    if (is_selection_) {
        plugin_->selection_sink_.reset();
    } else {
        plugin_->clipboard_sink_.reset();
    }
    
    return nullptr;
}
