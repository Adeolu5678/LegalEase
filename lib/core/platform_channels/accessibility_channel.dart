import 'dart:io';
import 'package:flutter/services.dart';
import 'ios_keyboard_channel.dart';
import 'windows_accessibility_channel.dart';
import 'macos_accessibility_channel.dart';

class NativeAccessibilityService {
  static const MethodChannel _androidChannel =
      MethodChannel('legalease_android_accessibility');
  static const EventChannel _textStreamChannel =
      EventChannel('legalease_text_stream');
  static const EventChannel _eventStreamChannel =
      EventChannel('legalease_event_stream');
  
  final IosKeyboardChannel _iosKeyboardChannel = IosKeyboardChannel();
  final WindowsAccessibilityChannel _windowsChannel = WindowsAccessibilityChannel();
  final MacosAccessibilityChannel _macosChannel = MacosAccessibilityChannel();

  Future<bool> enableAccessibilityService() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('enableAccessibility');
    }
    if (Platform.isIOS) {
      await _iosKeyboardChannel.openKeyboardSettings();
      return true;
    }
    if (Platform.isWindows) {
      return true;
    }
    if (Platform.isMacOS) {
      return await _macosChannel.requestAccessibilityPermission();
    }
    return false;
  }

  Future<bool> hasAccessibilityPermission() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('hasAccessibilityPermission');
    }
    if (Platform.isIOS) {
      return await _iosKeyboardChannel.isKeyboardEnabled();
    }
    if (Platform.isWindows) {
      return true;
    }
    if (Platform.isMacOS) {
      return await _macosChannel.isAccessibilityEnabled();
    }
    return false;
  }

  Future<String?> extractScreenText() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('extractScreenText');
    }
    if (Platform.isIOS) {
      return await _iosKeyboardChannel.getSharedText();
    }
    if (Platform.isWindows) {
      return await _windowsChannel.extractScreenText();
    }
    if (Platform.isMacOS) {
      return await _macosChannel.extractScreenText();
    }
    return null;
  }

  Future<void> showOverlay() async {
    if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('showOverlay');
    }
    if (Platform.isWindows) {
      await _windowsChannel.showOverlay();
    }
  }

  Future<void> hideOverlay() async {
    if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('hideOverlay');
    }
    if (Platform.isWindows) {
      await _windowsChannel.hideOverlay();
    }
  }

  Stream<String> get textStream =>
      _textStreamChannel.receiveBroadcastStream().map((event) => event as String);

  Stream<Map<String, dynamic>> get eventStream =>
      _eventStreamChannel.receiveBroadcastStream().map((event) => 
          Map<String, dynamic>.from(event as Map));
  
  Future<bool> isKeyboardEnabled() async {
    if (!Platform.isIOS) return false;
    return await _iosKeyboardChannel.isKeyboardEnabled();
  }
  
  Future<void> openKeyboardSettings() async {
    if (Platform.isIOS) {
      await _iosKeyboardChannel.openKeyboardSettings();
    }
  }
  
  Future<Map<String, dynamic>?> getKeyboardSharedData() async {
    if (!Platform.isIOS) return null;
    return await _iosKeyboardChannel.getSharedData();
  }

  Future<bool> hasOverlayPermission() async {
    if (Platform.isAndroid) {
      return await _androidChannel.invokeMethod('hasOverlayPermission');
    }
    if (Platform.isWindows) {
      return true;
    }
    if (Platform.isMacOS) {
      return await _macosChannel.isAccessibilityEnabled();
    }
    return false;
  }

  Future<void> requestOverlayPermission() async {
    if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('requestOverlayPermission');
    }
  }

  Future<void> openAccessibilitySettings() async {
    if (Platform.isAndroid) {
      await _androidChannel.invokeMethod('openAccessibilitySettings');
    }
  }

  Future<bool> startMonitoring() async {
    if (Platform.isWindows) {
      return await _windowsChannel.startMonitoring();
    }
    if (Platform.isMacOS) {
      return await _macosChannel.startMonitoring();
    }
    return false;
  }

  Future<void> stopMonitoring() async {
    if (Platform.isWindows) {
      await _windowsChannel.stopMonitoring();
    }
    if (Platform.isMacOS) {
      await _macosChannel.stopMonitoring();
    }
  }

  Future<String?> getForegroundWindowTitle() async {
    if (Platform.isWindows) {
      return await _windowsChannel.getForegroundWindowTitle();
    }
    if (Platform.isMacOS) {
      return await _macosChannel.getFocusedApplicationName();
    }
    return null;
  }

  Stream<Map<String, dynamic>> get windowChangeStream {
    if (Platform.isWindows) {
      return _windowsChannel.windowChangeStream;
    }
    if (Platform.isMacOS) {
      return _macosChannel.windowChangeStream;
    }
    return const Stream.empty();
  }

  Stream<Map<String, dynamic>> get tcContentStream {
    if (Platform.isWindows) {
      return _windowsChannel.tcContentStream;
    }
    if (Platform.isMacOS) {
      return _macosChannel.tcContentStream;
    }
    return const Stream.empty();
  }

  WindowsAccessibilityChannel get windowsChannel => _windowsChannel;
  MacosAccessibilityChannel get macosChannel => _macosChannel;
}