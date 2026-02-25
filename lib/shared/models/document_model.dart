import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

enum DocumentType {
  contract,
  lease,
  termsConditions,
  privacyPolicy,
  eula,
  other,
}

@freezed
class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    required String userId,
    required String title,
    required DocumentType type,
    required String originalText,
    String? summary,
    List<RedFlag>? redFlags,
    String? plainEnglishTranslation,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);
}

@freezed
class RedFlag with _$RedFlag {
  const factory RedFlag({
    required String id,
    required String originalText,
    required String explanation,
    required String severity,
    required int startPosition,
    required int endPosition,
    @Default(0.8) double confidenceScore,
  }) = _RedFlag;

  factory RedFlag.fromJson(Map<String, dynamic> json) =>
      _$RedFlagFromJson(json);
}
