import 'package:legalease/shared/models/persona_model.dart';
import 'package:legalease/shared/models/document_model.dart';
import 'package:legalease/shared/services/ai/ai_service.dart';
import 'package:legalease/features/persona/domain/repositories/persona_repository.dart';

/// Service that integrates personas with AI operations.
///
/// This service applies active persona context to AI prompts,
/// enabling customized AI responses based on user preferences.
class PersonaService {
  final PersonaRepository _repository;
  final AiService _aiService;

  PersonaService({
    required PersonaRepository repository,
    required AiService aiService,
  })  : _repository = repository,
        _aiService = aiService;

  /// Summarizes a document with optional persona context.
  ///
  /// If [persona] is null, uses the default AI behavior.
  /// The persona's tone, style, and system prompt are injected
  /// into the AI request for customized summaries.
  Future<String> summarizeWithPersona(
    String documentText,
    Persona? persona,
  ) async {
    if (persona == null) {
      return _aiService.summarizeDocument(documentText);
    }

    final personaPrompt = buildPersonaPrompt(persona);
    final enhancedPrompt = '''
$personaPrompt

Please summarize the following legal document:

$documentText
''';

    return _aiService.generateText(
      prompt: enhancedPrompt,
      maxTokens: 2000,
    );
  }

  /// Translates legalese to plain English with optional persona context.
  ///
  /// If [persona] is null, uses the default AI behavior.
  /// The persona's tone and style affect how the translation is presented.
  Future<String> translateWithPersona(
    String legaleseText,
    Persona? persona,
  ) async {
    if (persona == null) {
      return _aiService.translateToPlainEnglish(legaleseText);
    }

    final personaPrompt = buildPersonaPrompt(persona);
    final enhancedPrompt = '''
$personaPrompt

Please translate the following legal text into plain English:

$legaleseText
''';

    return _aiService.generateText(
      prompt: enhancedPrompt,
      maxTokens: 2000,
    );
  }

  /// Detects red flags in a document with optional persona context.
  ///
  /// If [persona] is null, uses the default AI behavior.
  /// The persona's analysis style affects how red flags are identified
  /// and explained.
  Future<List<RedFlag>> detectRedFlagsWithPersona(
    String documentText,
    Persona? persona,
  ) async {
    if (persona == null) {
      return _aiService.detectRedFlags(documentText);
    }

    final personaPrompt = buildPersonaPrompt(persona);
    final enhancedPrompt = '''
$personaPrompt

Analyze the following legal document and identify any red flags, risky clauses, or potential issues:

$documentText

Please provide a detailed analysis of each red flag found, including:
1. The exact text of the problematic clause
2. An explanation of why it's concerning
3. The severity level (low, medium, high, critical)
''';

    final response = await _aiService.generateText(
      prompt: enhancedPrompt,
      maxTokens: 4000,
    );

    return _parseRedFlagsResponse(response);
  }

  /// Conducts a chat conversation with document context and persona.
  ///
  /// If [persona] is null, uses the default AI behavior.
  /// The [history] parameter allows for multi-turn conversations.
  Future<String> chatWithPersona({
    required String documentText,
    required String userQuery,
    Persona? persona,
    List<Map<String, String>>? history,
  }) async {
    if (persona == null) {
      return _aiService.chatWithContext(
        documentText: documentText,
        userQuery: userQuery,
        conversationHistory: history,
      );
    }

    final personaPrompt = buildPersonaPrompt(persona);
    final enhancedQuery = '''
Context: You are responding as the following persona:

$personaPrompt

Document context:
$documentText

User question: $userQuery
''';

    return _aiService.generateText(
      prompt: enhancedQuery,
      maxTokens: 2000,
    );
  }

  /// Builds a system prompt from a persona's configuration.
  ///
  /// Combines the persona's name, tone, style, and custom system prompt
  /// into a comprehensive instruction for the AI.
  String buildPersonaPrompt(Persona persona) {
    final buffer = StringBuffer();

    buffer.writeln('You are ${persona.name}.');
    buffer.writeln();

    if (persona.description.isNotEmpty) {
      buffer.writeln('Description: ${persona.description}');
      buffer.writeln();
    }

    buffer.writeln('Communication Tone: ${_toneToString(persona.tone)}');
    buffer.writeln('Response Style: ${_styleToString(persona.style)}');

    if (persona.language.isNotEmpty && persona.language != 'en') {
      buffer.writeln('Language: ${_languageToString(persona.language)}');
    }

    buffer.writeln();
    buffer.writeln('Core Instructions:');
    buffer.writeln(persona.systemPrompt);

    return buffer.toString();
  }

  /// Gets all personas for a user, including default templates.
  Future<List<Persona>> getUserPersonas(String userId) async {
    final userPersonas = await _repository.getPersonas(userId);
    final allPersonas = [...userPersonas];

    for (final defaultPersona in Persona.defaultTemplates) {
      if (!allPersonas.any((p) => p.id == defaultPersona.id)) {
        allPersonas.add(defaultPersona);
      }
    }

    return allPersonas;
  }

