// LegalEase Safari Extension - Popup Script
//
// Setup: This script handles popup UI interactions and communicates with content scripts.

document.addEventListener('DOMContentLoaded', async () => {
    const statusDot = document.getElementById('statusDot');
    const statusText = document.getElementById('statusText');
    const analyzeBtn = document.getElementById('analyzeBtn');
    
    // Check current tab for T&C content
    const [tab] = await browser.tabs.query({ active: true, currentWindow: true });
    
    try {
        const response = await browser.tabs.sendMessage(tab.id, { action: 'checkTcContent' });
        
        if (response.hasTcContent) {
            statusDot.classList.remove('warning');
            statusText.textContent = 'Legal content detected!';
        } else {
            statusDot.classList.add('warning');
            statusText.textContent = 'No legal content detected';
        }
    } catch (e) {
        statusDot.classList.add('warning');
        statusText.textContent = 'Unable to scan page';
    }
    
    // Analyze button
    analyzeBtn.addEventListener('click', async () => {
        const response = await browser.tabs.sendMessage(tab.id, { action: 'extractContent' });
        if (response && response.success) {
            const url = `legalease://analyze?url=${encodeURIComponent(response.url)}&title=${encodeURIComponent(response.title)}`;
            browser.tabs.update({ url: url });
        }
    });
    
    // Quick action buttons
    document.getElementById('redFlagsBtn').addEventListener('click', () => {
        sendAction('redflags');
    });
    
    document.getElementById('translateBtn').addEventListener('click', () => {
        sendAction('translate');
    });
    
    document.getElementById('summarizeBtn').addEventListener('click', () => {
        sendAction('summarize');
    });
    
    async function sendAction(action) {
        const response = await browser.tabs.sendMessage(tab.id, { action: 'extractContent' });
        if (response && response.success) {
            const url = `legalease://${action}?url=${encodeURIComponent(response.url)}`;
            browser.tabs.update({ url: url });
        }
    }
});
