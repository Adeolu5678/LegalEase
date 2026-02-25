#include "ui_automation.h"
#include <algorithm>
#include <sstream>

UIAutomation::UIAutomation()
    : automation_(nullptr)
    , textCondition_(nullptr)
    , nameCondition_(nullptr)
    , comInitialized_(false)
    , monitoring_(false)
    , lastForegroundWindow_(nullptr) {
}

UIAutomation::~UIAutomation() {
    StopMonitoring();
    
    if (textCondition_) {
        textCondition_->Release();
        textCondition_ = nullptr;
    }
    if (nameCondition_) {
        nameCondition_->Release();
        nameCondition_ = nullptr;
    }
    if (automation_) {
        automation_->Release();
        automation_ = nullptr;
    }
    
    if (comInitialized_) {
        CoUninitialize();
    }
}

bool UIAutomation::Initialize() {
    HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    if (SUCCEEDED(hr)) {
        comInitialized_ = true;
    } else if (hr != RPC_E_CHANGED_MODE) {
        return false;
    }

    hr = CoCreateInstance(
        __uuidof(CUIAutomation),
        nullptr,
        CLSCTX_INPROC_SERVER,
        __uuidof(IUIAutomation),
        reinterpret_cast<void**>(&automation_)
    );

    if (FAILED(hr) || !automation_) {
        return false;
    }

    return InitializeConditions();
}

bool UIAutomation::InitializeConditions() {
    if (!automation_) return false;

    HRESULT hr = automation_->CreateTrueCondition(&textCondition_);
    if (FAILED(hr)) return false;

    return true;
}

std::wstring UIAutomation::GetForegroundWindowTitle() {
    HWND hwnd = GetForegroundWindow();
    if (!hwnd) return L"";

    wchar_t title[256] = {0};
    GetWindowTextW(hwnd, title, 256);
    return std::wstring(title);
}

HWND UIAutomation::GetForegroundWindowHandle() {
    return GetForegroundWindow();
}

std::wstring UIAutomation::GetElementName(IUIAutomationElement* element) {
    if (!element) return L"";

    BSTR name = nullptr;
    HRESULT hr = element->get_CurrentName(&name);
    if (SUCCEEDED(hr) && name) {
        std::wstring result(name);
        SysFreeString(name);
        return result;
    }
    return L"";
}

std::wstring UIAutomation::GetElementValue(IUIAutomationElement* element) {
    if (!element) return L"";

    VARIANT value;
    VariantInit(&value);
    HRESULT hr = element->GetCurrentPropertyValue(UIA_ValueValuePropertyId, &value);
    if (SUCCEEDED(hr) && value.vt == VT_BSTR && value.bstrVal) {
        std::wstring result(value.bstrVal);
        VariantClear(&value);
        return result;
    }
    VariantClear(&value);
    return L"";
}

std::wstring UIAutomation::GetElementTextPatternText(IUIAutomationElement* element) {
    if (!element) return L"";

    ITextProvider* textProvider = nullptr;
    HRESULT hr = element->GetCurrentPatternAs(UIA_TextPatternId, __uuidof(ITextProvider), reinterpret_cast<void**>(&textProvider));
    if (FAILED(hr) || !textProvider) return L"";

    std::wstring result;
    ITextRangeProvider* textRange = nullptr;
    hr = textProvider->get_DocumentRange(&textRange);
    if (SUCCEEDED(hr) && textRange) {
        BSTR text = nullptr;
        hr = textRange->GetText(-1, &text);
        if (SUCCEEDED(hr) && text) {
            result = std::wstring(text);
            SysFreeString(text);
        }
        textRange->Release();
    }
    textProvider->Release();
    return result;
}

std::wstring UIAutomation::GetElementText(IUIAutomationElement* element) {
    if (!element) return L"";

    std::wstring result;

    std::wstring textPatternText = GetElementTextPatternText(element);
    if (!textPatternText.empty()) {
        result = textPatternText;
    }

    std::wstring name = GetElementName(element);
    if (!name.empty()) {
        if (!result.empty()) result += L" ";
        result += name;
    }

    std::wstring value = GetElementValue(element);
    if (!value.empty()) {
        if (!result.empty()) result += L" ";
        result += value;
    }

    return result;
}

