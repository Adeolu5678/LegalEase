import 'dart:io';
import 'package:flutter/services.dart';

class IosKeyboardChannel {
  static const MethodChannel _channel = MethodChannel('legalease_ios_keyboard');
  
  static final IosKeyboardChannel _instance = IosKeyboardChannel._internal();
  factory IosKeyboardChannel() => _instance;
  IosKeyboardChannel._internal();
  
  Future<bool> isKeyboardEnabled() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod('isKeyboardEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }
  
  Future<void> openKeyboardSettings() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('openKeyboardSettings');
    } on PlatformException catch (e) {
      print('Failed to open keyboard settings: ${e.message}');
    }
  }
  
  Future<String?> getSharedText() async {
    if (!Platform.isIOS) return null;
    try {
      return await _channel.invokeMethod('getSharedText');
    } on PlatformException {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> getSharedData() async {
    if (!Platform.isIOS) return null;
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getSharedData');
      if (result == null) return null;
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return null;
    }
  }
  
  Future<void> clearSharedData() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('clearSharedData');
    } on PlatformException catch (e) {
      print('Failed to clear shared data: ${e.message}');
    }
  }
  
  Future<bool> hasFullAccessEnabled() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod('hasFullAccess') ?? false;
    } on PlatformException {
      return false;
    }
  }
  
  Future<bool> requestFullAccess() async {
    if (!Platform.isIOS) return false;
    try {
      await _channel.invokeMethod('requestFullAccess');
      return true;
    } on PlatformException {
      return false;
    }
  }
}
