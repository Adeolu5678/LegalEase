import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/models/persona_model.dart';

abstract class AiProvider {
  String get name;
  String get modelId;
  set modelId(String modelId);

  Future<String> summarizeDocument(String documentText, {Persona? persona});

  Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona});

  Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona});

  Future<String> chatWithContext({
    required String documentText,
    required String userQuery,
    List<Map<String, String>>? conversationHistory,
    Persona? persona,
  });

  Future<String> generateText({
    required String prompt,
    String? persona,
    int? maxTokens,
  });

  Future<List<String>> getSuggestedQuestions({
    required String documentText,
    String? documentType,
    int maxQuestions = 5,
  });

  Future<bool> isAvailable();

  Future<void> initialize();

  void dispose();
}
