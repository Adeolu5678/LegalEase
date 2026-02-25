import 'dart:async';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';
import 'package:legalease/shared/services/ai/retry_helper.dart';
import 'package:legalease/shared/services/ai/response_cache.dart';

class GeminiProvider implements AiProvider {
  final ResponseCache _cache = ResponseCache();
  String _applyPersona(String prompt, Persona? persona) {
    if (persona == null) return prompt;
    
    final toneName = persona.tone.name;
    final styleName = persona.style.name;
    
    final systemInstruction = 'You are acting as ${persona.name}. ${persona.systemPrompt}. Your communication style should be $toneName and $styleName.';
    
    return '$systemInstruction\n\n$prompt';
  }
  final String _apiKey;
  String _modelId;
  GenerativeModel? _model;
  final String _name = 'Google Gemini';

  GeminiProvider({
    required String apiKey,
    String modelId = 'gemini-pro',
  })  : _apiKey = apiKey,
        _modelId = modelId;

  @override
  String get name => _name;

  @override
  String get modelId => _modelId;

  @override
  set modelId(String modelId) {
    _modelId = modelId;
    _model = null;
  }

  @override
  Future<void> initialize() async {
    if (_apiKey.isEmpty) {
      throw StateError('Gemini API key is not configured');
    }
    _model = GenerativeModel(
      model: _modelId,
      apiKey: _apiKey,
    );
  }

  GenerativeModel _getModel() {
    _model ??= GenerativeModel(
      model: _modelId,
      apiKey: _apiKey,
    );
    return _model!;
  }

  @override
  Future<bool> isAvailable() async {
    if (_apiKey.isEmpty) return false;
    try {
      await initialize();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> summarizeDocument(String documentText, {Persona? persona}) async {
    final prompt = '''
You are a legal document analyzer. Summarize the following legal document concisely, 
highlighting key points, obligations, and important clauses. Use clear, professional language.

Document:
$documentText

Provide a structured summary with:
1. Document Overview
2. Key Parties Involved
3. Main Obligations
4. Important Dates/Terms
5. Critical Clauses
''';
    final effectivePrompt = _applyPersona(prompt, persona);
    final cacheKey = _cache.generateKey('summarize', documentText, persona?.id);
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;
    
    final result = await _generateTextWithRetry(effectivePrompt);
    _cache.set(cacheKey, result);
    return result;
  }

  @override
  Future<String> translateToPlainEnglish(String legaleseText, {Persona? persona}) async {
    final prompt = '''
You are a legal translator. Convert the following legal text into plain, easy-to-understand English.
Maintain accuracy while using simple language that a non-lawyer can understand.

Legal Text:
$legaleseText

Plain English Translation:
''';
    final effectivePrompt = _applyPersona(prompt, persona);
    final cacheKey = _cache.generateKey('translate', legaleseText, persona?.id);
    final cached = _cache.get(cacheKey);
    if (cached != null) return cached;
    
    final result = await _generateTextWithRetry(effectivePrompt);
    _cache.set(cacheKey, result);
    return result;
  }

  @override
  Future<List<RedFlag>> detectRedFlags(String documentText, {Persona? persona}) async {
    final prompt = '''
You are a legal risk analyst. Analyze the following document for potential red flags, 
unfair terms, hidden fees, or concerning clauses that might disadvantage the signer.

For each red flag found, provide:
- The exact text from the document
- An explanation of why it's concerning
- Severity level: "low", "medium", or "high"
- Confidence score: a number from 0.0 to 1.0 indicating how confident you are that this is a genuine concern

Document:
$documentText

Format your response as a JSON array with objects containing:
- "originalText": the concerning text
- "explanation": why it's a red flag
- "severity": low/medium/high
- "confidenceScore": a number between 0.0 and 1.0

If no red flags are found, return an empty array: []
''';
    final effectivePrompt = _applyPersona(prompt, persona);
    final cacheKey = _cache.generateKey('redFlags', documentText, persona?.id);
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return _parseRedFlagsResponse(cached);
    }
    
    final response = await _generateTextWithRetry(effectivePrompt);
    _cache.set(cacheKey, response);
    return _parseRedFlagsResponse(response);
  }

  List<RedFlag> _parseRedFlagsResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch == null) return [];

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> jsonList = _parseJsonList(jsonString);

