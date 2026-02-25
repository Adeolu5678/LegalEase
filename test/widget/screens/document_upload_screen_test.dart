import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/document_scan/presentation/screens/document_upload_screen.dart';

void main() {
  group('DocumentUploadScreen', () {
    testWidgets('displays hero section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DocumentUploadScreen(),
          ),
        ),
      );

      expect(find.textContaining('legal document'), findsWidgets);
    });

    testWidgets('displays upload options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DocumentUploadScreen(),
          ),
        ),
      );

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Files'), findsOneWidget);
    });

    testWidgets('has bottom navigation', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DocumentUploadScreen(),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
}
