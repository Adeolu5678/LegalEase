#include "desktop_overlay.h"
#include <dwmapi.h>

const wchar_t* DesktopOverlay::kOverlayClassName = L"LegalEaseOverlayWindow";
bool DesktopOverlay::class_registered_ = false;

DesktopOverlay::DesktopOverlay() {}

DesktopOverlay::~DesktopOverlay() {
    Destroy();
}

void DesktopOverlay::RegisterWindowClass() {
    if (class_registered_) return;
    
    WNDCLASS wc = {};
    wc.lpfnWndProc = WndProc;
    wc.hInstance = GetModuleHandle(nullptr);
    wc.lpszClassName = kOverlayClassName;
    wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
    wc.hbrBackground = CreateSolidBrush(RGB(30, 30, 30));
    wc.style = CS_HREDRAW | CS_VREDRAW;
    
    RegisterClass(&wc);
    class_registered_ = true;
}

bool DesktopOverlay::Create(int x, int y, int width, int height) {
    Destroy();
    
    RegisterWindowClass();
    
    position_x_ = x;
    position_y_ = y;
    width_ = width;
    height_ = height;
    expanded_height_ = height;
    
    DWORD ex_style = WS_EX_LAYERED | WS_EX_TOPMOST | WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT;
    DWORD style = WS_POPUP;
    
    window_handle_ = CreateWindowEx(
        ex_style,
        kOverlayClassName,
        L"LegalEase Writing Assistant",
        style,
        x, y, width, height,
        nullptr,
        nullptr,
        GetModuleHandle(nullptr),
        this
    );
    
    if (!window_handle_) {
        return false;
    }
    
    SetLayeredWindowAttributes(window_handle_, RGB(1, 1, 1), 0, LWA_COLORKEY);
    SetLayeredWindowAttributes(window_handle_, 0, 255, LWA_ALPHA);
    
    MARGINS margins = { -1, -1, -1, -1 };
    DwmExtendFrameIntoClientArea(window_handle_, &margins);
    
    BOOL dark_mode = TRUE;
    DwmSetWindowAttribute(window_handle_, 20, &dark_mode, sizeof(dark_mode));
    
    return true;
}

void DesktopOverlay::Destroy() {
    if (window_handle_) {
        DestroyWindow(window_handle_);
        window_handle_ = nullptr;
    }
    is_visible_ = false;
}

void DesktopOverlay::Show() {
    if (window_handle_) {
        ShowWindow(window_handle_, SW_SHOWNOACTIVATE);
        SetWindowPos(window_handle_, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        is_visible_ = true;
    }
}

void DesktopOverlay::Hide() {
    if (window_handle_) {
        ShowWindow(window_handle_, SW_HIDE);
        is_visible_ = false;
    }
}

void DesktopOverlay::SetPosition(int x, int y) {
    position_x_ = x;
    position_y_ = y;
    if (window_handle_) {
        SetWindowPos(window_handle_, nullptr, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
}

void DesktopOverlay::SetSize(int width, int height) {
    width_ = width;
    expanded_height_ = height;
    if (window_handle_ && !is_minimized_) {
        SetWindowPos(window_handle_, nullptr, 0, 0, width, height, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
}

void DesktopOverlay::SetAlwaysOnTop(bool alwaysOnTop) {
    always_on_top_ = alwaysOnTop;
    if (window_handle_) {
        SetWindowPos(
            window_handle_,
            alwaysOnTop ? HWND_TOPMOST : HWND_NOTOPMOST,
            0, 0, 0, 0,
            SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE
        );
    }
}

void DesktopOverlay::Minimize() {
    is_minimized_ = true;
    if (window_handle_) {
        SetWindowPos(window_handle_, nullptr, 0, 0, width_, minimized_height_, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
}

void DesktopOverlay::Expand() {
    is_minimized_ = false;
    if (window_handle_) {
        SetWindowPos(window_handle_, nullptr, 0, 0, width_, expanded_height_, SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
}

bool DesktopOverlay::IsVisible() const {
    return is_visible_;
}

bool DesktopOverlay::IsMinimized() const {
    return is_minimized_;
}

void DesktopOverlay::GetPosition(int& x, int& y) const {
    x = position_x_;
    y = position_y_;
}

void DesktopOverlay::GetSize(int& width, int& height) const {
    width = width_;
    height = is_minimized_ ? minimized_height_ : expanded_height_;
}

void DesktopOverlay::SetFlutterViewController(flutter::FlutterViewController* controller) {
    flutter_controller_ = controller;
}

void DesktopOverlay::SetOnCloseCallback(std::function<void()> callback) {
    on_close_callback_ = callback;
}

LRESULT CALLBACK DesktopOverlay::WndProc(HWND window, UINT message, WPARAM wparam, LPARAM lparam) {
    if (message == WM_NCCREATE) {
        auto create_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
        SetWindowLongPtr(window, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(create_struct->lpCreateParams));
    }
    
    DesktopOverlay* that = GetThisFromHandle(window);
    if (that) {
        return that->MessageHandler(window, message, wparam, lparam);
    }
    
    return DefWindowProc(window, message, wparam, lparam);
}

DesktopOverlay* DesktopOverlay::GetThisFromHandle(HWND window) {
    return reinterpret_cast<DesktopOverlay*>(GetWindowLongPtr(window, GWLP_USERDATA));
}

LRESULT DesktopOverlay::MessageHandler(HWND window, UINT message, WPARAM wparam, LPARAM lparam) {
    switch (message) {
        case WM_DESTROY:
            window_handle_ = nullptr;
            is_visible_ = false;
            if (on_close_callback_) {
                on_close_callback_();
            }
            return 0;
            
        case WM_CLOSE:
            Hide();
            return 0;
            
        case WM_SIZE:
            if (flutter_controller_) {
                RECT rect;
                GetClientRect(window, &rect);
                flutter_controller_->OnWindowSizeChanged(rect.right - rect.left, rect.bottom - rect.top);
            }
            return 0;
            
        case WM_ERASEBKGND:
            return 1;
            
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(window, &ps);
            RECT rect;
            GetClientRect(window, &rect);
            FillRect(hdc, &rect, CreateSolidBrush(RGB(30, 30, 30)));
            EndPaint(window, &ps);
            return 0;
        }
            
        default:
            return DefWindowProc(window, message, wparam, lparam);
    }
}
