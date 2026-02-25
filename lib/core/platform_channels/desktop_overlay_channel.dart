import 'dart:io';
import 'package:flutter/services.dart';

class DesktopOverlayChannel {
  static const MethodChannel _methodChannel = MethodChannel('legalease_desktop_overlay');
  static const EventChannel _eventChannel = EventChannel('legalease_desktop_overlay_events');
  
  static final DesktopOverlayChannel _instance = DesktopOverlayChannel._internal();
  factory DesktopOverlayChannel() => _instance;
  DesktopOverlayChannel._internal();
  
  Stream<Map<String, dynamic>>? _selectionEventStream;
  Stream<Map<String, dynamic>>? _clipboardEventStream;

  Future<bool> showOverlay() async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('showOverlay') ?? false;
    } on PlatformException catch (e) {
      print('Failed to show overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> hideOverlay() async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('hideOverlay') ?? false;
    } on PlatformException catch (e) {
      print('Failed to hide overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> setPosition(double x, double y) async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('setPosition', {
        'x': x,
        'y': y,
      }) ?? false;
    } on PlatformException catch (e) {
      print('Failed to set overlay position: ${e.message}');
      return false;
    }
  }

  Future<bool> setSize(double width, double height) async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('setSize', {
        'width': width,
        'height': height,
      }) ?? false;
    } on PlatformException catch (e) {
      print('Failed to set overlay size: ${e.message}');
      return false;
    }
  }

  Future<bool> setAlwaysOnTop(bool alwaysOnTop) async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('setAlwaysOnTop', {
        'alwaysOnTop': alwaysOnTop,
      }) ?? false;
    } on PlatformException catch (e) {
      print('Failed to set always on top: ${e.message}');
      return false;
    }
  }

  Future<bool> minimize() async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('minimize') ?? false;
    } on PlatformException catch (e) {
      print('Failed to minimize overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> expand() async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('expand') ?? false;
    } on PlatformException catch (e) {
      print('Failed to expand overlay: ${e.message}');
      return false;
    }
  }

  Future<bool> isOverlayVisible() async {
    if (!Platform.isWindows && !Platform.isMacOS) return false;
    try {
      return await _methodChannel.invokeMethod('isOverlayVisible') ?? false;
    } on PlatformException catch (e) {
      print('Failed to check overlay visibility: ${e.message}');
      return false;
    }
  }

  Future<void> updateContent(String text) async {
    if (!Platform.isWindows && !Platform.isMacOS) return;
    try {
      await _methodChannel.invokeMethod('updateContent', {
        'text': text,
      });
    } on PlatformException catch (e) {
      print('Failed to update overlay content: ${e.message}');
    }
  }

  Future<Map<String, double>?> getPosition() async {
    if (!Platform.isWindows && !Platform.isMacOS) return null;
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getPosition');
      if (result != null) {
        return {
          'x': (result['x'] as num).toDouble(),
          'y': (result['y'] as num).toDouble(),
        };
      }
      return null;
    } on PlatformException catch (e) {
      print('Failed to get overlay position: ${e.message}');
      return null;
    }
  }

  Future<Map<String, double>?> getSize() async {
    if (!Platform.isWindows && !Platform.isMacOS) return null;
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getSize');
      if (result != null) {
        return {
          'width': (result['width'] as num).toDouble(),
          'height': (result['height'] as num).toDouble(),
        };
      }
      return null;
    } on PlatformException catch (e) {
      print('Failed to get overlay size: ${e.message}');
      return null;
    }
  }

  Stream<Map<String, dynamic>> get selectionEventStream {
    if (!Platform.isWindows && !Platform.isMacOS) {
      return const Stream.empty();
    }
    _selectionEventStream ??= _eventChannel
        .receiveBroadcastStream('selectionEvent')
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _selectionEventStream!;
  }

  Stream<Map<String, dynamic>> get clipboardEventStream {
    if (!Platform.isWindows && !Platform.isMacOS) {
      return const Stream.empty();
    }
    _clipboardEventStream ??= _eventChannel
        .receiveBroadcastStream('clipboardEvent')
        .map((event) => Map<String, dynamic>.from(event as Map));
    return _clipboardEventStream!;
  }

  Future<void> dispose() async {
    _selectionEventStream = null;
    _clipboardEventStream = null;
  }
}
