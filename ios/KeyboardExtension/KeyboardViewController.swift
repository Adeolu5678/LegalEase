//
//  KeyboardViewController.swift
//  LegalEase Keyboard Extension
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, select your project in the navigator
//  2. File > New > Target
//  3. Select "Custom Keyboard Extension" under iOS > Application Extension
//  4. Name it "KeyboardExtension"
//  5. Replace the generated KeyboardViewController.swift with this file
//  6. Enable App Groups in both the main app and extension targets:
//     - Select target > Signing & Capabilities > + Capability > App Groups
//     - Add "group.com.legalease.shared" to both targets
//  7. Add the URL scheme to the main app's Info.plist (see Runner/Info.plist)
//

import UIKit

class KeyboardViewController: UIInputViewController {
    
    private var keyboardView: UIView!
    private var textView: UITextView!
    private var analyzeButton: UIButton!
    private var legalEaseButton: UIButton!
    private var statusLabel: UILabel!
    
    private let tcKeywords = [
        "terms and conditions", "terms of service", "privacy policy",
        "eula", "end user license", "user agreement", "legal",
        "by clicking", "by using", "you agree", "binding agreement",
        "governing law", "jurisdiction", "indemnification",
        "limitation of liability", "disclaimer", "warranty"
    ]
    
    private let appGroupIdentifier = "group.com.legalease.shared"
    private let urlScheme = "legalease"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardView()
        setupKeyboardHeight()
    }
    
    private func setupKeyboardHeight() {
        self.inputView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 280)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        keyboardView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 280)
    }
    
    private func setupKeyboardView() {
        keyboardView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 280))
        keyboardView.backgroundColor = .systemBackground
        keyboardView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textView = UITextView()
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.textColor = .label
        textView.text = "Tap in a text field to preview content..."
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        analyzeButton = UIButton(type: .system)
        analyzeButton.setTitle("🛡️ Analyze for Legal Issues", for: .normal)
        analyzeButton.backgroundColor = .systemBlue
        analyzeButton.setTitleColor(.white, for: .normal)
        analyzeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        analyzeButton.layer.cornerRadius = 12
        analyzeButton.addTarget(self, action: #selector(analyzeText), for: .touchUpInside)
        analyzeButton.translatesAutoresizingMaskIntoConstraints = false
        
        legalEaseButton = UIButton(type: .system)
        legalEaseButton.setTitle("📋 Quick Actions", for: .normal)
        legalEaseButton.backgroundColor = .secondarySystemFill
        legalEaseButton.setTitleColor(.label, for: .normal)
        legalEaseButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        legalEaseButton.layer.cornerRadius = 12
        legalEaseButton.addTarget(self, action: #selector(showLegalOptions), for: .touchUpInside)
        legalEaseButton.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.text = "LegalEase Keyboard Ready"
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonStack = UIStackView(arrangedSubviews: [analyzeButton, legalEaseButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainStack = UIStackView(arrangedSubviews: [textView, buttonStack, statusLabel])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        keyboardView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: keyboardView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor, constant: -16),
            
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            analyzeButton.heightAnchor.constraint(equalToConstant: 50),
            legalEaseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(keyboardView)
        updateTextPreview()
    }
    
    private func updateTextPreview() {
        guard let proxy = textDocumentProxy else { return }
        
        let context = proxy.documentContextBeforeInput ?? ""
        let afterContext = proxy.documentContextAfterInput ?? ""
        let selectedText = proxy.selectedText ?? ""
        let fullText = context + selectedText + afterContext
        
        let displayText = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if displayText.isEmpty {
                self.textView.text = "No text detected. Tap in a text field first."
                self.textView.textColor = .secondaryLabel
                self.resetAnalyzeButton()
            } else {
                self.textView.text = displayText
                self.textView.textColor = .label
                
                if self.containsTcContent(displayText) {
                    self.highlightLegalContent()
                } else {
                    self.resetAnalyzeButton()
                }
            }
        }
    }
    
    private func containsTcContent(_ text: String) -> Bool {
        let lowerText = text.lowercased()
        return tcKeywords.contains { lowerText.contains($0) }
    }
    
    private func highlightLegalContent() {
        analyzeButton.backgroundColor = .systemOrange
        analyzeButton.setTitle("⚠️ Legal Text Detected - Tap to Analyze", for: .normal)
        statusLabel.text = "⚠️ Potential legal content detected"
        statusLabel.textColor = .systemOrange
    }
    
    private func resetAnalyzeButton() {
        analyzeButton.backgroundColor = .systemBlue
        analyzeButton.setTitle("🛡️ Analyze for Legal Issues", for: .normal)
        statusLabel.text = "LegalEase Keyboard Ready"
        statusLabel.textColor = .secondaryLabel
    }
    
    @objc private func analyzeText() {
        guard let text = textView.text,
              !text.isEmpty,
              !text.contains("No text detected") else {
            showNoTextAlert()
            return
        }
        
        sendToMainApp(text: text, action: "analyze")
    }
    
    private func showNoTextAlert() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        label.text = "No text to analyze"
        label.textAlignment = .center
        label.backgroundColor = .systemRed
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.center = keyboardView.center
        
        keyboardView.addSubview(label)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            label.removeFromSuperview()
        }
    }
    
    @objc private func showLegalOptions() {
        guard let text = textView.text,
              !text.isEmpty,
              !text.contains("No text detected") else {
            showNoTextAlert()
            return
        }
        
        let alert = UIAlertController(title: "LegalEase Actions", message: "Choose an action for the selected text", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "🔍 Check for Red Flags", style: .default) { [weak self] _ in
            self?.sendToMainApp(text: text, action: "analyze")
        })
        
        alert.addAction(UIAlertAction(title: "📝 Translate to Plain English", style: .default) { [weak self] _ in
            self?.sendToMainApp(text: text, action: "translate")
        })
        
        alert.addAction(UIAlertAction(title: "📄 Summarize", style: .default) { [weak self] _ in
            self?.sendToMainApp(text: text, action: "summarize")
        })
        
        alert.addAction(UIAlertAction(title: "❓ Ask Question", style: .default) { [weak self] _ in
            self?.sendToMainApp(text: text, action: "ask")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func sendToMainApp(text: String, action: String) {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        
        let sharedData: [String: Any] = [
            "text": text,
            "action": action,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        sharedDefaults?.set(sharedData, forKey: "keyboard_shared_data")
        sharedDefaults?.synchronize()
        
        let urlString = "\(urlScheme)://\(action)?from=keyboard&timestamp=\(Date().timeIntervalSince1970)"
        
        if let url = URL(string: urlString) {
            self.extensionContext?.open(url) { success in
                if !success {
                    DispatchQueue.main.async {
                        self.showOpenAppFailedAlert()
                    }
                }
            }
        }
    }
    
    private func showOpenAppFailedAlert() {
        let alert = UIAlertController(
            title: "Cannot Open App",
            message: "Please open LegalEase manually to analyze the text. The text has been saved.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        updateTextPreview()
    }
    
    override func selectionWillChange(_ textInput: UITextInput?) {
        updateTextPreview()
    }
    
    override func selectionDidChange(_ textInput: UITextInput?) {
        updateTextPreview()
    }
}
