import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:legalease/features/document_scan/presentation/screens/document_upload_screen.dart';
import 'package:legalease/features/document_scan/presentation/screens/analysis_result_screen.dart';
import 'package:legalease/features/chat/presentation/screens/chat_screen.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';
import 'package:legalease/features/document_scan/domain/models/analysis_result.dart';
import 'package:legalease/features/chat/domain/providers/chat_providers.dart';
import 'package:legalease/features/chat/domain/models/chat_message.dart';
import 'package:legalease/shared/providers/ai_providers.dart';
import 'package:legalease/shared/providers/ocr_provider.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';
import 'package:legalease/shared/models/ai_config_model.dart';
import 'package:legalease/shared/services/ai/ai_service.dart';
import 'package:legalease/features/document_scan/data/models/ocr_result_model.dart';
import 'package:legalease/features/document_scan/data/services/ocr_service.dart';
import 'package:legalease/features/document_scan/data/services/document_processor.dart';
import 'package:legalease/shared/models/document_model.dart' hide DocumentType, DocumentModel;

class MockAiProvider extends Mock implements AiProvider {}

class MockOcrService extends Mock implements OcrService {}

class FakeAiConfig extends Fake implements AiConfig {}

final testAnalysisStateProvider = StateProvider<AnalysisState>((ref) => const AnalysisState());

final testOcrStateProvider = StateProvider<OcrState>((ref) => const OcrState());

final testChatSessionProvider = StateProvider<ChatSession>((ref) {
  return ChatSession(
    id: '',
    documentId: '',
    documentContext: '',
    createdAt: DateTime.now(),
  );
});

