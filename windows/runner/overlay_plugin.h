#ifndef RUNNER_OVERLAY_PLUGIN_H_
#define RUNNER_OVERLAY_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>
#include "desktop_overlay.h"

class OverlayPlugin : public flutter::Plugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

    OverlayPlugin(flutter::PluginRegistrarWindows* registrar);
    virtual ~OverlayPlugin();

    OverlayPlugin(const OverlayPlugin&) = delete;
    OverlayPlugin& operator=(const OverlayPlugin&) = delete;

private:
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    void SendSelectionEvent(const std::string& text, int start, int end);
    void SendClipboardEvent(const std::string& text);

    std::unique_ptr<DesktopOverlay> overlay_;
    flutter::PluginRegistrarWindows* registrar_;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> selection_sink_;
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> clipboard_sink_;
};

class OverlayStreamHandler : public flutter::StreamHandler<flutter::EncodableValue> {
public:
    OverlayStreamHandler(OverlayPlugin* plugin, bool is_selection);
    virtual ~OverlayStreamHandler();

protected:
    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListenInternal(
        const flutter::EncodableValue* arguments,
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) override;

    std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancelInternal(
        const flutter::EncodableValue* arguments) override;

private:
    OverlayPlugin* plugin_;
    bool is_selection_;
};

#endif
