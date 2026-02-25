import 'package:mocktail/mocktail.dart';
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';

class FakeRedFlag extends Fake implements RedFlag {}

class MockAiProvider extends Mock implements AiProvider {
  MockAiProvider() {
    _stubDefaults();
  }

  factory MockAiProvider.withDefaults() {
    return MockAiProvider();
  }

  factory MockAiProvider.withError() {
    final provider = MockAiProvider._internal();
    provider._stubErrors();
    return provider;
  }

  MockAiProvider._internal();

  void _stubDefaults() {
    when(() => name).thenReturn('MockProvider');
    when(() => modelId).thenReturn('mock-model');
    when(() => isAvailable()).thenAnswer((_) async => true);
    when(() => initialize()).thenAnswer((_) async {});
    when(() => dispose()).thenReturn(null);
    when(() => summarizeDocument(any(), persona: any(named: 'persona')))
        .thenAnswer((_) async => 'Mock summary');
    when(() => translateToPlainEnglish(any(), persona: any(named: 'persona')))
        .thenAnswer((_) async => 'Mock plain English translation');
    when(() => detectRedFlags(any(), persona: any(named: 'persona')))
        .thenAnswer((_) async => <RedFlag>[]);
    when(() => chatWithContext(
          documentText: any(named: 'documentText'),
          userQuery: any(named: 'userQuery'),
          conversationHistory: any(named: 'conversationHistory'),
          persona: any(named: 'persona'),
        )).thenAnswer((_) async => 'Mock chat response');
    when(() => generateText(
          prompt: any(named: 'prompt'),
          persona: any(named: 'persona'),
          maxTokens: any(named: 'maxTokens'),
        )).thenAnswer((_) async => 'Mock generated text');
    when(() => getSuggestedQuestions(
          documentText: any(named: 'documentText'),
          documentType: any(named: 'documentType'),
          maxQuestions: any(named: 'maxQuestions'),
        )).thenAnswer((_) async => <String>[
              'Mock question 1?',
              'Mock question 2?',
            ]);
  }

  void _stubErrors() {
    when(() => name).thenReturn('ErrorProvider');
    when(() => modelId).thenReturn('error-model');
    when(() => isAvailable()).thenAnswer((_) async => false);
    when(() => initialize())
        .thenThrow(Exception('Failed to initialize provider'));
    when(() => dispose()).thenReturn(null);
    when(() => summarizeDocument(any(), persona: any(named: 'persona')))
        .thenThrow(Exception('Summarization failed'));
    when(() => translateToPlainEnglish(any(), persona: any(named: 'persona')))
        .thenThrow(Exception('Translation failed'));
    when(() => detectRedFlags(any(), persona: any(named: 'persona')))
        .thenThrow(Exception('Red flag detection failed'));
    when(() => chatWithContext(
          documentText: any(named: 'documentText'),
          userQuery: any(named: 'userQuery'),
          conversationHistory: any(named: 'conversationHistory'),
          persona: any(named: 'persona'),
        )).thenThrow(Exception('Chat failed'));
    when(() => generateText(
          prompt: any(named: 'prompt'),
          persona: any(named: 'persona'),
          maxTokens: any(named: 'maxTokens'),
        )).thenThrow(Exception('Text generation failed'));
    when(() => getSuggestedQuestions(
          documentText: any(named: 'documentText'),
          documentType: any(named: 'documentType'),
          maxQuestions: any(named: 'maxQuestions'),
        )).thenThrow(Exception('Question generation failed'));
  }
}