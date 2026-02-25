import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:legalease/core/platform_channels/accessibility_channel.dart';

class TcDetectorService {
  final NativeAccessibilityService _accessibilityService;
  StreamSubscription? _textStreamSubscription;
  StreamSubscription? _eventStreamSubscription;
  StreamSubscription? _windowChangeSubscription;
  StreamSubscription? _tcContentSubscription;

  final List<String> tcKeywords = [
    'terms and conditions',
    'terms of service',
    'terms of use',
    'privacy policy',
    'eula',
    'end user license agreement',
    'user agreement',
    'legal notice',
    'cookie policy',
    'data protection',
    'disclaimer',
  ];

  String? _lastDetectedContent;
  DateTime? _lastDetectionTime;
  static const _detectionCooldown = Duration(seconds: 5);

  TcDetectorService(this._accessibilityService);

  Future<void> startMonitoring() async {
    if (Platform.isAndroid) {
      _textStreamSubscription = _accessibilityService.textStream.listen(
        _onScreenTextChanged,
        onError: (error) => debugPrint('Text stream error: $error'),
      );

      _eventStreamSubscription = _accessibilityService.eventStream.listen(
        _onAccessibilityEvent,
        onError: (error) => debugPrint('Event stream error: $error'),
      );
    }

    if (Platform.isWindows || Platform.isMacOS) {
      await _accessibilityService.startMonitoring();

      _windowChangeSubscription = _accessibilityService.windowChangeStream.listen(
        _onWindowChange,
        onError: (error) => debugPrint('Window change stream error: $error'),
      );

      _tcContentSubscription = _accessibilityService.tcContentStream.listen(
        _onWindowsTcContent,
        onError: (error) => debugPrint('TC content stream error: $error'),
      );
    }
  }

  void _onScreenTextChanged(String text) {
    if (_containsTcContent(text)) {
      _onTcDetected(text, null, null);
    }
  }

  void _onAccessibilityEvent(Map<String, dynamic> event) {
    if (event['type'] == 'tc_detected') {
      final data = event['data'] as Map<String, dynamic>;
      final text = data['text'] as String?;
      final packageName = data['packageName'] as String?;

      if (text != null && _shouldNotify(text)) {
        _lastDetectedContent = text;
        _lastDetectionTime = DateTime.now();
        _tcDetectedController.add(TcDetectionResult(
          content: text,
          sourcePackage: packageName,
          detectedAt: DateTime.now(),
        ));
      }
    }
  }

  void _onWindowChange(Map<String, dynamic> event) async {
    final windowTitle = event['windowTitle'] as String?;

    final screenText = await _accessibilityService.extractScreenText();
    if (screenText != null && _containsTcContent(screenText)) {
      _onTcDetected(screenText, null, windowTitle);
    } else if (windowTitle != null && _containsTcContent(windowTitle)) {
      _onTcDetected(windowTitle, null, windowTitle);
    }
  }

  void _onWindowsTcContent(Map<String, dynamic> event) {
    final text = event['text'] as String?;
    final windowTitle = event['windowTitle'] as String?;
    final processName = event['processName'] as String?;

    if (text != null && _shouldNotify(text)) {
      _lastDetectedContent = text;
      _lastDetectionTime = DateTime.now();
      _tcDetectedController.add(TcDetectionResult(
        content: text,
        sourcePackage: processName,
        detectedAt: DateTime.now(),
        windowTitle: windowTitle,
      ));
    }
  }

  bool _shouldNotify(String text) {
    if (_lastDetectionTime == null) return true;
    if (DateTime.now().difference(_lastDetectionTime!) < _detectionCooldown) {
      return false;
    }
    return text != _lastDetectedContent;
  }

  bool _containsTcContent(String text) {
    final lowerText = text.toLowerCase();
    return tcKeywords.any((keyword) => lowerText.contains(keyword));
  }

  void _onTcDetected(String text, String? packageName, String? windowTitle) {
    if (!_shouldNotify(text)) return;

    _lastDetectedContent = text;
    _lastDetectionTime = DateTime.now();
    _tcDetectedController.add(TcDetectionResult(
      content: text,
      sourcePackage: packageName,
      detectedAt: DateTime.now(),
      windowTitle: windowTitle,
    ));
  }

  final _tcDetectedController = StreamController<TcDetectionResult>.broadcast();
  Stream<TcDetectionResult> get onTcDetected => _tcDetectedController.stream;

  Future<void> stopMonitoring() async {
    await _textStreamSubscription?.cancel();
    await _eventStreamSubscription?.cancel();
    await _windowChangeSubscription?.cancel();
    await _tcContentSubscription?.cancel();
    _textStreamSubscription = null;
    _eventStreamSubscription = null;
    _windowChangeSubscription = null;
    _tcContentSubscription = null;

    if (Platform.isWindows || Platform.isMacOS) {
      await _accessibilityService.stopMonitoring();
    }
  }

  Future<void> showOverlay() async {
    await _accessibilityService.showOverlay();
  }

  Future<void> hideOverlay() async {
    await _accessibilityService.hideOverlay();
  }

  Future<bool> hasAccessibilityPermission() async {
    return await _accessibilityService.hasAccessibilityPermission();
  }

  Future<bool> hasOverlayPermission() async {
    return await _accessibilityService.hasOverlayPermission();
  }

  void dispose() {
    stopMonitoring();
    _tcDetectedController.close();
  }
}

class TcDetectionResult {
  final String content;
  final String? sourcePackage;
  final DateTime detectedAt;
  final String? windowTitle;

  const TcDetectionResult({
    required this.content,
    this.sourcePackage,
    required this.detectedAt,
    this.windowTitle,
  });
}
