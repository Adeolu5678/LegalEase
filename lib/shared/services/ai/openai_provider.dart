import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/services/ai/ai_provider.dart';
import 'package:legalease/shared/services/ai/retry_helper.dart';
import 'package:legalease/shared/services/ai/response_cache.dart';

class OpenAiProvider implements AiProvider {
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
  final String _name = 'OpenAI';
  final String _baseUrl = 'https://api.openai.com/v1';
  final http.Client _client;

  OpenAiProvider({
    required String apiKey,
    String modelId = 'gpt-4-turbo',
    http.Client? client,
  })  : _apiKey = apiKey,
        _modelId = modelId,
        _client = client ?? http.Client();

  @override
  String get name => _name;

  @override
  String get modelId => _modelId;

  @override
  set modelId(String modelId) {
    _modelId = modelId;
  }

  @override
  Future<void> initialize() async {
    if (_apiKey.isEmpty) {
      throw StateError('OpenAI API key is not configured');
    }
  }

  @override
  Future<bool> isAvailable() async {
    if (_apiKey.isEmpty) return false;
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/models'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
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
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

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

  @override
  Future<String> chatWithContext({
    required String documentText,
    required String userQuery,
    List<Map<String, String>>? conversationHistory,
    Persona? persona,
  }) async {
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': 'You are a helpful legal assistant with expertise in document analysis. '
            'Answer questions based on the provided document context.',
      },
    ];

    if (persona != null) {
      final toneName = persona.tone.name;
      final styleName = persona.style.name;
      messages[0]['content'] = 'You are acting as ${persona.name}. ${persona.systemPrompt}. Your communication style should be $toneName and $styleName.';
    }

    if (conversationHistory != null) {
      messages.addAll(conversationHistory);
    }

    messages.add({
      'role': 'user',
      'content': 'Document Context:\n$documentText\n\nQuestion: $userQuery',
    });

    return await _createChatCompletionWithRetry(messages);
  }

  @override
  Future<String> generateText({
    required String prompt,
    String? persona,
    int? maxTokens,
  }) async {
    final messages = <Map<String, String>>[];

    if (persona != null) {
      messages.add({
        'role': 'system',
        'content': 'Act as $persona',
      });
    }

    messages.add({
      'role': 'user',
      'content': prompt,
    });

    return await _createChatCompletion(messages, maxTokens: maxTokens);
  }

  Future<String> _createChatCompletion(
    List<Map<String, String>> messages, {
    int? maxTokens,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: _getHeaders(),
      body: jsonEncode({
        'model': _modelId,
        'messages': messages,
        'max_tokens': maxTokens ?? 2048,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception('OpenAI API error: ${error['error']?['message'] ?? response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    if (choices.isEmpty) return '';

    return (choices[0] as Map<String, dynamic>)['message']['content'] as String? ?? '';
  }

  Future<String> _createChatCompletionWithRetry(
    List<Map<String, String>> messages, {
    int? maxTokens,
  }) async {
    return RetryHelper.withRetry(() => _createChatCompletion(messages, maxTokens: maxTokens));
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
    
    final cacheKey = 'suggestedQuestions_$documentContext';
    final response = await _generateTextWithRetry(prompt, maxTokens: 500);
    return _parseQuestionsResponse(response);
  }

  List<String> _parseQuestionsResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(response);
      if (jsonMatch == null) {
        return _getDefaultQuestions();
      }

      final jsonString = jsonMatch.group(0)!;
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

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
    _client.close();
    _cache.clear();
  }
}
