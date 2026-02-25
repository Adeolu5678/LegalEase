import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';

/// DeepLinkHandler - Handles incoming deep links from Safari Extension
///
/// Setup Instructions:
/// 1. Add uni_links package to pubspec.yaml
/// 2. Add URL scheme to iOS Info.plist:
///    <key>CFBundleURLTypes</key>
///    <array>
///      <dict>
///        <key>CFBundleURLSchemes</key>
///        <array>
///          <string>legalease</string>
///        </array>
///      </dict>
///    </array>
/// 3. Call DeepLinkHandler.init() in main.dart before runApp()
/// 4. Handle the content using the received URL parameters

class DeepLinkHandler {
  static StreamSubscription<Uri?>? _linkSubscription;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void init() {
    _linkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;
      _handleDeepLink(uri);
    });
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }

  static void _handleDeepLink(Uri uri) {
    final path = uri.path;
    final params = uri.queryParameters;
    
    switch (path) {
      case '/analyze':
        _handleAnalyze(params);
        break;
      case '/translate':
        _handleTranslate(params);
        break;
      case '/summarize':
        _handleSummarize(params);
        break;
      case '/redflags':
        _handleRedFlags(params);
        break;
      default:
        debugPrint('Unknown deep link path: $path');
    }
  }

  static void _handleAnalyze(Map<String, String> params) {
    final url = params['url'] ?? '';
    final title = params['title'] ?? '';
    
    // Navigate to document analysis screen with shared content
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push('/document/analyze', extra: {
        'sourceUrl': url,
        'title': title,
        'source': 'safari_extension',
      });
    }
  }

  static void _handleTranslate(Map<String, String> params) {
    final url = params['url'] ?? '';
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push('/document/translate', extra: {
        'sourceUrl': url,
        'mode': 'plain_english',
        'source': 'safari_extension',
      });
    }
  }

  static void _handleSummarize(Map<String, String> params) {
    final url = params['url'] ?? '';
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push('/document/summarize', extra: {
        'sourceUrl': url,
        'source': 'safari_extension',
      });
    }
  }

  static void _handleRedFlags(Map<String, String> params) {
    final url = params['url'] ?? '';
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.push('/document/red-flags', extra: {
        'sourceUrl': url,
        'source': 'safari_extension',
      });
    }
  }
}
