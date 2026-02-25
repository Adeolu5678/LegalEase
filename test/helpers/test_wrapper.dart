import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestWrapper extends StatelessWidget {
  const TestWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
    this.theme,
    this.navigatorObservers,
    this.locale,
    this.localizationsDelegates,
    this.routes,
    this.initialRoute,
  });

  final Widget child;
  final List<Override> overrides;
  final ThemeData? theme;
  final List<NavigatorObserver>? navigatorObservers;
  final Locale? locale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme ?? ThemeData.light(),
        navigatorObservers: navigatorObservers ?? [],
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        routes: routes ?? const {},
        initialRoute: initialRoute,
        home: Scaffold(body: child),
      ),
    );
  }
}

Future<WidgetTester> pumpTestWidget(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  ThemeData? theme,
  List<NavigatorObserver>? navigatorObservers,
  Duration? duration,
}) async {
  await tester.pumpWidget(
    TestWrapper(
      overrides: overrides,
      theme: theme,
      navigatorObservers: navigatorObservers,
      child: widget,
    ),
  );

  if (duration != null) {
    await tester.pump(duration);
  }

  return tester;
}

Future<WidgetTester> pumpTestWidgetWithAnimation(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
  ThemeData? theme,
  List<NavigatorObserver>? navigatorObservers,
  Duration animationDuration = const Duration(seconds: 1),
}) async {
  await tester.pumpWidget(
    TestWrapper(
      overrides: overrides,
      theme: theme,
      navigatorObservers: navigatorObservers,
      child: widget,
    ),
  );

  await tester.pumpAndSettle(animationDuration);

  return tester;
}

class TestProviders {
  static List<Override> mockAiProviders({
    AiService? aiService,
    AiConfig? aiConfig,
  }) {
    final overrides = <Override>[];

    if (aiConfig != null) {
      overrides.add(
        aiConfigProvider.overrideWith((ref) => aiConfig),
      );
    }

    return overrides;
  }

  static List<Override> mockSubscriptionProviders({
    bool isPremium = false,
  }) {
    return [
      isPremiumProvider.overrideWith((ref) => isPremium),
    ];
  }

  static List<Override> mockAuthProviders({
    User? user,
    bool isAuthenticated = false,
  }) {
    return [
      authStateProvider.overrideWith((ref) => AuthState(
        user: user,
        isAuthenticated: isAuthenticated,
      )),
    ];
  }

  static List<Override> mockDocumentProviders({
    List<Document>? documents,
  }) {
    return [
      documentsProvider.overrideWith((ref) => documents ?? []),
    ];
  }
}

final isPremiumProvider = StateProvider<bool>((ref) => false);

final authStateProvider = StateProvider<AuthState>((ref) => const AuthState());

final documentsProvider = StateProvider<List<Document>>((ref) => []);

class AuthState {
  final User? user;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
  });
}

class User {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });
}

class Document {
  final String id;
  final String title;

  const Document({
    required this.id,
    required this.title,
  });
}

class AiService {
  final AiConfig config;

  AiService({required this.config});
}

class AiConfig {
  final AiProviderType defaultProvider;
  final Map<String, String> apiKeys;

  const AiConfig({
    this.defaultProvider = AiProviderType.gemini,
    this.apiKeys = const {},
  });
}

enum AiProviderType {
  gemini,
  openai,
  anthropic,
}

final aiConfigProvider = Provider<AiConfig>((ref) {
  return const AiConfig();
});

extension WidgetTesterExtensions on WidgetTester {
  Future<WidgetTester> pumpWithProviders(
    Widget widget, {
    List<Override> overrides = const [],
    ThemeData? theme,
  }) async {
    return pumpTestWidget(
      this,
      widget,
      overrides: overrides,
      theme: theme,
    );
  }

  Future<WidgetTester> pumpWithAnimation(
    Widget widget, {
    List<Override> overrides = const [],
    ThemeData? theme,
    Duration duration = const Duration(seconds: 1),
  }) async {
    return pumpTestWidgetWithAnimation(
      this,
      widget,
      overrides: overrides,
      theme: theme,
      animationDuration: duration,
    );
  }

  T findWidget<T extends Widget>() => widget<T>(find.byType(T));
  Element findElement<T extends Widget>() => element(find.byType(T));
}
