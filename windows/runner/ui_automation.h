#ifndef RUNNER_UI_AUTOMATION_H_
#define RUNNER_UI_AUTOMATION_H_

#include <windows.h>
#include <objbase.h>
#include <UIAutomation.h>
#include <string>
#include <vector>
#include <functional>

class UIAutomation {
public:
    UIAutomation();
    ~UIAutomation();

    bool Initialize();
    bool IsInitialized() const { return automation_ != nullptr; }

    std::wstring GetForegroundWindowTitle();
    HWND GetForegroundWindowHandle();
    
    std::wstring ExtractTextFromForegroundWindow();
    std::wstring ExtractTextFromFocusedElement();
    std::wstring ExtractTextFromWindow(HWND hwnd);
    std::wstring ExtractAllTextFromElement(IUIAutomationElement* element);

    bool ContainsTCKewords(const std::wstring& text);
    bool ContainsPrivacyKeywords(const std::wstring& text);

    void SetForegroundWindowChangedCallback(std::function<void(HWND, const std::wstring&)> callback);
    void StartMonitoring();
    void StopMonitoring();
    bool IsMonitoring() const { return monitoring_; }

private:
    IUIAutomation* automation_;
    IUIAutomationCondition* textCondition_;
    IUIAutomationCondition* nameCondition_;
    bool comInitialized_;
    bool monitoring_;
    HWND lastForegroundWindow_;
    std::function<void(HWND, const std::wstring&)> foregroundWindowChangedCallback_;

    bool InitializeConditions();
    std::wstring GetElementText(IUIAutomationElement* element);
    std::wstring GetElementName(IUIAutomationElement* element);
    std::wstring GetElementValue(IUIAutomationElement* element);
    std::wstring GetElementTextPatternText(IUIAutomationElement* element);
};

#endif
