import 'package:equatable/equatable.dart';

enum AnalysisStatus { pending, processing, completed, failed }

enum RedFlagSeverity { critical, warning, info }

enum ConfidenceLevel { high, medium, low }

enum DocumentType {
  contract,
  lease,
  termsConditions,
  privacyPolicy,
  eula,
  nda,
  employment,
  other,
}

class AnalysisResult extends Equatable {
  final String documentId;
  final String originalText;
  final String plainEnglishTranslation;
  final String summary;
  final List<RedFlagItem> redFlags;
  final DocumentMetadata metadata;
  final AnalysisStatus status;
  final DateTime analyzedAt;
  final String? errorMessage;

  const AnalysisResult({
    required this.documentId,
    required this.originalText,
    this.plainEnglishTranslation = '',
    this.summary = '',
    this.redFlags = const [],
    required this.metadata,
    this.status = AnalysisStatus.pending,
    required this.analyzedAt,
    this.errorMessage,
  });

  bool get isCompleted => status == AnalysisStatus.completed;
  bool get isFailed => status == AnalysisStatus.failed;
  bool get isProcessing => status == AnalysisStatus.processing;
  bool get isPending => status == AnalysisStatus.pending;
  bool get hasRedFlags => redFlags.isNotEmpty;
  bool get hasCriticalFlags => redFlags.any((f) => f.severity == RedFlagSeverity.critical);
  bool get hasWarnings => redFlags.any((f) => f.severity == RedFlagSeverity.warning);

  int get criticalCount => redFlags.where((f) => f.severity == RedFlagSeverity.critical).length;
  int get warningCount => redFlags.where((f) => f.severity == RedFlagSeverity.warning).length;
  int get infoCount => redFlags.where((f) => f.severity == RedFlagSeverity.info).length;

  AnalysisResult copyWith({
    String? documentId,
    String? originalText,
    String? plainEnglishTranslation,
    String? summary,
    List<RedFlagItem>? redFlags,
    DocumentMetadata? metadata,
    AnalysisStatus? status,
    DateTime? analyzedAt,
    String? errorMessage,
  }) {
    return AnalysisResult(
      documentId: documentId ?? this.documentId,
      originalText: originalText ?? this.originalText,
      plainEnglishTranslation: plainEnglishTranslation ?? this.plainEnglishTranslation,
      summary: summary ?? this.summary,
      redFlags: redFlags ?? this.redFlags,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'originalText': originalText,
      'plainEnglishTranslation': plainEnglishTranslation,
      'summary': summary,
      'redFlags': redFlags.map((f) => f.toJson()).toList(),
      'metadata': metadata.toJson(),
      'status': status.name,
      'analyzedAt': analyzedAt.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      documentId: json['documentId'] as String,
      originalText: json['originalText'] as String,
      plainEnglishTranslation: json['plainEnglishTranslation'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      redFlags: (json['redFlags'] as List?)
              ?.map((f) => RedFlagItem.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      metadata: DocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      status: AnalysisStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AnalysisStatus.pending,
      ),
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        documentId,
        originalText,
        plainEnglishTranslation,
        summary,
        redFlags,
        metadata,
        status,
        analyzedAt,
        errorMessage,
      ];
}

class RedFlagItem extends Equatable {
  final String id;
  final String originalClause;
  final String explanation;
  final RedFlagSeverity severity;
  final int startIndex;
  final int endIndex;
  final double confidenceScore;

  const RedFlagItem({
    required this.id,
    required this.originalClause,
    required this.explanation,
    required this.severity,
    required this.startIndex,
    required this.endIndex,
    this.confidenceScore = 0.8,
  });

  bool get isCritical => severity == RedFlagSeverity.critical;
  bool get isWarning => severity == RedFlagSeverity.warning;
  bool get isInfo => severity == RedFlagSeverity.info;
  int get length => endIndex - startIndex;
  
  ConfidenceLevel get confidenceLevel {
    if (confidenceScore >= 0.8) return ConfidenceLevel.high;
    if (confidenceScore >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  String get severityLabel {
    switch (severity) {
      case RedFlagSeverity.critical:
        return 'Critical';
      case RedFlagSeverity.warning:
        return 'Warning';
      case RedFlagSeverity.info:
        return 'Info';
    }
  }

  RedFlagItem copyWith({
    String? id,
    String? originalClause,
    String? explanation,
    RedFlagSeverity? severity,
    int? startIndex,
    int? endIndex,
    double? confidenceScore,
  }) {
    return RedFlagItem(
      id: id ?? this.id,
      originalClause: originalClause ?? this.originalClause,
      explanation: explanation ?? this.explanation,
      severity: severity ?? this.severity,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalClause': originalClause,
      'explanation': explanation,
      'severity': severity.name,
      'startIndex': startIndex,
      'endIndex': endIndex,
      'confidenceScore': confidenceScore,
    };
  }

  factory RedFlagItem.fromJson(Map<String, dynamic> json) {
    return RedFlagItem(
      id: json['id'] as String,
      originalClause: json['originalClause'] as String,
      explanation: json['explanation'] as String,
      severity: RedFlagSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => RedFlagSeverity.info,
      ),
      startIndex: json['startIndex'] as int,
      endIndex: json['endIndex'] as int,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.8,
    );
  }

  factory RedFlagItem.fromRedFlag(Map<String, dynamic> json) {
    return RedFlagItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      originalClause: json['originalText'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      severity: _parseSeverity(json['severity'] as String?),
      startIndex: json['startPosition'] as int? ?? 0,
      endIndex: json['endPosition'] as int? ?? 0,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.8,
    );
  }

  static RedFlagSeverity _parseSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
      case 'high':
        return RedFlagSeverity.critical;
      case 'warning':
      case 'medium':
        return RedFlagSeverity.warning;
      case 'info':
      case 'low':
      default:
        return RedFlagSeverity.info;
    }
  }

  @override
  List<Object?> get props => [id, originalClause, explanation, severity, startIndex, endIndex, confidenceScore];
}

class DocumentMetadata extends Equatable {
  final String? fileName;
  final int pageCount;
  final int wordCount;
  final int characterCount;
  final DocumentType type;
  final Duration processingTime;
  final double confidence;