  /// Gets the active persona for a user with fallback to default.
  Future<Persona?> getActivePersonaWithFallback(String userId) async {
    final active = await _repository.getActivePersona(userId);
    if (active != null) return active;

    return Persona.defaultTemplates.first;
  }

  /// Sets the active persona for a user.
  Future<void> setActivePersona(String userId, String personaId) async {
    await _repository.setActivePersona(userId, personaId);
  }

  /// Creates a new custom persona for a user.
  Future<Persona> createCustomPersona({
    required String userId,
    required String name,
    required String description,
    required String systemPrompt,
    PersonaTone tone = PersonaTone.professional,
    PersonaStyle style = PersonaStyle.detailed,
    String language = 'en',
    bool isPremium = false,
  }) async {
    final persona = Persona(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      description: description,
      systemPrompt: systemPrompt,
      tone: tone,
      style: style,
      language: language,
      isPremium: isPremium,
      isDefault: false,
      createdAt: DateTime.now(),
    );

    return _repository.createPersona(userId, persona);
  }

  /// Updates an existing custom persona.
  Future<Persona> updateCustomPersona(String userId, Persona persona) async {
    if (persona.isDefault) {
      throw ArgumentError('Cannot modify default personas');
    }
    return _repository.updatePersona(userId, persona);
  }

  /// Deletes a custom persona.
  Future<void> deleteCustomPersona(String userId, String personaId) async {
    final persona = await _repository.getPersona(userId, personaId);
    if (persona?.isDefault ?? false) {
      throw ArgumentError('Cannot delete default personas');
    }
    await _repository.deletePersona(userId, personaId);
  }

  /// Checks if a persona is premium-only.
  bool isPremiumPersona(Persona persona) {
    return persona.isPremium;
  }

  /// Filters personas to only include premium ones.
  List<Persona> getPremiumPersonas(List<Persona> personas) {
    return personas.where((p) => p.isPremium).toList();
  }

  /// Filters personas to only include free ones.
  List<Persona> getFreePersonas(List<Persona> personas) {
    return personas.where((p) => !p.isPremium).toList();
  }

  /// Streams the active persona for real-time updates.
  Stream<Persona?> watchActivePersona(String userId) {
    return _repository.watchActivePersona(userId);
  }

  String _toneToString(PersonaTone tone) {
    switch (tone) {
      case PersonaTone.formal:
        return 'Formal - Professional and structured communication';
      case PersonaTone.casual:
        return 'Casual - Relaxed and conversational communication';
      case PersonaTone.professional:
        return 'Professional - Business-appropriate communication';
      case PersonaTone.friendly:
        return 'Friendly - Warm and approachable communication';
      case PersonaTone.assertive:
        return 'Assertive - Direct and confident communication';
      case PersonaTone.diplomatic:
        return 'Diplomatic - Tactful and balanced communication';
    }
  }

  String _styleToString(PersonaStyle style) {
    switch (style) {
      case PersonaStyle.concise:
        return 'Concise - Brief and to-the-point responses';
      case PersonaStyle.detailed:
        return 'Detailed - Comprehensive and thorough responses';
      case PersonaStyle.technical:
        return 'Technical - Precise and specialized terminology';
      case PersonaStyle.plainEnglish:
        return 'Plain English - Simple and accessible language';
    }
  }

  String _languageToString(String code) {
    const languages = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
    };
    return languages[code] ?? code.toUpperCase();
  }

  List<RedFlag> _parseRedFlagsResponse(String response) {
    final redFlags = <RedFlag>[];
    final sections = response.split(RegExp(r'\n(?=\d+\.)'));

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i].trim();
      if (section.isEmpty) continue;

      String? originalText;
      String? explanation;
      String severity = 'medium';

      final lines = section.split('\n');
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;

        if (trimmedLine.toLowerCase().contains('text:') ||
            trimmedLine.toLowerCase().contains('clause:')) {
          originalText = trimmedLine.replaceFirst(
            RegExp(r'^(text|clause):\s*', caseSensitive: false),
            '',
          );
        } else if (trimmedLine.toLowerCase().contains('explanation:') ||
            trimmedLine.toLowerCase().contains('why:') ||
            trimmedLine.toLowerCase().contains('reason:')) {
          explanation = trimmedLine.replaceFirst(
            RegExp(r'^(explanation|why|reason):\s*', caseSensitive: false),
            '',
          );
        } else if (trimmedLine.toLowerCase().contains('severity:')) {
          final severityMatch =
              RegExp(r'(low|medium|high|critical)', caseSensitive: false)
                  .firstMatch(trimmedLine);
          if (severityMatch != null) {
            severity = severityMatch.group(1)!.toLowerCase();
          }
        }
      }

      if (originalText != null && originalText.isNotEmpty) {
        redFlags.add(RedFlag(
          id: 'red-flag-${DateTime.now().millisecondsSinceEpoch}-$i',
          originalText: originalText,
          explanation: explanation ?? 'Potential issue identified in document.',
          severity: severity,
          startPosition: 0,
          endPosition: originalText.length,
        ));
      }
    }

    return redFlags;
  }
}
