import 'package:equatable/equatable.dart';

enum TemplateCategory {
  contracts,
  employment,
  intellectualProperty,
  realEstate,
  corporate,
  privacy,
  general,
}

enum TemplateField {
  text,
  number,
  date,
  email,
  phone,
  address,
  currency,
  percentage,
  selection,
  multilineText,
}

class TemplateFieldDefinition extends Equatable {
  final String id;
  final String label;
  final String placeholder;
  final TemplateField type;
  final bool required;
  final String? defaultValue;
  final List<String>? options;
  final String? validationRegex;

  const TemplateFieldDefinition({
    required this.id,
    required this.label,
    this.placeholder = '',
    this.type = TemplateField.text,
    this.required = true,
    this.defaultValue,
    this.options,
    this.validationRegex,
  });

  @override
  List<Object?> get props => [id, label, placeholder, type, required, defaultValue, options, validationRegex];
}

class LegalTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final TemplateCategory category;
  final String content;
  final List<TemplateFieldDefinition> fields;
  final List<String> tags;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LegalTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.content,
    this.fields = const [],
    this.tags = const [],
    this.isPremium = false,
    required this.createdAt,
    this.updatedAt,
  });

  String get categoryName {
    switch (category) {
      case TemplateCategory.contracts:
        return 'Contracts';
      case TemplateCategory.employment:
        return 'Employment';
      case TemplateCategory.intellectualProperty:
        return 'Intellectual Property';
      case TemplateCategory.realEstate:
        return 'Real Estate';
      case TemplateCategory.corporate:
        return 'Corporate';
      case TemplateCategory.privacy:
        return 'Privacy';
      case TemplateCategory.general:
        return 'General';
    }
  }

  LegalTemplate copyWith({
    String? id,
    String? name,
    String? description,
    TemplateCategory? category,
    String? content,
    List<TemplateFieldDefinition>? fields,
    List<String>? tags,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LegalTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      content: content ?? this.content,
      fields: fields ?? this.fields,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String fillTemplate(Map<String, dynamic> values) {
    var filledContent = content;
    for (final field in fields) {
      final value = values[field.id] ?? field.defaultValue ?? '';
      filledContent = filledContent.replaceAll('{{${field.id}}}', value.toString());
    }
    return filledContent;
  }

  @override
  List<Object?> get props => [id, name, description, category, content, fields, tags, isPremium, createdAt, updatedAt];
}
