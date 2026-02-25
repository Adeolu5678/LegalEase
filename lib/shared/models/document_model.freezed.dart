// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) {
  return _DocumentModel.fromJson(json);
}

/// @nodoc
mixin _$DocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DocumentType get type => throw _privateConstructorUsedError;
  String get originalText => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  List<RedFlag>? get redFlags => throw _privateConstructorUsedError;
  String? get plainEnglishTranslation => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentModelCopyWith<DocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentModelCopyWith<$Res> {
  factory $DocumentModelCopyWith(
          DocumentModel value, $Res Function(DocumentModel) then) =
      _$DocumentModelCopyWithImpl<$Res, DocumentModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      DocumentType type,
      String originalText,
      String? summary,
      List<RedFlag>? redFlags,
      String? plainEnglishTranslation,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DocumentModelCopyWithImpl<$Res, $Val extends DocumentModel>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? type = null,
    Object? originalText = null,
    Object? summary = freezed,
    Object? redFlags = freezed,
    Object? plainEnglishTranslation = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      redFlags: freezed == redFlags
          ? _value.redFlags
          : redFlags // ignore: cast_nullable_to_non_nullable
              as List<RedFlag>?,
      plainEnglishTranslation: freezed == plainEnglishTranslation
          ? _value.plainEnglishTranslation
          : plainEnglishTranslation // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentModelImplCopyWith<$Res>
    implements $DocumentModelCopyWith<$Res> {
  factory _$$DocumentModelImplCopyWith(
          _$DocumentModelImpl value, $Res Function(_$DocumentModelImpl) then) =
      __$$DocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      DocumentType type,
      String originalText,
      String? summary,
      List<RedFlag>? redFlags,
      String? plainEnglishTranslation,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$DocumentModelImplCopyWithImpl<$Res>
    extends _$DocumentModelCopyWithImpl<$Res, _$DocumentModelImpl>
    implements _$$DocumentModelImplCopyWith<$Res> {
  __$$DocumentModelImplCopyWithImpl(
      _$DocumentModelImpl _value, $Res Function(_$DocumentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? type = null,
    Object? originalText = null,
    Object? summary = freezed,
    Object? redFlags = freezed,
    Object? plainEnglishTranslation = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DocumentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as DocumentType,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String?,
      redFlags: freezed == redFlags
          ? _value._redFlags
          : redFlags // ignore: cast_nullable_to_non_nullable
              as List<RedFlag>?,
      plainEnglishTranslation: freezed == plainEnglishTranslation
          ? _value.plainEnglishTranslation
          : plainEnglishTranslation // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentModelImpl implements _DocumentModel {
  const _$DocumentModelImpl(
      {required this.id,
      required this.userId,
      required this.title,
      required this.type,
      required this.originalText,
      this.summary,
      final List<RedFlag>? redFlags,
      this.plainEnglishTranslation,
      required this.createdAt,
      this.updatedAt})
      : _redFlags = redFlags;

  factory _$DocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final DocumentType type;
  @override
  final String originalText;
  @override
  final String? summary;
  final List<RedFlag>? _redFlags;
  @override
  List<RedFlag>? get redFlags {
    final value = _redFlags;
    if (value == null) return null;
    if (_redFlags is EqualUnmodifiableListView) return _redFlags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? plainEnglishTranslation;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DocumentModel(id: $id, userId: $userId, title: $title, type: $type, originalText: $originalText, summary: $summary, redFlags: $redFlags, plainEnglishTranslation: $plainEnglishTranslation, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.originalText, originalText) ||
                other.originalText == originalText) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._redFlags, _redFlags) &&
            (identical(
                    other.plainEnglishTranslation, plainEnglishTranslation) ||
                other.plainEnglishTranslation == plainEnglishTranslation) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      type,
      originalText,
      summary,
      const DeepCollectionEquality().hash(_redFlags),
      plainEnglishTranslation,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      __$$DocumentModelImplCopyWithImpl<_$DocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentModelImplToJson(
      this,
    );
  }
}

abstract class _DocumentModel implements DocumentModel {
  const factory _DocumentModel(
      {required final String id,
      required final String userId,
      required final String title,
      required final DocumentType type,
      required final String originalText,
      final String? summary,
      final List<RedFlag>? redFlags,
      final String? plainEnglishTranslation,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$DocumentModelImpl;

  factory _DocumentModel.fromJson(Map<String, dynamic> json) =
      _$DocumentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  DocumentType get type;
  @override
  String get originalText;
  @override
  String? get summary;
  @override
  List<RedFlag>? get redFlags;
  @override
  String? get plainEnglishTranslation;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RedFlag _$RedFlagFromJson(Map<String, dynamic> json) {
  return _RedFlag.fromJson(json);
}

/// @nodoc
mixin _$RedFlag {
  String get id => throw _privateConstructorUsedError;
  String get originalText => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  int get startPosition => throw _privateConstructorUsedError;
  int get endPosition => throw _privateConstructorUsedError;
  double get confidenceScore => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RedFlagCopyWith<RedFlag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedFlagCopyWith<$Res> {
  factory $RedFlagCopyWith(RedFlag value, $Res Function(RedFlag) then) =
      _$RedFlagCopyWithImpl<$Res, RedFlag>;
  @useResult
  $Res call(
      {String id,
      String originalText,
      String explanation,
      String severity,
      int startPosition,
      int endPosition,
      double confidenceScore});
}

/// @nodoc
class _$RedFlagCopyWithImpl<$Res, $Val extends RedFlag>
    implements $RedFlagCopyWith<$Res> {
  _$RedFlagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? explanation = null,
    Object? severity = null,
    Object? startPosition = null,
    Object? endPosition = null,
    Object? confidenceScore = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      startPosition: null == startPosition
          ? _value.startPosition
          : startPosition // ignore: cast_nullable_to_non_nullable
              as int,
      endPosition: null == endPosition
          ? _value.endPosition
          : endPosition // ignore: cast_nullable_to_non_nullable
              as int,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedFlagImplCopyWith<$Res> implements $RedFlagCopyWith<$Res> {
  factory _$$RedFlagImplCopyWith(
          _$RedFlagImpl value, $Res Function(_$RedFlagImpl) then) =
      __$$RedFlagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String originalText,
      String explanation,
      String severity,
      int startPosition,
      int endPosition,
      double confidenceScore});
}

/// @nodoc
class __$$RedFlagImplCopyWithImpl<$Res>
    extends _$RedFlagCopyWithImpl<$Res, _$RedFlagImpl>
    implements _$$RedFlagImplCopyWith<$Res> {
  __$$RedFlagImplCopyWithImpl(
      _$RedFlagImpl _value, $Res Function(_$RedFlagImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? originalText = null,
    Object? explanation = null,
    Object? severity = null,
    Object? startPosition = null,
    Object? endPosition = null,
    Object? confidenceScore = null,
  }) {
    return _then(_$RedFlagImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      originalText: null == originalText
          ? _value.originalText
          : originalText // ignore: cast_nullable_to_non_nullable
              as String,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      startPosition: null == startPosition
          ? _value.startPosition
          : startPosition // ignore: cast_nullable_to_non_nullable
              as int,
      endPosition: null == endPosition
          ? _value.endPosition
          : endPosition // ignore: cast_nullable_to_non_nullable
              as int,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedFlagImpl implements _RedFlag {
  const _$RedFlagImpl(
      {required this.id,
      required this.originalText,
      required this.explanation,
      required this.severity,
      required this.startPosition,
      required this.endPosition,
      this.confidenceScore = 0.8});

  factory _$RedFlagImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedFlagImplFromJson(json);

  @override
  final String id;
  @override
  final String originalText;
  @override
  final String explanation;
  @override
  final String severity;
  @override
  final int startPosition;
  @override
  final int endPosition;
  @override
  @JsonKey()
  final double confidenceScore;

  @override
  String toString() {
    return 'RedFlag(id: $id, originalText: $originalText, explanation: $explanation, severity: $severity, startPosition: $startPosition, endPosition: $endPosition, confidenceScore: $confidenceScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedFlagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalText, originalText) ||
                other.originalText == originalText) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.startPosition, startPosition) ||
                other.startPosition == startPosition) &&
            (identical(other.endPosition, endPosition) ||
                other.endPosition == endPosition) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, originalText, explanation,
      severity, startPosition, endPosition, confidenceScore);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RedFlagImplCopyWith<_$RedFlagImpl> get copyWith =>
      __$$RedFlagImplCopyWithImpl<_$RedFlagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedFlagImplToJson(
      this,
    );
  }
}

abstract class _RedFlag implements RedFlag {
  const factory _RedFlag(
      {required final String id,
      required final String originalText,
      required final String explanation,
      required final String severity,
      required final int startPosition,
      required final int endPosition,
      final double confidenceScore}) = _$RedFlagImpl;

  factory _RedFlag.fromJson(Map<String, dynamic> json) = _$RedFlagImpl.fromJson;

  @override
  String get id;
  @override
  String get originalText;
  @override
  String get explanation;
  @override
  String get severity;
  @override
  int get startPosition;
  @override
  int get endPosition;
  @override
  double get confidenceScore;
  @override
  @JsonKey(ignore: true)
  _$$RedFlagImplCopyWith<_$RedFlagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
