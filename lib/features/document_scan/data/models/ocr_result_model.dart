import 'dart:ui';

class OcrTextBlock {
  final String text;
  final Rect boundingBox;
  final List<String> lines;
  final double confidence;

  const OcrTextBlock({
    required this.text,
    required this.boundingBox,
    required this.lines,
    this.confidence = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'boundingBox': {
          'left': boundingBox.left,
          'top': boundingBox.top,
          'right': boundingBox.right,
          'bottom': boundingBox.bottom,
        },
        'lines': lines,
        'confidence': confidence,
      };

  factory OcrTextBlock.fromJson(Map<String, dynamic> json) => OcrTextBlock(
        text: json['text'] as String,
        boundingBox: Rect.fromLTRB(
          (json['boundingBox']['left'] as num).toDouble(),
          (json['boundingBox']['top'] as num).toDouble(),
          (json['boundingBox']['right'] as num).toDouble(),
          (json['boundingBox']['bottom'] as num).toDouble(),
        ),
        lines: (json['lines'] as List).cast<String>(),
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      );
}

class OcrResultModel {
  final String text;
  final List<OcrTextBlock> blocks;
  final Size imageSize;
  final Duration processingTime;
  final double confidence;
  final String? filePath;
  final int pageIndex;

  const OcrResultModel({
    required this.text,
    required this.blocks,
    required this.imageSize,
    required this.processingTime,
    this.confidence = 0.0,
    this.filePath,
    this.pageIndex = 0,
  });

  bool get isEmpty => text.trim().isEmpty;
  bool get isNotEmpty => text.trim().isNotEmpty;
  int get wordCount => text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  int get characterCount => text.length;
  int get blockCount => blocks.length;

  String get preview {
    if (text.length <= 200) return text;
    return '${text.substring(0, 200)}...';
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'imageSize': {'width': imageSize.width, 'height': imageSize.height},
        'processingTimeMs': processingTime.inMilliseconds,
        'confidence': confidence,
        'filePath': filePath,
        'pageIndex': pageIndex,
      };

  factory OcrResultModel.fromJson(Map<String, dynamic> json) => OcrResultModel(
        text: json['text'] as String,
        blocks: (json['blocks'] as List)
            .map((b) => OcrTextBlock.fromJson(b as Map<String, dynamic>))
            .toList(),
        imageSize: Size(
          (json['imageSize']['width'] as num).toDouble(),
          (json['imageSize']['height'] as num).toDouble(),
        ),
        processingTime: Duration(milliseconds: json['processingTimeMs'] as int),
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        filePath: json['filePath'] as String?,
        pageIndex: json['pageIndex'] as int? ?? 0,
      );

  OcrResultModel copyWith({
    String? text,
    List<OcrTextBlock>? blocks,
    Size? imageSize,
    Duration? processingTime,
    double? confidence,
    String? filePath,
    int? pageIndex,
  }) {
    return OcrResultModel(
      text: text ?? this.text,
      blocks: blocks ?? this.blocks,
      imageSize: imageSize ?? this.imageSize,
      processingTime: processingTime ?? this.processingTime,
      confidence: confidence ?? this.confidence,
      filePath: filePath ?? this.filePath,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}

class MultiPageOcrResult {
  final List<OcrResultModel> pages;
  final Duration totalProcessingTime;
  final double averageConfidence;

  const MultiPageOcrResult({
    required this.pages,
    required this.totalProcessingTime,
    this.averageConfidence = 0.0,
  });

  String get combinedText => pages.map((p) => p.text).join('\n\n--- Page Break ---\n\n');
  int get totalPages => pages.length;
  int get totalWordCount => pages.fold(0, (sum, p) => sum + p.wordCount);
  int get totalCharacterCount => pages.fold(0, (sum, p) => sum + p.characterCount);

  bool get isEmpty => pages.isEmpty || pages.every((p) => p.isEmpty);
  bool get isNotEmpty => !isEmpty;

  Map<String, dynamic> toJson() => {
        'pages': pages.map((p) => p.toJson()).toList(),
        'totalProcessingTimeMs': totalProcessingTime.inMilliseconds,
        'averageConfidence': averageConfidence,
      };

  factory MultiPageOcrResult.fromJson(Map<String, dynamic> json) => MultiPageOcrResult(
        pages: (json['pages'] as List)
            .map((p) => OcrResultModel.fromJson(p as Map<String, dynamic>))
            .toList(),
        totalProcessingTime: Duration(milliseconds: json['totalProcessingTimeMs'] as int),
        averageConfidence: (json['averageConfidence'] as num?)?.toDouble() ?? 0.0,
      );
}
