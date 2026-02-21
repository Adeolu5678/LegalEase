SYSTEM PROMPT & PROJECT BRIEF
Role: Act as a Lead Product Manager, UX Researcher, and Technical Architect. Objective: Read the following project context for a new startup called "LegalEase". Based on this context, conduct comprehensive market research and generate all necessary product, technical, and business documents required to bring this application to life.
PART 1: PROJECT CONTEXT - "LegalEase"
1. Vision & Problem Statement
Everyday people and small business owners overpay for simple legal help because tools are fragmented and legal jargon (legalese) is intentionally difficult to understand. People often sign contracts they don't fully grasp, missing "red flags" buried in the text.
LegalEase is an all-in-one AI legal assistant designed to democratize legal comprehension. It moves beyond passive document scanning to become an active, real-time participant in the user's legal life—helping them review, draft, and negotiate with confidence.
2. Core Feature Set
A. Deep-Scan Document Analysis ("Scan & Summarize")
Functionality: Users upload digital files or snap photos of physical documents (Contracts, Leases).
Extraction: Uses OCR to extract text accurately.
Translation & Risk Flagging: The AI translates complex legalese into plain English. It specifically hunts for and highlights "Red Flags"—hidden details or manipulative clauses buried by the original author.
Contextual Q&A: A chat interface where users can ask the AI specific questions about the scanned document.
B. On-Screen T&C Auto-Scanner (No Screenshots Required)
Functionality: The app detects when a user is viewing a "Terms and Conditions," "Privacy Policy," or "EULA" in another app or browser. A floating button appears offering to summarize the text.
Extraction: The app uses OS Accessibility APIs to read the text directly from the screen's view hierarchy—no manual downloading or screenshotting is needed from the user.
C. Real-Time Legal Writing Assistant (The "Grammarly for Legal" Overlay)
Desktop/PC: An embedded background application that monitors active text fields. It highlights problematic phrasing in real-time and pops up to suggest legally sound corrections.
Mobile (Android Overlay): A floating UI pop-up that actively scans text the user is typing on their standard keyboard within any app (e.g., WhatsApp, Gmail). It highlights text and suggests rewrites to help users refine their negotiations.
iOS Fallback: A custom keyboard extension or Share Sheet integration for iOS (due to Apple's strict sandboxing preventing screen-reading overlays).
D. Personalized AI Counsel (Premium Subscription)
Custom Persona Engine: Premium users can define the exact "identity," tone, and language of their AI assistant (e.g., "Formal Corporate," "Polite but Firm," "Aggressive Negotiator").
Adaptive Output: The AI applies this specific persona when generating draft contracts, suggesting live text corrections via the overlay, or providing negotiation scripts.
3. Technical Stack & Constraints
Frontend Mobile/Web: Flutter (Cross-platform).
AI Engine: Google Gemini API (handles summarization, persona management, generation, and chat).
OCR: Google ML Kit (for physical document scans).
Crucial Technical Architecture for Overlays & Screen Reading: * Android: Cannot be done in pure Flutter. Requires writing native Android code (Kotlin/Java) utilizing the AccessibilityService API (to traverse AccessibilityNodeInfo and read screen/typing text) and SYSTEM_ALERT_WINDOW (Draw Over Other Apps permission) to render the pop-up UI.
iOS: Apple does not allow global Accessibility text scanning. The agent must account for a separate architectural approach for iOS, likely falling back to an iOS Custom Keyboard Extension and Safari Web Extensions.
PC/Desktop: Requires native OS Accessibility APIs (UI Automation on Windows, Accessibility API on macOS).
PART 2: INSTRUCTIONS FOR THE AGENT
Now that you have the context for LegalEase, please generate the following comprehensive documents. Present each as a distinct, highly detailed section:
Task 1: Comprehensive Market & Competitor Research
Analyze the current landscape of AI legal tools for consumers/SMBs.
Highlight the unique value proposition (UVP) of LegalEase (specifically focusing on the real-time Accessibility overlay, auto-screen reading, and custom personas).
Task 2: Phased Development Roadmap
Define what goes into Phase 1 (MVP) to validate the core idea quickly.
Define Phase 2 (The Android Accessibility Overlay and On-Screen T&C Auto-Scanner).
Define Phase 3 (Custom Personas & Premium Monetization).
Task 3: Detailed Technical Architecture & Feasibility Report
Provide a high-level architecture diagram/flow detailing how the Flutter app, native OS services, and the Gemini API interact.
Provide a highly specific technical deep-dive on the Real-Time Overlay and Screen Reading constraint. Explain exactly how the Android AccessibilityService will extract long, scrollable T&C text from other apps, send it to the Gemini API, and trigger the floating Flutter UI. Address the iOS limitations directly and propose the best user experience workaround.
Task 4: User Personas & User Journeys
Map out a step-by-step user journey for the "Auto-Scanning a T&C on a mobile browser" use case.
Task 5: Monetization & Pricing Strategy
Propose a freemium model structure.
Detail exactly which features are gated behind the premium subscription.
