class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'LegalEase';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  // Feature Flags
  static const bool enableAccessibilityOverlay = true;
  static const bool enableDocumentScan = true;
  static const bool enableTcScanner = true;

  // Limits
  static const int maxDocumentSizeMB = 10;
  static const int maxChatHistoryMessages = 100;
  static const int ocrTimeoutSeconds = 30;

  // Animation Durations (milliseconds)
  static const int animationMicroMs = 100;
  static const int animationFastMs = 150;
  static const int animationNormalMs = 250;
  static const int animationMediumMs = 350;
  static const int animationSlowMs = 500;
  static const int animationVerySlowMs = 750;

  // Haptic Feedback Types
  static const bool enableHapticFeedback = true;

  // Onboarding
  static const String onboardingCompletedKey = 'onboarding_completed';
}
