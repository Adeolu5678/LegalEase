import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/auth/presentation/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('has navigation to signup', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.textContaining('Sign Up'), findsWidgets);
    });
  });
}