  const DocumentMetadata({
    this.fileName,
    this.pageCount = 1,
    this.wordCount = 0,
    this.characterCount = 0,
    this.type = DocumentType.other,
    this.processingTime = Duration.zero,
    this.confidence = 0.0,
  });

  String get typeName {
    switch (type) {
      case DocumentType.contract:
        return 'Contract';
      case DocumentType.lease:
        return 'Lease Agreement';
      case DocumentType.termsConditions:
        return 'Terms & Conditions';
      case DocumentType.privacyPolicy:
        return 'Privacy Policy';
      case DocumentType.eula:
        return 'End User License Agreement';
      case DocumentType.nda:
        return 'Non-Disclosure Agreement';
      case DocumentType.employment:
        return 'Employment Document';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  String get formattedProcessingTime {
    if (processingTime.inSeconds >= 60) {
      final minutes = processingTime.inMinutes;
      final seconds = processingTime.inSeconds.remainder(60);
      return '${minutes}m ${seconds}s';
    }
    return '${processingTime.inSeconds}.${processingTime.inMilliseconds.remainder(1000) ~/ 100}s';
  }

  DocumentMetadata copyWith({
    String? fileName,
    int? pageCount,
    int? wordCount,
    int? characterCount,
    DocumentType? type,
    Duration? processingTime,
    double? confidence,
  }) {
    return DocumentMetadata(
      fileName: fileName ?? this.fileName,
      pageCount: pageCount ?? this.pageCount,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      type: type ?? this.type,
      processingTime: processingTime ?? this.processingTime,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'pageCount': pageCount,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'type': type.name,
      'processingTimeMs': processingTime.inMilliseconds,
      'confidence': confidence,
    };
  }

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      fileName: json['fileName'] as String?,
      pageCount: json['pageCount'] as int? ?? 1,
      wordCount: json['wordCount'] as int? ?? 0,
      characterCount: json['characterCount'] as int? ?? 0,
      type: DocumentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      processingTime: Duration(milliseconds: json['processingTimeMs'] as int? ?? 0),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [fileName, pageCount, wordCount, characterCount, type, processingTime, confidence];
}