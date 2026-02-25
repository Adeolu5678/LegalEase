import 'dart:io';
import 'package:flutter/services.dart';

class MacosAccessibilityChannel {
  static const MethodChannel _channel = MethodChannel('legalease_macos_accessibility');
  static const EventChannel _eventChannel = EventChannel('legalease_macos_accessibility_events');
  
  static final MacosAccessibilityChannel _instance = MacosAccessibilityChannel._internal();
  factory MacosAccessibilityChannel() => _instance;
  MacosAccessibilityChannel._internal();
  
  Stream<Map<String, dynamic>>? _windowChangeStream;
  Stream<Map<String, dynamic>>? _tcContentStream;
  
  Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isMacOS) return false;
    try {
      return await _channel.invokeMethod('isAccessibilityEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> requestAccessibilityPermission() async {
    if (!Platform.isMacOS) return false;
    try {
      return await _channel.invokeMethod('requestAccessibilityPermission') ?? false;
    } on PlatformException catch (e) {
      print('Failed to request accessibility permission: ${e.message}');
      return false;
    }
  }
  
  Future<String?> extractScreenText() async {
    if (!Platform.isMacOS) return null;
    try {
      return await _channel.invokeMethod('extractScreenText');
    } on PlatformException catch (e) {
      print('Failed to extract screen text: ${e.message}');
      return null;
    }
  }
  
  Future<String?> getFocusedApplicationName() async {
    if (!Platform.isMacOS) return null;
    try {
      return await _channel.invokeMethod('getFocusedApplicationName');
    } on PlatformException catch (e) {
      print('Failed to get focused application name: ${e.message}');
      return null;
    }
  }
  
  Future<bool> startMonitoring() async {
    if (!Platform.isMacOS) return false;
    try {
      return await _channel.invokeMethod('startMonitoring') ?? false;
    } on PlatformException catch (e) {
      print('Failed to start monitoring: ${e.message}');
      return false;
    }
  }
  
  Future<void> stopMonitoring() async {
    if (!Platform.isMacOS) return;
    try {
      await _channel.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      print('Failed to stop monitoring: ${e.message}');
    }
  }
  
  Stream<Map<String, dynamic>> get windowChangeStream {
    if (!Platform.isMacOS) {
      return const Stream.empty();
    }
    _windowChangeStream ??= _eventChannel
        .receiveBroadcastStream('windowChange')
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _windowChangeStream!;
  }
  
  Stream<Map<String, dynamic>> get tcContentStream {
    if (!Platform.isMacOS) {
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
