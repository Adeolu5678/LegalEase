// LegalEase Safari Extension - Content Script
// Detects T&C/Privacy Policy content on web pages
//
// Setup: This script runs automatically on all pages when the extension is enabled.
// It detects legal document keywords and shows a floating button for analysis.

(function() {
    'use strict';
    
    const TC_KEYWORDS = [
        'terms and conditions',
        'terms of service',
        'terms of use',
        'privacy policy',
        'eula',
        'end user license agreement',
        'user agreement',
        'legal notice',
        'cookie policy',
        'data protection'
    ];
    
    const TC_SELECTORS = [
        '[class*="terms"]',
        '[class*="privacy"]',
        '[class*="legal"]',
        '[id*="terms"]',
        '[id*="privacy"]',
        '[id*="legal"]',
        'article',
        'main',
        '.content',
        '#content'
    ];
    
    let tcContentDetected = false;
    let detectedContent = null;
    
    // Check if page contains T&C content
    function detectTcContent() {
        const bodyText = document.body.innerText.toLowerCase();
        const hasKeywords = TC_KEYWORDS.some(keyword => bodyText.includes(keyword));
        
        if (hasKeywords) {
            tcContentDetected = true;
            extractTcContent();
            showFloatingButton();
        }
    }
    
    // Extract T&C content from page
    function extractTcContent() {
        let content = '';
        
        // Try specific selectors first
        for (const selector of TC_SELECTORS) {
            const elements = document.querySelectorAll(selector);
            elements.forEach(el => {
                const text = el.innerText.trim();
                if (text.length > 100) {
                    content += text + '\n\n';
                }
            });
        }
        
        // Fallback to body text if no specific content found
        if (content.length < 200) {
            content = document.body.innerText;
        }
        
        detectedContent = content;
    }
    
    // Show floating LegalEase button
    function showFloatingButton() {
        // Check if button already exists
        if (document.getElementById('legalease-floating-btn')) return;
        
        const button = document.createElement('div');
        button.id = 'legalease-floating-btn';
        button.innerHTML = `
            <div style="
                position: fixed;
                bottom: 20px;
                right: 20px;
                z-index: 999999;
                background: #2563EB;
                color: white;
                padding: 12px 20px;
                border-radius: 24px;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 4px 12px rgba(37, 99, 235, 0.4);
                display: flex;
                align-items: center;
                gap: 8px;
                transition: transform 0.2s, box-shadow 0.2s;
            ">
                <span style="font-size: 18px;">🛡️</span>
                <span>Analyze with LegalEase</span>
            </div>
        `;
        
        button.addEventListener('click', () => {
            sendToLegalEase();
        });
        
        // Add hover effect
        button.querySelector('div').addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.05)';
            this.style.boxShadow = '0 6px 16px rgba(37, 99, 235, 0.5)';
        });
        
        button.querySelector('div').addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
            this.style.boxShadow = '0 4px 12px rgba(37, 99, 235, 0.4)';
        });
        
        document.body.appendChild(button);
    }
    
    // Send content to LegalEase app
    function sendToLegalEase() {
        if (!detectedContent) {
            detectTcContent();
        }
        
        // Store in localStorage for extension to access
        localStorage.setItem('legalease_content', detectedContent);
        localStorage.setItem('legalease_url', window.location.href);
        localStorage.setItem('legalease_title', document.title);
        
        // Notify background script
        browser.runtime.sendMessage({
            action: 'analyzeContent',
            content: detectedContent,
            url: window.location.href,
            title: document.title
        });
    }
    
    // Listen for messages from popup/background
    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        if (request.action === 'extractContent') {
            extractTcContent();
            sendResponse({
                success: true,
                content: detectedContent,
                url: window.location.href,
                title: document.title
            });
        } else if (request.action === 'checkTcContent') {
            sendResponse({
                hasTcContent: tcContentDetected,
                contentLength: detectedContent?.length || 0
            });
        }
        return true;
    });
    
    // Run detection on page load
    if (document.readyState === 'complete') {
        detectTcContent();
    } else {
        window.addEventListener('load', detectTcContent);
    }
})();
