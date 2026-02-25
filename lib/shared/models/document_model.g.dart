// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentModelImpl _$$DocumentModelImplFromJson(Map<String, dynamic> json) =>
    _$DocumentModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
      originalText: json['originalText'] as String,
      summary: json['summary'] as String?,
      redFlags: (json['redFlags'] as List<dynamic>?)
          ?.map((e) => RedFlag.fromJson(e as Map<String, dynamic>))
          .toList(),
      plainEnglishTranslation: json['plainEnglishTranslation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DocumentModelImplToJson(_$DocumentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'originalText': instance.originalText,
      'summary': instance.summary,
      'redFlags': instance.redFlags,
      'plainEnglishTranslation': instance.plainEnglishTranslation,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.contract: 'contract',
  DocumentType.lease: 'lease',
  DocumentType.termsConditions: 'termsConditions',
  DocumentType.privacyPolicy: 'privacyPolicy',
  DocumentType.eula: 'eula',
  DocumentType.other: 'other',
};

_$RedFlagImpl _$$RedFlagImplFromJson(Map<String, dynamic> json) =>
    _$RedFlagImpl(
      id: json['id'] as String,
      originalText: json['originalText'] as String,
      explanation: json['explanation'] as String,
      severity: json['severity'] as String,
      startPosition: (json['startPosition'] as num).toInt(),
      endPosition: (json['endPosition'] as num).toInt(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.8,
    );

Map<String, dynamic> _$$RedFlagImplToJson(_$RedFlagImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalText': instance.originalText,
      'explanation': instance.explanation,
      'severity': instance.severity,
      'startPosition': instance.startPosition,
      'endPosition': instance.endPosition,
      'confidenceScore': instance.confidenceScore,
    };
