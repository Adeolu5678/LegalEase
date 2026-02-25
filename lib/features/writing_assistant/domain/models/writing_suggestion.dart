enum SuggestionType {
  clarity,
  legalAccuracy,
  toneAdjustment,
  riskReduction,
}

class WritingSuggestion {
  final String id;
  final SuggestionType type;
  final String originalText;
  final String suggestedText;
  final String explanation;
  final int startPosition;
  final int endPosition;
  final double confidence;

  const WritingSuggestion({
    required this.id,
    required this.type,
    required this.originalText,
    required this.suggestedText,
    required this.explanation,
    required this.startPosition,
    required this.endPosition,
    required this.confidence,
  });

  factory WritingSuggestion.fromJson(Map<String, dynamic> json) {
    return WritingSuggestion(
      id: json['id'] as String? ?? '',
      type: SuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SuggestionType.clarity,
      ),
      originalText: json['originalText'] as String? ?? '',
      suggestedText: json['suggestedText'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      startPosition: json['startPosition'] as int? ?? 0,
      endPosition: json['endPosition'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'originalText': originalText,
      'suggestedText': suggestedText,
      'explanation': explanation,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'confidence': confidence,
    };
  }

  WritingSuggestion copyWith({
    String? id,
    SuggestionType? type,
    String? originalText,
    String? suggestedText,
    String? explanation,
    int? startPosition,
    int? endPosition,
    double? confidence,
  }) {
    return WritingSuggestion(
      id: id ?? this.id,
      type: type ?? this.type,
      originalText: originalText ?? this.originalText,
      suggestedText: suggestedText ?? this.suggestedText,
      explanation: explanation ?? this.explanation,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      confidence: confidence ?? this.confidence,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case SuggestionType.clarity:
        return 'Clarity';
      case SuggestionType.legalAccuracy:
        return 'Legal Accuracy';
      case SuggestionType.toneAdjustment:
        return 'Tone';
      case SuggestionType.riskReduction:
        return 'Risk Reduction';
    }
  }

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.5;
}
