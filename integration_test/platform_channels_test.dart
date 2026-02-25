import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:legalease/core/platform_channels/accessibility_channel.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late NativeAccessibilityService service;
  
  const androidChannel = MethodChannel('legalease_android_accessibility');
  const iosChannel = MethodChannel('legalease_ios_keyboard');
  const windowsChannel = MethodChannel('legalease_windows_accessibility');
  const macosChannel = MethodChannel('legalease_macos_accessibility');
  const textStreamChannel = EventChannel('legalease_text_stream');
  const eventStreamChannel = EventChannel('legalease_event_stream');
  const windowsEventChannel = EventChannel('legalease_windows_accessibility_events');
  const macosEventChannel = EventChannel('legalease_macos_accessibility_events');

  setUp(() {
    service = NativeAccessibilityService();
  });

  group('Android Platform Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, _androidHandler);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, null);
    });

    testWidgets('enableAccessibilityService calls correct method', (tester) async {
      if (!Platform.isAndroid) return;
      
      final result = await service.enableAccessibilityService();
      expect(result, isTrue);
    });

    testWidgets('hasAccessibilityPermission returns bool', (tester) async {
      if (!Platform.isAndroid) return;
      
      final result = await service.hasAccessibilityPermission();
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    testWidgets('extractScreenText returns text', (tester) async {
      if (!Platform.isAndroid) return;
      
      final result = await service.extractScreenText();
      expect(result, isA<String?>());
      expect(result, equals('Sample extracted text'));
    });

    testWidgets('showOverlay calls correct method', (tester) async {
      if (!Platform.isAndroid) return;
      
      await service.showOverlay();
    });

    testWidgets('hideOverlay calls correct method', (tester) async {
      if (!Platform.isAndroid) return;
      
      await service.hideOverlay();
    });

    testWidgets('hasOverlayPermission returns bool', (tester) async {
      if (!Platform.isAndroid) return;
      
      final result = await service.hasOverlayPermission();
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    testWidgets('requestOverlayPermission is called', (tester) async {
      if (!Platform.isAndroid) return;
      
      await service.requestOverlayPermission();
    });

    testWidgets('openAccessibilitySettings is called', (tester) async {
      if (!Platform.isAndroid) return;
      
      await service.openAccessibilitySettings();
    });
  });

  group('iOS Platform Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, _iosHandler);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, null);
    });

    testWidgets('isKeyboardEnabled returns bool', (tester) async {
      if (!Platform.isIOS) return;
      
      final result = await service.isKeyboardEnabled();
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    testWidgets('openKeyboardSettings is called', (tester) async {
      if (!Platform.isIOS) return;
      
      await service.openKeyboardSettings();
    });

    testWidgets('getKeyboardSharedData returns map', (tester) async {
      if (!Platform.isIOS) return;
      
      final result = await service.getKeyboardSharedData();
      expect(result, isA<Map<String, dynamic>?>());
      expect(result?['text'], equals('Shared keyboard text'));
      expect(result?['timestamp'], equals(1234567890));
    });
  });

  group('Windows Platform Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, _windowsHandler);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('startMonitoring returns bool', (tester) async {
      if (!Platform.isWindows) return;
      
      final result = await service.startMonitoring();
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    testWidgets('stopMonitoring is called', (tester) async {
      if (!Platform.isWindows) return;
      
      await service.stopMonitoring();
    });

    testWidgets('getForegroundWindowTitle returns string', (tester) async {
      if (!Platform.isWindows) return;
      
      final result = await service.getForegroundWindowTitle();
      expect(result, isA<String?>());
      expect(result, equals('Test Window Title'));
    });
  });

  group('macOS Platform Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, _macosHandler);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });

    testWidgets('startMonitoring returns bool', (tester) async {
      if (!Platform.isMacOS) return;
      
      final result = await service.startMonitoring();
      expect(result, isA<bool>());
      expect(result, isTrue);
    });

    testWidgets('stopMonitoring is called', (tester) async {
      if (!Platform.isMacOS) return;
      
      await service.stopMonitoring();
    });

    testWidgets('getForegroundWindowTitle returns string', (tester) async {
      if (!Platform.isMacOS) return;
      
      final result = await service.getForegroundWindowTitle();
      expect(result, isA<String?>());
      expect(result, equals('Test App Name'));
    });
  });

  group('Stream Tests', () {
    late StreamController<String> textStreamController;
    late StreamController<Map<String, dynamic>> eventStreamController;

    setUp(() {
      textStreamController = StreamController<String>.broadcast();
      eventStreamController = StreamController<Map<String, dynamic>>.broadcast();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(textStreamChannel.name, (message) async {
        final methodCall = const StandardMethodCodec().decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          textStreamController.add('Test text stream event');
        }
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(eventStreamChannel.name, (message) async {
        final methodCall = const StandardMethodCodec().decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          eventStreamController.add({'type': 'test', 'data': 'event data'});
        }
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(textStreamChannel.name, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(eventStreamChannel.name, null);
      textStreamController.close();
      eventStreamController.close();
    });

    testWidgets('textStream receives broadcast events', (tester) async {
      final completer = Completer<String>();
      final subscription = service.textStream.listen(
        completer.complete,
        onError: completer.completeError,
      );

      await tester.pumpAndSettle();

      subscription.cancel();
    });

    testWidgets('eventStream receives and parses events', (tester) async {
      final completer = Completer<Map<String, dynamic>>();
      final subscription = service.eventStream.listen(
        completer.complete,
        onError: completer.completeError,
      );

      await tester.pumpAndSettle();

      subscription.cancel();
    });
  });

  group('Window/macOS Change Stream Tests', () {
    testWidgets('windowChangeStream emits events on Windows', (tester) async {
      if (!Platform.isWindows) return;

      final controller = StreamController<Map<String, dynamic>>.broadcast();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(windowsEventChannel.name, (message) async {
        final methodCall = const StandardMethodCodec().decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          controller.add({'window': 'New Window', 'pid': 1234});
        }
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });

      final subscription = service.windowChangeStream.listen((_) {});
      await tester.pumpAndSettle();
      
      await subscription.cancel();
      await controller.close();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(windowsEventChannel.name, null);
    });

    testWidgets('tcContentStream emits events on macOS', (tester) async {
      if (!Platform.isMacOS) return;

      final controller = StreamController<Map<String, dynamic>>.broadcast();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(macosEventChannel.name, (message) async {
        final methodCall = const StandardMethodCodec().decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          controller.add({'content': 'TC content', 'url': 'https://example.com'});
        }
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });

      final subscription = service.tcContentStream.listen((_) {});
      await tester.pumpAndSettle();
      
      await subscription.cancel();
      await controller.close();
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(macosEventChannel.name, null);
    });
  });

  group('Error Handling Tests', () {
    testWidgets('Android method call throws PlatformException', (tester) async {
      if (!Platform.isAndroid) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, (call) async {
        throw PlatformException(
          code: 'ERROR',
          message: 'Test error',
          details: null,
        );
      });

      expect(
        () => service.extractScreenText(),
        throwsA(isA<PlatformException>()),
      );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, null);
    });

    testWidgets('iOS method call throws PlatformException', (tester) async {
      if (!Platform.isIOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, (call) async {
        throw PlatformException(
          code: 'ERROR',
          message: 'iOS error',
          details: null,
        );
      });

      final result = await service.isKeyboardEnabled();
      expect(result, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, null);
    });

    testWidgets('Windows method call throws PlatformException', (tester) async {
      if (!Platform.isWindows) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, (call) async {
        throw PlatformException(
          code: 'ERROR',
          message: 'Windows error',
          details: null,
        );
      });

      final result = await service.startMonitoring();
      expect(result, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('macOS method call throws PlatformException', (tester) async {
      if (!Platform.isMacOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, (call) async {
        throw PlatformException(
          code: 'ERROR',
          message: 'macOS error',
          details: null,
        );
      });

      final result = await service.startMonitoring();
      expect(result, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });

    testWidgets('returns null for unsupported platform', (tester) async {
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
        return;
      }

      final result = await service.extractScreenText();
      expect(result, isNull);
    });

    testWidgets('returns false for hasAccessibilityPermission on unsupported platform', (tester) async {
      if (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isMacOS) {
        return;
      }

      final result = await service.hasAccessibilityPermission();
      expect(result, isFalse);
    });

    testWidgets('empty stream for windowChangeStream on unsupported platform', (tester) async {
      if (Platform.isWindows || Platform.isMacOS) return;

      final stream = service.windowChangeStream;
      expect(stream, emitsDone);
    });

    testWidgets('empty stream for tcContentStream on unsupported platform', (tester) async {
      if (Platform.isWindows || Platform.isMacOS) return;

      final stream = service.tcContentStream;
      expect(stream, emitsDone);
    });
  });

  group('Method Channel Call Verification Tests', () {
    testWidgets('Android channel methods are invoked with correct names', (tester) async {
      if (!Platform.isAndroid) return;

      final calledMethods = <String>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, (call) async {
        calledMethods.add(call.method);
        return _getAndroidReturnValue(call.method);
      });

      await service.enableAccessibilityService();
      await service.hasAccessibilityPermission();
      await service.extractScreenText();
      await service.showOverlay();
      await service.hideOverlay();
      await service.hasOverlayPermission();
      await service.requestOverlayPermission();
      await service.openAccessibilitySettings();

      expect(calledMethods, containsAll([
        'enableAccessibility',
        'hasAccessibilityPermission',
        'extractScreenText',
        'showOverlay',
        'hideOverlay',
        'hasOverlayPermission',
        'requestOverlayPermission',
        'openAccessibilitySettings',
      ]));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, null);
    });

    testWidgets('iOS channel methods are invoked with correct names', (tester) async {
      if (!Platform.isIOS) return;

      final calledMethods = <String>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, (call) async {
        calledMethods.add(call.method);
        return _getIosReturnValue(call.method);
      });

      await service.isKeyboardEnabled();
      await service.openKeyboardSettings();
      await service.getKeyboardSharedData();

      expect(calledMethods, containsAll([
        'isKeyboardEnabled',
        'openKeyboardSettings',
        'getSharedData',
      ]));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, null);
    });

    testWidgets('Windows channel methods are invoked with correct names', (tester) async {
      if (!Platform.isWindows) return;

      final calledMethods = <String>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, (call) async {
        calledMethods.add(call.method);
        return _getWindowsReturnValue(call.method);
      });

      await service.startMonitoring();
      await service.getForegroundWindowTitle();
      await service.stopMonitoring();

      expect(calledMethods, containsAll([
        'startMonitoring',
        'getForegroundWindowTitle',
        'stopMonitoring',
      ]));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('macOS channel methods are invoked with correct names', (tester) async {
      if (!Platform.isMacOS) return;

      final calledMethods = <String>[];
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, (call) async {
        calledMethods.add(call.method);
        return _getMacosReturnValue(call.method);
      });

      await service.startMonitoring();
      await service.getForegroundWindowTitle();
      await service.stopMonitoring();

      expect(calledMethods, containsAll([
        'startMonitoring',
        'getFocusedApplicationName',
        'stopMonitoring',
      ]));

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });
  });

  group('Return Value Type Tests', () {
    testWidgets('Android returns correct types', (tester) async {
      if (!Platform.isAndroid) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, _androidHandler);

      final permissionResult = await service.hasAccessibilityPermission();
      expect(permissionResult, isA<bool>());

      final textResult = await service.extractScreenText();
      expect(textResult, isA<String?>());

      final overlayResult = await service.hasOverlayPermission();
      expect(overlayResult, isA<bool>());

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, null);
    });

    testWidgets('iOS returns correct types', (tester) async {
      if (!Platform.isIOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, _iosHandler);

      final keyboardResult = await service.isKeyboardEnabled();
      expect(keyboardResult, isA<bool>());

      final sharedDataResult = await service.getKeyboardSharedData();
      expect(sharedDataResult, isA<Map<String, dynamic>?>());

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, null);
    });

    testWidgets('Windows returns correct types', (tester) async {
      if (!Platform.isWindows) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, _windowsHandler);

      final monitorResult = await service.startMonitoring();
      expect(monitorResult, isA<bool>());

      final windowResult = await service.getForegroundWindowTitle();
      expect(windowResult, isA<String?>());

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('macOS returns correct types', (tester) async {
      if (!Platform.isMacOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, _macosHandler);

      final monitorResult = await service.startMonitoring();
      expect(monitorResult, isA<bool>());

      final windowResult = await service.getForegroundWindowTitle();
      expect(windowResult, isA<String?>());

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });
  });

  group('Edge Case Tests', () {
    testWidgets('Android returns null for extractScreenText', (tester) async {
      if (!Platform.isAndroid) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, (call) async {
        if (call.method == 'extractScreenText') return null;
        return _getAndroidReturnValue(call.method);
      });

      final result = await service.extractScreenText();
      expect(result, isNull);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(androidChannel, null);
    });

    testWidgets('iOS returns null for getKeyboardSharedData', (tester) async {
      if (!Platform.isIOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, (call) async {
        if (call.method == 'getSharedData') return null;
        return _getIosReturnValue(call.method);
      });

      final result = await service.getKeyboardSharedData();
      expect(result, isNull);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(iosChannel, null);
    });

    testWidgets('Windows returns null for getForegroundWindowTitle', (tester) async {
      if (!Platform.isWindows) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, (call) async {
        if (call.method == 'getForegroundWindowTitle') return null;
        return _getWindowsReturnValue(call.method);
      });

      final result = await service.getForegroundWindowTitle();
      expect(result, isNull);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('macOS returns null for getForegroundWindowTitle', (tester) async {
      if (!Platform.isMacOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, (call) async {
        if (call.method == 'getFocusedApplicationName') return null;
        return _getMacosReturnValue(call.method);
      });

      final result = await service.getForegroundWindowTitle();
      expect(result, isNull);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });

    testWidgets('Windows returns false for startMonitoring failure', (tester) async {
      if (!Platform.isWindows) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, (call) async {
        if (call.method == 'startMonitoring') return false;
        return _getWindowsReturnValue(call.method);
      });

      final result = await service.startMonitoring();
      expect(result, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(windowsChannel, null);
    });

    testWidgets('macOS returns false for startMonitoring failure', (tester) async {
      if (!Platform.isMacOS) return;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, (call) async {
        if (call.method == 'startMonitoring') return false;
        return _getMacosReturnValue(call.method);
      });

      final result = await service.startMonitoring();
      expect(result, isFalse);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(macosChannel, null);
    });
  });
}