      return jsonList.asMap().entries.map((entry) {
        final index = entry.key;
        final json = entry.value as Map<String, dynamic>;
        return RedFlag(
          id: 'red_flag_$index',
          originalText: json['originalText'] as String? ?? '',
          explanation: json['explanation'] as String? ?? '',
          severity: json['severity'] as String? ?? 'medium',
          startPosition: 0,
          endPosition: 0,
          confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.8,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  List<dynamic> _parseJsonList(String jsonString) {
    return jsonDecode(jsonString) as List<dynamic>;
  }

  @override
  Future<String> chatWithContext({
    required String documentText,
    required String userQuery,
    List<Map<String, String>>? conversationHistory,
    Persona? persona,
  }) async {
    final historyContent = conversationHistory?.map((msg) {
      final role = msg['role'] ?? 'user';
      final content = msg['content'] ?? '';
      return '$role: $content';
    }).join('\n');

    final prompt = '''
You are a helpful legal assistant with expertise in document analysis.
Answer the user's question based on the provided document context.

Document Context:
$documentText

${historyContent != null ? 'Previous Conversation:\n$historyContent\n' : ''}

User Question: $userQuery

Provide a clear, accurate, and helpful response based on the document content.
If the answer cannot be found in the document, state that clearly.
''';
    return await _generateTextWithRetry(_applyPersona(prompt, persona));
  }

  @override
  Future<String> generateText({
    required String prompt,
    String? persona,
    int? maxTokens,
  }) async {
    final effectivePrompt = persona != null
        ? 'Act as $persona.\n\n$prompt'
        : prompt;

    final model = _getModel();
    final content = [Content.text(effectivePrompt)];

    final response = await model.generateContent(
      content,
      generationConfig: GenerationConfig(
        maxOutputTokens: maxTokens ?? 2048,
      ),
    );

    return response.text ?? '';
  }

  Future<String> _generateTextWithRetry(String prompt, {int? maxTokens}) async {
    return RetryHelper.withRetry(() => generateText(prompt: prompt, maxTokens: maxTokens));
  }

  @override
  Future<List<String>> getSuggestedQuestions({
    required String documentText,
    String? documentType,
    int maxQuestions = 5,
  }) async {
    final documentContext = documentText.length > 2000 
        ? documentText.substring(0, 2000) 
        : documentText;
    
    final prompt = '''
You are a legal document analysis assistant. Based on the following document excerpt, suggest $maxQuestions relevant questions that a user might want to ask about this document.

Document Type: ${documentType ?? 'Unknown'}
Document Excerpt:
$documentContext

Generate exactly $maxQuestions questions that would help the user understand important aspects of this document such as:
- Key terms and obligations
- Potential risks or concerns
- Important deadlines or dates
- Financial implications
- Termination or renewal terms
- Parties' rights and responsibilities

Format your response as a JSON array of strings, each being a question. Example:
["Question 1?", "Question 2?", "Question 3?", "Question 4?", "Question 5?"]

Only output the JSON array, no other text.
''';
    
    final cacheKey = _cache.generateKey('suggestedQuestions', documentContext, null);
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return _parseQuestionsResponse(cached);
    }
    
    final response = await _generateTextWithRetry(prompt, maxTokens: 500);
    _cache.set(cacheKey, response);
    return _parseQuestionsResponse(response);
  }

  List<String> _parseQuestionsResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch == null) {
        return _getDefaultQuestions();
      }

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> jsonList = _parseJsonList(jsonString);

      return jsonList
          .map((q) => q.toString().trim())
          .where((q) => q.isNotEmpty && q.endsWith('?'))
          .toList();
    } catch (_) {
      return _getDefaultQuestions();
    }
  }

  List<String> _getDefaultQuestions() {
    return [
      'What are the key terms?',
      'Are there any hidden fees?',
      'Can I cancel this contract?',
      'What are my obligations?',
      'What happens if I breach?',
    ];
  }

  @override
  void dispose() {
    _model = null;
    _cache.clear();
  }
}
