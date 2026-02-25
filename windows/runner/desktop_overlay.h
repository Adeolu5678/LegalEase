#ifndef RUNNER_DESKTOP_OVERLAY_H_
#define RUNNER_DESKTOP_OVERLAY_H_

#include <windows.h>
#include <flutter/flutter_view_controller.h>
#include <memory>
#include <functional>
#include <string>

class DesktopOverlay {
public:
    DesktopOverlay();
    ~DesktopOverlay();

    DesktopOverlay(const DesktopOverlay&) = delete;
    DesktopOverlay& operator=(const DesktopOverlay&) = delete;

    bool Create(int x, int y, int width, int height);
    void Destroy();
    
    void Show();
    void Hide();
    
    void SetPosition(int x, int y);
    void SetSize(int width, int height);
    void SetAlwaysOnTop(bool alwaysOnTop);
    
    void Minimize();
    void Expand();
    
    bool IsVisible() const;
    bool IsMinimized() const;
    
    void GetPosition(int& x, int& y) const;
    void GetSize(int& width, int& height) const;
    
    HWND GetHandle() const { return window_handle_; }
    
    void SetFlutterViewController(flutter::FlutterViewController* controller);
    
    void SetOnCloseCallback(std::function<void()> callback);

private:
    static LRESULT CALLBACK WndProc(HWND window, UINT message, WPARAM wparam, LPARAM lparam);
    static DesktopOverlay* GetThisFromHandle(HWND window);
    
    LRESULT MessageHandler(HWND window, UINT message, WPARAM wparam, LPARAM lparam);
    
    void UpdateWindowStyle();
    
    HWND window_handle_ = nullptr;
    bool is_visible_ = false;
    bool is_minimized_ = false;
    bool always_on_top_ = true;
    
    int position_x_ = 100;
    int position_y_ = 100;
    int width_ = 400;
    int height_ = 500;
    int minimized_height_ = 40;
    int expanded_height_ = 500;
    
    flutter::FlutterViewController* flutter_controller_ = nullptr;
    std::function<void()> on_close_callback_;
    
    static const wchar_t* kOverlayClassName;
    static bool class_registered_;
    
    static void RegisterWindowClass();
};

#endif