Future<dynamic> _androidHandler(MethodCall call) async {
  return _getAndroidReturnValue(call.method);
}

dynamic _getAndroidReturnValue(String method) {
  switch (method) {
    case 'enableAccessibility':
      return true;
    case 'hasAccessibilityPermission':
      return true;
    case 'extractScreenText':
      return 'Sample extracted text';
    case 'showOverlay':
      return null;
    case 'hideOverlay':
      return null;
    case 'hasOverlayPermission':
      return true;
    case 'requestOverlayPermission':
      return null;
    case 'openAccessibilitySettings':
      return null;
    default:
      return null;
  }
}

Future<dynamic> _iosHandler(MethodCall call) async {
  return _getIosReturnValue(call.method);
}

dynamic _getIosReturnValue(String method) {
  switch (method) {
    case 'isKeyboardEnabled':
      return true;
    case 'openKeyboardSettings':
      return null;
    case 'getSharedText':
      return 'Shared text content';
    case 'getSharedData':
      return {'text': 'Shared keyboard text', 'timestamp': 1234567890};
    case 'hasFullAccess':
      return true;
    case 'requestFullAccess':
      return null;
    case 'clearSharedData':
      return null;
    default:
      return null;
  }
}

Future<dynamic> _windowsHandler(MethodCall call) async {
  return _getWindowsReturnValue(call.method);
}

dynamic _getWindowsReturnValue(String method) {
  switch (method) {
    case 'isAvailable':
      return true;
    case 'startMonitoring':
      return true;
    case 'stopMonitoring':
      return null;
    case 'getForegroundWindowTitle':
      return 'Test Window Title';
    case 'extractScreenText':
      return 'Windows screen text';
    case 'showOverlay':
      return true;
    case 'hideOverlay':
      return null;
    default:
      return null;
  }
}

Future<dynamic> _macosHandler(MethodCall call) async {
  return _getMacosReturnValue(call.method);
}

dynamic _getMacosReturnValue(String method) {
  switch (method) {
    case 'isAccessibilityEnabled':
      return true;
    case 'requestAccessibilityPermission':
      return true;
    case 'extractScreenText':
      return 'macOS screen text';
    case 'getFocusedApplicationName':
      return 'Test App Name';
    case 'startMonitoring':
      return true;
    case 'stopMonitoring':
      return null;
    default:
      return null;
  }
}
