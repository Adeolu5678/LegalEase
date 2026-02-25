import 'dart:io';
import 'package:flutter/services.dart';

enum KeyboardAction {
  analyze,
  translate,
  summarize,
  ask,
}

class KeyboardSharedData {
  final String text;
  final KeyboardAction action;
  final DateTime timestamp;
  
  KeyboardSharedData({
    required this.text,
    required this.action,
    required this.timestamp,
  });
  
  factory KeyboardSharedData.fromMap(Map<String, dynamic> map) {
    final timestampValue = map['timestamp'];
    DateTime parsedTimestamp;
    
    if (timestampValue is double) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch((timestampValue * 1000).toInt());
    } else if (timestampValue is int) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
    } else {
      parsedTimestamp = DateTime.now();
    }
    
    return KeyboardSharedData(
      text: map['text'] as String? ?? '',
      action: KeyboardAction.values.firstWhere(
        (e) => e.name == (map['action'] as String? ?? 'analyze'),
        orElse: () => KeyboardAction.analyze,
      ),
      timestamp: parsedTimestamp,
    );
  }
  
  Map<String, dynamic> toMap() => {
    'text': text,
    'action': action.name,
    'timestamp': timestamp.millisecondsSinceEpoch / 1000,
  };
}

class IosKeyboardService {
  static const MethodChannel _channel = MethodChannel('legalease_ios_keyboard');
  
  static final IosKeyboardService _instance = IosKeyboardService._internal();
  factory IosKeyboardService() => _instance;
  IosKeyboardService._internal();
  
  DateTime? _lastProcessedTimestamp;
  
  Future<bool> isPlatformSupported() async => Platform.isIOS;
  
  Future<bool> isKeyboardEnabled() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod('isKeyboardEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }
  
  Future<bool> hasFullAccessEnabled() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod('hasFullAccess') ?? false;
    } catch (_) {
      return false;
    }
  }
  
  Future<void> openKeyboardSettings() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('openKeyboardSettings');
    } catch (_) {}
  }
  
  Future<KeyboardSharedData?> getPendingSharedData() async {
    if (!Platform.isIOS) return null;
    
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getSharedData');
      if (result == null) return null;
      
      final data = KeyboardSharedData.fromMap(Map<String, dynamic>.from(result));
      
      if (_isAlreadyProcessed(data.timestamp)) {
        return null;
      }
      
      return data;
    } catch (_) {
      return null;
    }
  }
  
  void markAsProcessed(DateTime timestamp) {
    _lastProcessedTimestamp = timestamp;
  }
  
  bool _isAlreadyProcessed(DateTime timestamp) {
    if (_lastProcessedTimestamp == null) return false;
    return timestamp.isBefore(_lastProcessedTimestamp!) || 
           timestamp.isAtSameMomentAs(_lastProcessedTimestamp!);
  }
  
  Future<void> clearSharedData() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('clearSharedData');
    } catch (_) {}
  }
  
  String getActionDisplayName(KeyboardAction action) {
    switch (action) {
      case KeyboardAction.analyze:
        return 'Analyze for Red Flags';
      case KeyboardAction.translate:
        return 'Translate to Plain English';
      case KeyboardAction.summarize:
        return 'Summarize';
      case KeyboardAction.ask:
        return 'Ask Question';
    }
  }
  
  String getActionIcon(KeyboardAction action) {
    switch (action) {
      case KeyboardAction.analyze:
        return '🛡️';
      case KeyboardAction.translate:
        return '📝';
      case KeyboardAction.summarize:
        return '📄';
      case KeyboardAction.ask:
        return '❓';
    }
  }
  
  Future<KeyboardSetupStatus> checkKeyboardSetup() async {
    if (!Platform.isIOS) {
      return KeyboardSetupStatus.notApplicable;
    }
    
    final isEnabled = await isKeyboardEnabled();
    if (!isEnabled) {
      return KeyboardSetupStatus.notInstalled;
    }
    
    final hasFullAccess = await hasFullAccessEnabled();
    if (!hasFullAccess) {
      return KeyboardSetupStatus.needsFullAccess;
    }
    
    return KeyboardSetupStatus.ready;
  }
}

enum KeyboardSetupStatus {
  notApplicable,
  notInstalled,
  needsFullAccess,
  ready,
}
