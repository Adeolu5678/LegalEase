import 'dart:convert';
import 'package:legalease/features/writing_assistant/domain/models/writing_suggestion.dart';
import 'package:legalease/shared/services/ai/ai_service.dart';

class WritingAssistantService {
  final AiService _aiService;

  WritingAssistantService({required AiService aiService}) : _aiService = aiService;

  Future<List<WritingSuggestion>> analyzeText(String text) async {
    if (text.trim().isEmpty) return [];

    final prompt = _buildAnalysisPrompt(text);
    
    try {
      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 2048,
      );
      
      return _parseSuggestions(response, text);
    } catch (e) {
      return [];
    }
  }

  Future<WritingSuggestion?> getSuggestionForRange(
    String text,
    int startPosition,
    int endPosition,
  ) async {
    if (startPosition < 0 || endPosition > text.length || startPosition >= endPosition) {
      return null;
    }

    final selectedText = text.substring(startPosition, endPosition);
    final prompt = _buildSingleSuggestionPrompt(selectedText, text);

    try {
      final response = await _aiService.generateText(
        prompt: prompt,
        maxTokens: 512,
      );
      
      final suggestions = _parseSuggestions(response, text);
      if (suggestions.isNotEmpty) {
        return suggestions.first.copyWith(
          startPosition: startPosition,
          endPosition: endPosition,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String applySuggestion(String originalText, WritingSuggestion suggestion) {
    if (suggestion.startPosition < 0 || 
        suggestion.endPosition > originalText.length ||
        suggestion.startPosition >= suggestion.endPosition) {
      return originalText;
    }

    final before = originalText.substring(0, suggestion.startPosition);
    final after = originalText.substring(suggestion.endPosition);
    
    return '$before${suggestion.suggestedText}$after';
  }

  String _buildAnalysisPrompt(String text) {
    return '''
Analyze the following legal text and provide suggestions for improvement. Focus on:
1. Clarity: Suggestions to make the text clearer and more understandable
2. Legal Accuracy: Suggestions to ensure legal terminology is used correctly
3. Tone Adjustment: Suggestions to maintain appropriate professional/legal tone
4. Risk Reduction: Suggestions to reduce potential legal risks or ambiguities

Text to analyze:
"""
$text
"""

Provide suggestions in the following JSON format:
{
  "suggestions": [
    {
      "type": "clarity|legalAccuracy|toneAdjustment|riskReduction",
      "originalText": "the exact text to be replaced",
      "suggestedText": "the suggested replacement",
      "explanation": "brief explanation of why this change is recommended",
      "confidence": 0.0-1.0
    }
  ]
}

Only include suggestions that would genuinely improve the text. If no improvements are needed, return an empty suggestions array.
''';
  }

  String _buildSingleSuggestionPrompt(String selectedText, String fullContext) {
    return '''
Analyze the following selected text within its context and provide improvement suggestions.

Full context:
"""
$fullContext
"""

Selected text to analyze:
"""
$selectedText
"""

Provide a suggestion in the following JSON format:
{
  "suggestions": [
    {
      "type": "clarity|legalAccuracy|toneAdjustment|riskReduction",
      "originalText": "$selectedText",
      "suggestedText": "the suggested replacement",
      "explanation": "brief explanation",
      "confidence": 0.0-1.0
    }
  ]
}

If the selected text is already optimal, return an empty suggestions array.
''';
  }

  List<WritingSuggestion> _parseSuggestions(String response, String originalText) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch == null) return [];

      final json = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
      final suggestionsList = json['suggestions'] as List? ?? [];

      return suggestionsList.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value as Map<String, dynamic>;
        
        final original = data['originalText'] as String? ?? '';
        final position = _findTextPosition(originalText, original);
        
        return WritingSuggestion(
          id: 'suggestion_$index',
          type: _parseSuggestionType(data['type'] as String?),
          originalText: original,
          suggestedText: data['suggestedText'] as String? ?? '',
          explanation: data['explanation'] as String? ?? '',
          startPosition: position.start,
          endPosition: position.end,
          confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  SuggestionType _parseSuggestionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'clarity':
        return SuggestionType.clarity;
      case 'legalaccuracy':
        return SuggestionType.legalAccuracy;
      case 'toneadjustment':
        return SuggestionType.toneAdjustment;
      case 'riskreduction':
        return SuggestionType.riskReduction;
      default:
        return SuggestionType.clarity;
    }
  }

  ({int start, int end}) _findTextPosition(String fullText, String searchText) {
    if (searchText.isEmpty) return (start: 0, end: 0);
    
    final index = fullText.indexOf(searchText);
    if (index == -1) return (start: 0, end: 0);
    
    return (start: index, end: index + searchText.length);
  }
}
