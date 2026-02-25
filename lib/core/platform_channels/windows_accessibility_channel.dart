import 'dart:io';
import 'package:flutter/services.dart';

class WindowsAccessibilityChannel {
  static const MethodChannel _channel = MethodChannel('legalease_windows_accessibility');
  static const EventChannel _eventChannel = EventChannel('legalease_windows_accessibility_events');
  
  static final WindowsAccessibilityChannel _instance = WindowsAccessibilityChannel._internal();
  factory WindowsAccessibilityChannel() => _instance;
  WindowsAccessibilityChannel._internal();
  
  Stream<Map<String, dynamic>>? _windowChangeStream;
  Stream<Map<String, dynamic>>? _tcContentStream;
  
  Future<bool> isAvailable() async {
    if (!Platform.isWindows) return false;
    try {
      return await _channel.invokeMethod('isAvailable') ?? false;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> startMonitoring() async {
    if (!Platform.isWindows) return false;
    try {
      return await _channel.invokeMethod('startMonitoring') ?? false;
    } on PlatformException catch (e) {
      print('Failed to start monitoring: ${e.message}');
      return false;
    }
  }
  
  Future<void> stopMonitoring() async {
    if (!Platform.isWindows) return;
    try {
      await _channel.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      print('Failed to stop monitoring: ${e.message}');
    }
  }
  
  Future<String?> getForegroundWindowTitle() async {
    if (!Platform.isWindows) return null;
    try {
      return await _channel.invokeMethod('getForegroundWindowTitle');
    } on PlatformException {
      return null;
    }
  }
  
  Future<String?> extractScreenText() async {
    if (!Platform.isWindows) return null;
    try {
      return await _channel.invokeMethod('extractScreenText');
    } on PlatformException {
      return null;
    }
  }
  
  Future<bool> showOverlay({String? title, String? content}) async {
    if (!Platform.isWindows) return false;
    try {
      final args = <String, dynamic>{};
      if (title != null) args['title'] = title;
      if (content != null) args['content'] = content;
      return await _channel.invokeMethod('showOverlay', args) ?? false;
    } on PlatformException catch (e) {
      print('Failed to show overlay: ${e.message}');
      return false;
    }
  }
  
  Future<void> hideOverlay() async {
    if (!Platform.isWindows) return;
    try {
      await _channel.invokeMethod('hideOverlay');
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
    }
  }
  
  Stream<Map<String, dynamic>> get windowChangeStream {
    if (!Platform.isWindows) {
      return const Stream.empty();
    }
    _windowChangeStream ??= _eventChannel
        .receiveBroadcastStream('windowChange')
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _windowChangeStream!;
  }
  
  Stream<Map<String, dynamic>> get tcContentStream {
    if (!Platform.isWindows) {
      return const Stream.empty();
    }
    _tcContentStream ??= _eventChannel
        .receiveBroadcastStream('tcContent')
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _tcContentStream!;
  }
  
  Future<void> dispose() async {
    await stopMonitoring();
    _windowChangeStream = null;
    _tcContentStream = null;
  }
}