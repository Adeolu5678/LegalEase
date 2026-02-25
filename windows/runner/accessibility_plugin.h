#ifndef RUNNER_ACCESSIBILITY_PLUGIN_H_
#define RUNNER_ACCESSIBILITY_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>
#include <string>
#include "ui_automation.h"

class AccessibilityPlugin : public flutter::Plugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

    AccessibilityPlugin();
    virtual ~AccessibilityPlugin();

    AccessibilityPlugin(const AccessibilityPlugin&) = delete;
    AccessibilityPlugin& operator=(const AccessibilityPlugin&) = delete;

private:
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    flutter::EncodableValue IsAccessibilityEnabled();
    flutter::EncodableValue ExtractScreenText();
    flutter::EncodableValue GetForegroundWindow();
    flutter::EncodableValue HasOverlayPermission();
    flutter::EncodableValue StartMonitoring();
    flutter::EncodableValue StopMonitoring();

    std::unique_ptr<UIAutomation> uiAutomation_;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> eventSink_;
};

class AccessibilityStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
public:
    AccessibilityStreamHandler(UIAutomation* uiAutomation);
    virtual ~AccessibilityStreamHandler();

protected:
    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
        const flutter::EncodableValue* arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override;

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
        const flutter::EncodableValue* arguments) override;

private:
    UIAutomation* uiAutomation_;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> sink_;
};

#endif