std::wstring UIAutomation::ExtractTextFromForegroundWindow() {
    HWND hwnd = GetForegroundWindow();
    return ExtractTextFromWindow(hwnd);
}

std::wstring UIAutomation::ExtractTextFromFocusedElement() {
    if (!automation_) return L"";

    IUIAutomationElement* focusedElement = nullptr;
    HRESULT hr = automation_->GetFocusedElement(&focusedElement);
    if (FAILED(hr) || !focusedElement) return L"";

    std::wstring result = ExtractAllTextFromElement(focusedElement);
    focusedElement->Release();
    return result;
}

std::wstring UIAutomation::ExtractTextFromWindow(HWND hwnd) {
    if (!automation_ || !hwnd) return L"";

    IUIAutomationElement* rootElement = nullptr;
    HRESULT hr = automation_->ElementFromHandle(hwnd, &rootElement);
    if (FAILED(hr) || !rootElement) return L"";

    std::wstring result = ExtractAllTextFromElement(rootElement);
    rootElement->Release();
    return result;
}

std::wstring UIAutomation::ExtractAllTextFromElement(IUIAutomationElement* element) {
    if (!element || !automation_) return L"";

    std::wstring result = GetElementText(element);

    IUIAutomationElementArray* children = nullptr;
    HRESULT hr = element->FindAll(TreeScope_Descendants, textCondition_, &children);
    if (FAILED(hr) || !children) return result;

    int length = 0;
    hr = children->get_Length(&length);
    if (FAILED(hr)) {
        children->Release();
        return result;
    }

    for (int i = 0; i < length; i++) {
        IUIAutomationElement* child = nullptr;
        hr = children->GetElement(i, &child);
        if (SUCCEEDED(hr) && child) {
            std::wstring childText = GetElementText(child);
            if (!childText.empty()) {
                if (!result.empty()) result += L"\n";
                result += childText;
            }
            child->Release();
        }
    }

    children->Release();
    return result;
}

bool UIAutomation::ContainsTCKewords(const std::wstring& text) {
    if (text.empty()) return false;

    std::wstring lowerText = text;
    std::transform(lowerText.begin(), lowerText.end(), lowerText.begin(), ::towlower);

    const std::vector<std::wstring> keywords = {
        L"terms and conditions",
        L"terms of service",
        L"terms of use",
        L"user agreement",
        L"end user license",
        L"eula",
        L"license agreement",
        L"service agreement",
        L"subscription agreement",
        L"membership agreement",
        L"terms & conditions",
        L"t&c",
        L"legal terms",
        L"agreement to terms"
    };

    for (const auto& keyword : keywords) {
        if (lowerText.find(keyword) != std::wstring::npos) {
            return true;
        }
    }
    return false;
}

bool UIAutomation::ContainsPrivacyKeywords(const std::wstring& text) {
    if (text.empty()) return false;

    std::wstring lowerText = text;
    std::transform(lowerText.begin(), lowerText.end(), lowerText.begin(), ::towlower);

    const std::vector<std::wstring> keywords = {
        L"privacy policy",
        L"privacy notice",
        L"data protection",
        L"data collection",
        L"personal data",
        L"personal information",
        L"privacy statement",
        L"privacy practices",
        L"information we collect",
        L"how we use your information",
        L"cookie policy",
        L"data sharing"
    };

    for (const auto& keyword : keywords) {
        if (lowerText.find(keyword) != std::wstring::npos) {
            return true;
        }
    }
    return false;
}

void UIAutomation::SetForegroundWindowChangedCallback(std::function<void(HWND, const std::wstring&)> callback) {
    foregroundWindowChangedCallback_ = callback;
}

void UIAutomation::StartMonitoring() {
    if (monitoring_) return;
    monitoring_ = true;
    lastForegroundWindow_ = GetForegroundWindow();
}

void UIAutomation::StopMonitoring() {
    monitoring_ = false;
}
