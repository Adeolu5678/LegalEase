// LegalEase Safari Extension - Background Script
//
// Setup: This script handles communication between content scripts and the main app.
// It processes deep link URLs to open the LegalEase iOS app with content data.

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.action === 'analyzeContent') {
        // Open LegalEase app with content
        const content = encodeURIComponent(request.content.substring(0, 50000)); // Limit size
        const url = `legalease://analyze?url=${encodeURIComponent(request.url)}&title=${encodeURIComponent(request.title)}`;
        
        browser.tabs.update({ url: url });
        
        return Promise.resolve({ success: true });
    }
});

// Handle extension icon click
browser.action.onClicked.addListener((tab) => {
    browser.tabs.sendMessage(tab.id, { action: 'extractContent' }, (response) => {
        if (response && response.success) {
            const url = `legalease://analyze?url=${encodeURIComponent(response.url)}&title=${encodeURIComponent(response.title)}`;
            browser.tabs.update({ url: url });
        }
    });
});
