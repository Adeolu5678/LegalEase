import 'package:equatable/equatable.dart';

enum LegalTermCategory {
  contract,
  tort,
  property,
  criminal,
  constitutional,
  civilProcedure,
  evidence,
  family,
  corporate,
  intellectualProperty,
  tax,
  employment,
  realEstate,
  general,
}

extension LegalTermCategoryExtension on LegalTermCategory {
  String get label {
    return switch (this) {
      LegalTermCategory.contract => 'Contract Law',
      LegalTermCategory.tort => 'Tort Law',
      LegalTermCategory.property => 'Property Law',
      LegalTermCategory.criminal => 'Criminal Law',
      LegalTermCategory.constitutional => 'Constitutional Law',
      LegalTermCategory.civilProcedure => 'Civil Procedure',
      LegalTermCategory.evidence => 'Evidence',
      LegalTermCategory.family => 'Family Law',
      LegalTermCategory.corporate => 'Corporate Law',
      LegalTermCategory.intellectualProperty => 'Intellectual Property',
      LegalTermCategory.tax => 'Tax Law',
      LegalTermCategory.employment => 'Employment Law',
      LegalTermCategory.realEstate => 'Real Estate',
      LegalTermCategory.general => 'General',
    };
  }
}

class LegalTerm extends Equatable {
  final String id;
  final String term;
  final String definition;
  final String? phonetic;
  final List<String> synonyms;
  final List<String> relatedTerms;
  final LegalTermCategory category;
  final List<String> examples;
  final String? etymology;
  final bool isCommonTerm;

  const LegalTerm({
    required this.id,
    required this.term,
    required this.definition,
    this.phonetic,
    this.synonyms = const [],
    this.relatedTerms = const [],
    this.category = LegalTermCategory.general,
    this.examples = const [],
    this.etymology,
    this.isCommonTerm = false,
  });

  String get categoryLabel => category.label;

  LegalTerm copyWith({
    String? id,
    String? term,
    String? definition,
    String? phonetic,
    List<String>? synonyms,
    List<String>? relatedTerms,
    LegalTermCategory? category,
    List<String>? examples,
    String? etymology,
    bool? isCommonTerm,
  }) {
    return LegalTerm(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      phonetic: phonetic ?? this.phonetic,
      synonyms: synonyms ?? this.synonyms,
      relatedTerms: relatedTerms ?? this.relatedTerms,
      category: category ?? this.category,
      examples: examples ?? this.examples,
      etymology: etymology ?? this.etymology,
      isCommonTerm: isCommonTerm ?? this.isCommonTerm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'definition': definition,
      'phonetic': phonetic,
      'synonyms': synonyms,
      'relatedTerms': relatedTerms,
      'category': category.name,
      'examples': examples,
      'etymology': etymology,
      'isCommonTerm': isCommonTerm,
    };
  }

  factory LegalTerm.fromJson(Map<String, dynamic> json) {
    return LegalTerm(
      id: json['id'] as String,
      term: json['term'] as String,
      definition: json['definition'] as String,
      phonetic: json['phonetic'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      relatedTerms: (json['relatedTerms'] as List<dynamic>?)?.cast<String>() ?? [],
      category: LegalTermCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => LegalTermCategory.general,
      ),
      examples: (json['examples'] as List<dynamic>?)?.cast<String>() ?? [],
      etymology: json['etymology'] as String?,
      isCommonTerm: json['isCommonTerm'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        term,
        definition,
        phonetic,
        synonyms,
        relatedTerms,
        category,
        examples,
        etymology,
        isCommonTerm,
      ];
}