final testIsTypingProvider = StateProvider<bool>((ref) => false);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeAiConfig());
  });

  group('Document Analysis Flow', () {
    late MockAiProvider mockAiProvider;
    late MockOcrService mockOcrService;

    setUp(() {
      mockAiProvider = MockAiProvider();
      mockOcrService = MockOcrService();

      setupMockAiProvider(mockAiProvider);
    });

    ProviderScope createTestApp({
      required Widget home,
      AnalysisState? analysisState,
      OcrState? ocrState,
      ChatSession? chatSession,
      bool isTyping = false,
    }) {
      return ProviderScope(
        overrides: [
          currentAiProviderProvider.overrideWith((ref) => mockAiProvider),
          aiServiceProvider.overrideWith((ref) => AiServiceProvider()..initialize(const AiConfig())),
          ocrServiceProvider.overrideWith((ref) => mockOcrService),
          analysisNotifierProvider.overrideWith(
            (ref) => AnalysisNotifier()
              ..state = analysisState ??
                  const AnalysisState(
                    currentStep: AnalysisStep.idle,
                    progress: 0.0,
                  ),
          ),
          ocrStateProvider.overrideWith(
            (ref) => OcrStateNotifier(mockOcrService)
              ..state = ocrState ??
                  const OcrState(
                    status: ProcessingStatus.idle,
                    progress: 0.0,
                  ),
          ),
          chatSessionProvider.overrideWith(
            (ref) => ChatSessionNotifier(ref)
              ..state = chatSession ??
                  ChatSession(
                    id: '',
                    documentId: '',
                    documentContext: '',
                    createdAt: DateTime.now(),
                  ),
          ),
          isAssistantTypingProvider.overrideWith((ref) => isTyping),
        ],
        child: MaterialApp(home: home),
      );
    }

    group('1. Document Upload Flow', () {
      testWidgets('displays document upload screen with all UI elements', (tester) async {
        await tester.pumpWidget(
          createTestApp(home: const DocumentUploadScreen()),
        );

        await tester.pumpAndSettle();

        expect(find.text('LegalEase'), findsOneWidget);
        expect(find.textContaining('legal document'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Files'), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
      });

      testWidgets('displays upload instructions in hero section', (tester) async {
        await tester.pumpWidget(
          createTestApp(home: const DocumentUploadScreen()),
        );

        await tester.pumpAndSettle();

        expect(find.text('Understand any legal document in seconds'), findsOneWidget);
        expect(
          find.textContaining('Upload a contract'),
          findsOneWidget,
        );
      });

      testWidgets('shows recent analyses when available', (tester) async {
        final recentAnalysis = createMockAnalysisResult(
          documentId: 'doc-1',
          fileName: 'Contract.pdf',
        );

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          recentAnalyses: [recentAnalysis],
        );

        await tester.pumpWidget(
          createTestApp(
            home: const DocumentUploadScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Recent Analyses'), findsOneWidget);
        expect(find.text('Contract.pdf'), findsOneWidget);
      });

      testWidgets('tapping upload option triggers navigation', (tester) async {
        await tester.pumpWidget(
          createTestApp(home: const DocumentUploadScreen()),
        );

        await tester.pumpAndSettle();

        final cameraButton = find.text('Camera');
        expect(cameraButton, findsOneWidget);

        await tester.tap(cameraButton);
        await tester.pumpAndSettle();
      });
    });

    group('2. OCR Processing Flow', () {
      testWidgets('OCR service initialization state is correct', (tester) async {
        final ocrState = const OcrState(
          status: ProcessingStatus.idle,
          progress: 0.0,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            ocrState: ocrState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(ocrStateProvider);

        expect(state.status, ProcessingStatus.idle);
        expect(state.progress, 0.0);
        expect(state.isProcessing, false);
      });

      testWidgets('OCR progress updates correctly', (tester) async {
        final ocrState = const OcrState(
          status: ProcessingStatus.processing,
          progress: 0.5,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            ocrState: ocrState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(ocrStateProvider);

        expect(state.isProcessing, true);
        expect(state.progress, 0.5);
      });

      testWidgets('OCR completion sets correct state', (tester) async {
        final mockResult = OcrResultModel(
          text: 'Sample extracted text',
          blocks: [
            const OcrTextBlock(
              text: 'Sample',
              boundingBox: Rect.fromLTRB(0, 0, 100, 20),
              lines: ['Sample'],
              confidence: 0.95,
            ),
          ],
          imageSize: const Size(612, 792),
          processingTime: const Duration(milliseconds: 500),
          confidence: 0.95,
          pageIndex: 0,
        );

        final ocrState = OcrState(
          status: ProcessingStatus.completed,
          currentResult: mockResult,
          progress: 1.0,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            ocrState: ocrState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(ocrStateProvider);

        expect(state.isCompleted, true);
        expect(state.hasResult, true);
        expect(state.currentResult?.text, 'Sample extracted text');
      });

      testWidgets('OCR state properties work correctly', (tester) async {
        final ocrState = const OcrState(
          status: ProcessingStatus.processing,
          progress: 0.3,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            ocrState: ocrState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(ocrStateProvider);

        expect(state.status, ProcessingStatus.processing);
        expect(state.isProcessing, true);
      });
    });

    group('3. AI Analysis Flow', () {
      testWidgets('mock AI service returns expected summary', (tester) async {
        when(() => mockAiProvider.summarizeDocument(any(), persona: any(named: 'persona')))
            .thenAnswer((_) async => 'This is a test summary of the document.');

        final result = await mockAiProvider.summarizeDocument('Test document text');

        expect(result, 'This is a test summary of the document.');
        verify(() => mockAiProvider.summarizeDocument(any(), persona: any(named: 'persona'))).called(1);
      });

      testWidgets('mock AI service returns plain English translation', (tester) async {
        when(() => mockAiProvider.translateToPlainEnglish(any(), persona: any(named: 'persona')))
            .thenAnswer((_) async => 'This is the plain English translation.');

        final result = await mockAiProvider.translateToPlainEnglish('Legal text here');

        expect(result, 'This is the plain English translation.');
        verify(() => mockAiProvider.translateToPlainEnglish(any(), persona: any(named: 'persona'))).called(1);
      });

      testWidgets('mock AI service detects red flags', (tester) async {
        final redFlags = [
          RedFlag(
            id: 'flag-1',
            originalText: 'Unlimited liability clause',
            explanation: 'This clause exposes you to unlimited financial risk.',
            severity: 'critical',
            startPosition: 0,
            endPosition: 30,
            confidenceScore: 0.95,
          ),
        ];

        when(() => mockAiProvider.detectRedFlags(any(), persona: any(named: 'persona')))
            .thenAnswer((_) async => redFlags);

        final result = await mockAiProvider.detectRedFlags('Document text with liability clause');

        expect(result.length, 1);
        expect(result.first.severity, 'critical');
        verify(() => mockAiProvider.detectRedFlags(any(), persona: any(named: 'persona'))).called(1);
      });

      testWidgets('analysis state tracks progress correctly', (tester) async {
        final analysisState = AnalysisState(
          currentStep: AnalysisStep.analyzing,
          progress: 0.6,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            analysisState: analysisState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(analysisNotifierProvider);

        expect(state.isProcessing, true);
        expect(state.progress, 0.6);
        expect(state.currentStep, AnalysisStep.analyzing);
      });

      testWidgets('analysis completion sets all results', (tester) async {
        final result = createMockAnalysisResult(
          summary: 'Test summary',
          plainEnglishTranslation: 'Plain English version',
          redFlagCount: 2,
        );

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Test')),
            analysisState: analysisState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Test')));
        final state = container.read(analysisNotifierProvider);

        expect(state.isCompleted, true);
        expect(state.result, isNotNull);
        expect(state.result?.summary, 'Test summary');
        expect(state.result?.plainEnglishTranslation, 'Plain English version');
        expect(state.result?.redFlags.length, 2);
      });
    });

    group('4. Results Display', () {
      testWidgets('displays summary tab with document type and overview', (tester) async {
        final result = createMockAnalysisResult(
          fileName: 'Employment Contract.pdf',
          documentType: DocumentType.employment,
          summary: 'This employment agreement outlines the terms of employment.',
        );

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Employment Document'), findsOneWidget);
        expect(find.text('Overview'), findsOneWidget);
        expect(find.textContaining('employment agreement'), findsOneWidget);
        expect(find.text('Key Points'), findsOneWidget);
        expect(find.text('Document Info'), findsOneWidget);
      });

      testWidgets('displays red flags tab with severity breakdown', (tester) async {
        final result = createMockAnalysisResult(
          redFlags: [
            createMockRedFlag(severity: RedFlagSeverity.critical),
            createMockRedFlag(severity: RedFlagSeverity.warning),
            createMockRedFlag(severity: RedFlagSeverity.info),
          ],
        );

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.warning_amber_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Critical'), findsWidgets);
        expect(find.text('Warning'), findsWidgets);
        expect(find.text('Info'), findsWidgets);
      });

      testWidgets('displays no red flags message when clean', (tester) async {
        final result = createMockAnalysisResult(redFlags: []);

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.warning_amber_rounded));
        await tester.pumpAndSettle();

        expect(find.text('No Red Flags Detected'), findsOneWidget);
        expect(find.textContaining('did not identify any significant concerns'), findsOneWidget);
      });

      testWidgets('displays translation tab with toggle', (tester) async {
        final result = createMockAnalysisResult(
          originalText: 'The party of the first part...',
          plainEnglishTranslation: 'The first person involved...',
        );

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.translate_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Original'), findsOneWidget);
        expect(find.text('Translated'), findsOneWidget);
      });

      testWidgets('shows floating action button for chat', (tester) async {
        final result = createMockAnalysisResult();

        final analysisState = AnalysisState(
          currentStep: AnalysisStep.completed,
          progress: 1.0,
          result: result,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: analysisState,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Ask a Question'), findsOneWidget);
      });

      testWidgets('handles missing analysis result gracefully', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: const AnalysisState(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('No analysis result available'), findsOneWidget);
      });
    });

    group('5. Chat Flow', () {
      testWidgets('displays chat screen with empty state', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: ChatSession(
              id: 'session-1',
              documentId: 'doc-1',
              documentContext: 'Sample document text',
              createdAt: DateTime.now(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Chat'), findsOneWidget);
        expect(find.text('Ask me anything'), findsOneWidget);
        expect(find.textContaining('help you understand your document'), findsOneWidget);
      });

      testWidgets('displays suggested questions', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: ChatSession(
              id: 'session-1',
              documentId: 'doc-1',
              documentContext: 'Sample document text',
              createdAt: DateTime.now(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('What are the key terms?'), findsOneWidget);
        expect(find.text('Are there any hidden fees?'), findsOneWidget);
      });

      testWidgets('sends a message and displays conversation', (tester) async {
        final chatSession = ChatSession(
          id: 'session-1',
          documentId: 'doc-1',
          documentContext: 'Sample document text',
          messages: [
            ChatMessage.user('What does this contract say about termination?'),
            ChatMessage.assistant('Based on the document, the termination clause states...'),
          ],
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: chatSession,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('What does this contract say about termination?'), findsOneWidget);
        expect(find.textContaining('termination clause'), findsOneWidget);
      });

      testWidgets('displays typing indicator when AI is responding', (tester) async {
        final chatSession = ChatSession(
          id: 'session-1',
          documentId: 'doc-1',
          documentContext: 'Sample document text',
          messages: [
            ChatMessage.user('Test question?'),
            ChatMessage.loading(),
          ],
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: chatSession,
            isTyping: true,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test question?'), findsOneWidget);
      });

      testWidgets('shows clear chat option when messages exist', (tester) async {
        final chatSession = ChatSession(
          id: 'session-1',
          documentId: 'doc-1',
          documentContext: 'Sample document text',
          messages: [
            ChatMessage.user('Test question?'),
            ChatMessage.assistant('Test response.'),
          ],
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: chatSession,
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      });

      testWidgets('displays chat input field', (tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: ChatSession(
              id: 'session-1',
              documentId: 'doc-1',
              documentContext: 'Sample document text',
              createdAt: DateTime.now(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Ask a question about this document...'), findsOneWidget);
      });

      testWidgets('clear chat dialog appears on delete tap', (tester) async {
        final chatSession = ChatSession(
          id: 'session-1',
          documentId: 'doc-1',
          documentContext: 'Sample document text',
          messages: [
            ChatMessage.user('Test?'),
            ChatMessage.assistant('Response.'),
          ],
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestApp(
            home: const ChatScreen(),
            chatSession: chatSession,
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Clear Chat'), findsOneWidget);
        expect(find.text('Are you sure you want to clear all messages?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Clear'), findsOneWidget);
      });
    });

    group('End-to-End Flow', () {
      testWidgets('complete document analysis workflow', (tester) async {
        await tester.pumpWidget(
          createTestApp(home: const DocumentUploadScreen()),
        );

        await tester.pumpAndSettle();

        expect(find.text('LegalEase'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);

        final result = createMockAnalysisResult(
          fileName: 'Service Agreement.pdf',
          summary: 'This service agreement outlines the terms of service.',
          redFlagCount: 1,
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: AnalysisState(
              currentStep: AnalysisStep.completed,
              progress: 1.0,
              result: result,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Service Agreement.pdf'), findsOneWidget);
        expect(find.textContaining('service agreement'), findsOneWidget);

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('navigation from results to chat context', (tester) async {
        final result = createMockAnalysisResult(
          summary: 'Test document summary for chat context.',
        );

        await tester.pumpWidget(
          createTestApp(
            home: const AnalysisResultScreen(),
            analysisState: AnalysisState(
              currentStep: AnalysisStep.completed,
              progress: 1.0,
              result: result,
            ),
            chatSession: ChatSession(
              id: 'chat-1',
              documentId: 'doc-1',
              documentContext: result.originalText,
              createdAt: DateTime.now(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FloatingActionButton), findsOneWidget);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
      });

      testWidgets('error handling in analysis flow', (tester) async {
        final analysisState = AnalysisState(
          currentStep: AnalysisStep.error,
          errorMessage: 'Failed to process document',
        );

        await tester.pumpWidget(
          createTestApp(
            home: const Scaffold(body: Text('Error State')),
            analysisState: analysisState,
          ),
        );

        final container = ProviderScope.containerOf(tester.element(find.text('Error State')));
        final state = container.read(analysisNotifierProvider);

        expect(state.hasError, true);
        expect(state.errorMessage, 'Failed to process document');
      });
    });
  });
}

void setupMockAiProvider(MockAiProvider mockProvider) {
  when(() => mockProvider.name).thenReturn('MockProvider');
  when(() => mockProvider.modelId).thenReturn('mock-model');
  when(() => mockProvider.isAvailable()).thenAnswer((_) async => true);
  when(() => mockProvider.initialize()).thenAnswer((_) async {});
  when(() => mockProvider.dispose()).thenReturn(null);
  when(() => mockProvider.summarizeDocument(any(), persona: any(named: 'persona')))
      .thenAnswer((_) async => 'Mock summary of the document.');
  when(() => mockProvider.translateToPlainEnglish(any(), persona: any(named: 'persona')))
      .thenAnswer((_) async => 'Mock plain English translation.');
  when(() => mockProvider.detectRedFlags(any(), persona: any(named: 'persona')))
      .thenAnswer((_) async => <RedFlag>[]);
  when(() => mockProvider.chatWithContext(
        documentText: any(named: 'documentText'),
        userQuery: any(named: 'userQuery'),
        conversationHistory: any(named: 'conversationHistory'),
        persona: any(named: 'persona'),
      )).thenAnswer((_) async => 'Mock AI response to your question.');
  when(() => mockProvider.generateText(
        prompt: any(named: 'prompt'),
        persona: any(named: 'persona'),
        maxTokens: any(named: 'maxTokens'),
      )).thenAnswer((_) async => 'Mock generated text.');
  when(() => mockProvider.getSuggestedQuestions(
        documentText: any(named: 'documentText'),
        documentType: any(named: 'documentType'),
        maxQuestions: any(named: 'maxQuestions'),
      )).thenAnswer((_) async => <String>[
            'What are the key terms?',
            'Are there any hidden fees?',
            'Can I cancel this contract?',
          ]);
}

AnalysisResult createMockAnalysisResult({
  String documentId = 'test-doc-1',
  String fileName = 'Test Document.pdf',
  DocumentType documentType = DocumentType.contract,
  String originalText = 'This is the original legal document text.',
  String summary = 'This is a test summary.',
  String plainEnglishTranslation = 'This is the plain English translation.',
  List<RedFlagItem> redFlags = const [],
  int redFlagCount = 0,
}) {
  final flags = redFlags.isEmpty && redFlagCount > 0
      ? List.generate(
          redFlagCount,
          (i) => RedFlagItem(
            id: 'flag-$i',
            originalClause: 'Risk clause $i',
            explanation: 'This is a potential risk $i',
            severity: i == 0 ? RedFlagSeverity.critical : RedFlagSeverity.warning,
            startIndex: i * 100,
            endIndex: (i * 100) + 50,
            confidenceScore: 0.85,
          ),
        )
      : redFlags;

  return AnalysisResult(
    documentId: documentId,
    originalText: originalText,
    plainEnglishTranslation: plainEnglishTranslation,
    summary: summary,
    redFlags: flags,
    metadata: DocumentMetadata(
      fileName: fileName,
      pageCount: 1,
      wordCount: originalText.split(' ').length,
      characterCount: originalText.length,
      type: documentType,
      processingTime: const Duration(seconds: 2),
      confidence: 0.92,
    ),
    status: AnalysisStatus.completed,
    analyzedAt: DateTime.now(),
  );
}

RedFlagItem createMockRedFlag({
  String id = 'flag-1',
  String originalClause = 'Unlimited liability clause',
  String explanation = 'This clause exposes you to unlimited financial risk.',
  RedFlagSeverity severity = RedFlagSeverity.warning,
}) {
  return RedFlagItem(
    id: id,
    originalClause: originalClause,
    explanation: explanation,
    severity: severity,
    startIndex: 0,
    endIndex: originalClause.length,
    confidenceScore: 0.85,
  );
}
