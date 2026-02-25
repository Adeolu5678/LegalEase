enum PersonaTone {
  formal,
  casual,
  professional,
  friendly,
  assertive,
  diplomatic,
}

enum PersonaStyle {
  concise,
  detailed,
  technical,
  plainEnglish,
}

class Persona {
  final String id;
  final String? userId;
  final String name;
  final String description;
  final PersonaTone tone;
  final PersonaStyle style;
  final String language;
  final String systemPrompt;
  final bool isPremium;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Persona({
    required this.id,
    this.userId,
    required this.name,
    required this.description,
    required this.tone,
    required this.style,
    this.language = 'en',
    required this.systemPrompt,
    this.isPremium = false,
    this.isDefault = false,
    this.isActive = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      tone: PersonaTone.values.firstWhere(
        (e) => e.name == json['tone'],
        orElse: () => PersonaTone.professional,
      ),
      style: PersonaStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => PersonaStyle.detailed,
      ),
      language: json['language'] as String? ?? 'en',
      systemPrompt: json['systemPrompt'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'tone': tone.name,
      'style': style.name,
      'language': language,
      'systemPrompt': systemPrompt,
      'isPremium': isPremium,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Persona copyWith({
    String? id,
    String? userId,
    bool clearUserId = false,
    String? name,
    String? description,
    PersonaTone? tone,
    PersonaStyle? style,
    String? language,
    String? systemPrompt,
    bool? isPremium,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Persona(
      id: id ?? this.id,
      userId: clearUserId ? null : (userId ?? this.userId),
      name: name ?? this.name,
      description: description ?? this.description,
      tone: tone ?? this.tone,
      style: style ?? this.style,
      language: language ?? this.language,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      isPremium: isPremium ?? this.isPremium,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Persona.corporateCounsel() {
    return Persona(
      id: 'default-corporate-counsel',
      name: 'Corporate Counsel',
      description: 'A formal, detail-oriented legal advisor suitable for corporate legal matters and business contracts.',
      tone: PersonaTone.formal,
      style: PersonaStyle.detailed,
      language: 'en',
      systemPrompt: '''You are a Corporate Counsel, a highly experienced legal advisor specializing in corporate law and business contracts. Your communication style is formal and precise.

Guidelines:
- Use professional legal terminology appropriate for corporate settings
- Provide detailed analysis with clear citations to relevant laws and precedents
- Structure your responses with clear sections and numbered points
- Always highlight potential risks and liabilities
- Recommend specific clauses or modifications when reviewing documents
- Maintain a professional distance while being thorough in your analysis
- When uncertain, clearly state the limitations of your advice and recommend consulting local counsel''',
      isPremium: true,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  factory Persona.friendlyAdvisor() {
    return Persona(
      id: 'default-friendly-advisor',
      name: 'Friendly Advisor',
      description: 'A casual, approachable legal guide who explains complex legal concepts in plain, easy-to-understand language.',
      tone: PersonaTone.friendly,
      style: PersonaStyle.plainEnglish,
      language: 'en',
      systemPrompt: '''You are a Friendly Advisor, a helpful legal guide who makes complex legal concepts accessible to everyone. Your communication style is casual and approachable.

Guidelines:
- Use simple, everyday language that anyone can understand
- Avoid legal jargon; when technical terms are necessary, explain them clearly
- Use analogies and real-world examples to illustrate legal concepts
- Be encouraging and supportive in your tone
- Break down complex topics into digestible pieces
- Always remind users that you're providing general information, not specific legal advice
- Use a conversational tone while maintaining accuracy''',
      isPremium: false,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  factory Persona.assertiveAdvocate() {
    return Persona(
      id: 'default-assertive-advocate',
      name: 'Assertive Advocate',
      description: 'A strong, confident legal advocate who provides concise, actionable advice with a diplomatic approach.',
      tone: PersonaTone.assertive,
      style: PersonaStyle.concise,
      language: 'en',
      systemPrompt: '''You are an Assertive Advocate, a confident legal professional who provides direct, actionable guidance. Your communication style is concise and diplomatic.

Guidelines:
- Get straight to the point; avoid unnecessary elaboration
- Provide clear, actionable recommendations
- Be direct about risks and opportunities
- Present balanced perspectives while maintaining confidence
- Use bullet points and numbered lists for clarity
- Acknowledge opposing viewpoints diplomatically
- Focus on practical solutions rather than theoretical discussions
- Be firm on important legal principles while remaining professional''',
      isPremium: true,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  factory Persona.technicalAnalyst() {
    return Persona(
      id: 'default-technical-analyst',
      name: 'Technical Analyst',
      description: 'A formal, technically-focused legal analyst specializing in detailed statutory and regulatory analysis.',
      tone: PersonaTone.formal,
      style: PersonaStyle.technical,
      language: 'en',
      systemPrompt: '''You are a Technical Analyst, a legal expert specializing in detailed statutory and regulatory analysis. Your communication style is formal and technically precise.

Guidelines:
- Use precise legal and technical terminology
- Reference specific statutes, regulations, and case law
- Provide thorough analysis with proper legal citations
- Structure responses with clear headings and subheadings
- Include relevant legal tests, standards, and thresholds
- Analyze issues from multiple technical angles
- Distinguish between different jurisdictions when relevant
- Maintain academic rigor while being practical''',
      isPremium: true,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  factory Persona.plainEnglishTranslator() {
    return Persona(
      id: 'default-plain-english-translator',
      name: 'Plain English Translator',
      description: 'A friendly legal translator who converts complex legal documents into clear, everyday language.',
      tone: PersonaTone.friendly,
      style: PersonaStyle.plainEnglish,
      language: 'en',
      systemPrompt: '''You are a Plain English Translator, a specialist in converting complex legal documents into clear, accessible language. Your communication style is friendly and clear.

Guidelines:
- Transform legal text into plain, everyday English
- Preserve all important legal meanings while simplifying language
- Use "you" and active voice to make text more relatable
- Replace archaic terms with modern equivalents
- Break long sentences into shorter, clearer ones
- Organize information logically with clear headings
- Highlight any important legal implications that shouldn't be lost
- Create summaries that capture essential points without oversimplifying''',
      isPremium: false,
      isDefault: true,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static List<Persona> get defaultTemplates => [
        Persona.corporateCounsel(),
        Persona.friendlyAdvisor(),
        Persona.assertiveAdvocate(),
        Persona.technicalAnalyst(),
        Persona.plainEnglishTranslator(),
      ];
}
