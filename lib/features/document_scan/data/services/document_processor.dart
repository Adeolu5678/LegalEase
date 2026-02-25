import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:legalease/shared/models/document_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

enum ProcessingStatus {
  idle,
  loading,
  processing,
  completed,
  error,
}

enum MemoryPressureLevel {
  none,
  moderate,
  critical,
}

typedef ProgressCallback = void Function(int current, int total, String status);

class CancellationException implements Exception {
  final String message;
  const CancellationException([this.message = 'Operation was cancelled']);

  @override
  String toString() => 'CancellationException: $message';
}

class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const CancellationException();
    }
  }
}

class StructuredDocument {
  final DocumentType type;
  final String title;
  final List<DocumentSection> sections;
  final Map<String, String> metadata;
  final double confidence;

  const StructuredDocument({
    required this.type,
    required this.title,
    required this.sections,
    this.metadata = const {},
    this.confidence = 0.0,
  });

  String get fullText => sections.map((s) => s.content).join('\n\n');

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'sections': sections.map((s) => s.toJson()).toList(),
        'metadata': metadata,
        'confidence': confidence,
      };
}

class DocumentSection {
  final String heading;
  final String content;
  final int startIndex;
  final int endIndex;

  const DocumentSection({
    required this.heading,
    required this.content,
    required this.startIndex,
    required this.endIndex,
  });

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'content': content,
        'startIndex': startIndex,
        'endIndex': endIndex,
      };
}

class DocumentProcessor {
  static const int _defaultDpi = 200;
  static const int _maxPageCount = 50;
  static const int _defaultBatchSize = 10;
  static const int _defaultMaxMemoryBytes = 50 * 1024 * 1024;

  final Set<String> _tempFiles = {};
  bool _isDisposed = false;

  Future<List<File>> pdfToImages(
    File pdfFile, {
    int dpi = _defaultDpi,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
    int batchSize = _defaultBatchSize,
  }) async {
    final bytes = await pdfFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final images = <File>[];
    final tempDir = await getTemporaryDirectory();

    final pageCount = document.pages.count.clamp(0, _maxPageCount);

    for (var i = 0; i < pageCount; i++) {
      cancellationToken?.throwIfCancelled();

      onProgress?.call(i + 1, pageCount, 'Processing page ${i + 1} of $pageCount');

      if (i > 0 && i % batchSize == 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      try {
        final page = document.pages[i];
        final template = page.createTemplate();
        final newDoc = PdfDocument();
        final newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          Size(
            page.size.width * dpi / 72,
            page.size.height * dpi / 72,
          ),
        );

        final pdfBytes = await newDoc.save();
        newDoc.dispose();

        final file = File('${tempDir.path}/pdf_page_$i.pdf');
        await file.writeAsBytes(pdfBytes);
        _tempFiles.add(file.path);
        images.add(file);
      } catch (e) {
        if (e is CancellationException) rethrow;
        continue;
      }
    }

    document.dispose();
    return images;
  }

  Future<List<File>> extractPdfPages(
    File pdfFile, {
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
    int batchSize = _defaultBatchSize,
  }) async {
    return pdfToImages(
      pdfFile,
      onProgress: onProgress,
      cancellationToken: cancellationToken,
      batchSize: batchSize,
    );
  }

  DocumentType detectDocumentType(String text) {
    if (text.isEmpty) return DocumentType.other;

    final lowerText = text.toLowerCase();

    final scores = <DocumentType, int>{
      DocumentType.contract: _scoreContract(lowerText),
      DocumentType.lease: _scoreLease(lowerText),
      DocumentType.termsConditions: _scoreTermsConditions(lowerText),
      DocumentType.privacyPolicy: _scorePrivacyPolicy(lowerText),
      DocumentType.eula: _scoreEula(lowerText),
    };

    var maxScore = 0;
    var detectedType = DocumentType.other;

    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        detectedType = entry.key;
      }
    }

    return maxScore > 3 ? detectedType : DocumentType.other;
  }

  int _scoreContract(String text) {
    var score = 0;
    final keywords = [
      'agreement',
      'contract',
      'party',
      'parties',
      'hereby',
      'whereas',
      'terms and conditions',
      'obligations',
      'consideration',
      'execution',
      'effective date',
      'binding',
    ];

    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }

    return score;
  }

  int _scoreLease(String text) {
    var score = 0;
    final keywords = [
      'lease',
      'landlord',
      'tenant',
      'rent',
      'premises',
      'security deposit',
      'lease term',
      'rental',
      'occupancy',
      'property',
      'month-to-month',
    ];

    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }

    return score;
  }

  int _scoreTermsConditions(String text) {
    var score = 0;
    final keywords = [
      'terms of service',
      'terms and conditions',
      'user agreement',
      'terms of use',
      'service',
      'account',
      'user',
      'website',
      'platform',
      'access',
      'termination',
    ];

    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }

    return score;
  }

  int _scorePrivacyPolicy(String text) {
    var score = 0;
    final keywords = [
      'privacy policy',
      'personal data',
      'personal information',
      'data collection',
      'cookies',
      'gdpr',
      'ccpa',
      'data protection',
      'third parties',
      'consent',
      'data processing',
    ];

    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }

    return score;
  }

  int _scoreEula(String text) {
    var score = 0;
    final keywords = [
      'end user license agreement',
      'eula',
      'license',
      'software',
      'intellectual property',
      'copyright',
      'warranty',
      'liability',
      'license grant',
      'restrictions',
      'reverse engineer',
    ];

    for (final keyword in keywords) {
      if (text.contains(keyword)) score++;
    }

    return score;
  }

  Future<StructuredDocument> structureDocument(String rawText) async {
    if (rawText.isEmpty) {
      return const StructuredDocument(
        type: DocumentType.other,
        title: 'Untitled Document',
        sections: [],
      );
    }

    final documentType = detectDocumentType(rawText);
    final title = _extractTitle(rawText);
    final sections = _extractSections(rawText);
    final metadata = _extractMetadata(rawText);

    return StructuredDocument(
      type: documentType,
      title: title,
      sections: sections,
      metadata: metadata,
      confidence: _calculateStructureConfidence(sections),
    );
  }

  String _extractTitle(String text) {
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.length > 3 && trimmed.length < 100) {
        return trimmed;
      }
    }
    return 'Untitled Document';
  }

  List<DocumentSection> _extractSections(String text) {
    final sections = <DocumentSection>[];
    final lines = text.split('\n');

    final headingPatterns = [
      RegExp(r'^(\d+\.)\s+(.+)$'),
      RegExp(r'^([A-Z][A-Z\s]+)$'),
      RegExp(r'^(Article\s+\d+.*)$', caseSensitive: false),
      RegExp(r'^(Section\s+\d+.*)$', caseSensitive: false),
      RegExp(r'^(\d+\.\d+\s+.+)$'),
    ];

    var currentHeading = '';
    var currentContent = StringBuffer();
    var startIndex = 0;
    var currentIndex = 0;

    for (final line in lines) {
      currentIndex += line.length + 1;

      bool isHeading = false;
      String? headingText;

      for (final pattern in headingPatterns) {
        final match = pattern.firstMatch(line.trim());
        if (match != null) {
          isHeading = true;
          headingText = match.group(0) ?? line.trim();
          break;
        }
      }

      if (line.trim().length < 60 &&
          line.trim().isNotEmpty &&
          line.trim() == line.trim().toUpperCase() &&
          line.trim().split(' ').length <= 10) {
        isHeading = true;
        headingText = line.trim();
      }

      if (isHeading && headingText != null) {
        if (currentHeading.isNotEmpty && currentContent.toString().trim().isNotEmpty) {
          sections.add(DocumentSection(
            heading: currentHeading,
            content: currentContent.toString().trim(),
            startIndex: startIndex,
            endIndex: currentIndex - line.length - 1,
          ));
        }

        currentHeading = headingText;
        currentContent = StringBuffer();
        startIndex = currentIndex;
      } else {
        currentContent.writeln(line);
      }
    }

    if (currentHeading.isNotEmpty && currentContent.toString().trim().isNotEmpty) {
      sections.add(DocumentSection(
        heading: currentHeading,
        content: currentContent.toString().trim(),
        startIndex: startIndex,
        endIndex: currentIndex,
      ));
    }

    return sections;
  }

  Map<String, String> _extractMetadata(String text) {
    final metadata = <String, String>{};

    final datePatterns = [
      RegExp(r'(?:effective\s+date|date)[:\s]+([A-Za-z]+\s+\d{1,2},?\s+\d{4})', caseSensitive: false),
      RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})'),
      RegExp(r'([A-Za-z]+\s+\d{1,2},?\s+\d{4})'),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        metadata['date'] = match.group(1) ?? '';
        break;
      }
    }

    final partyPattern = RegExp(r'(?:between|party)[:\s]+([A-Z][A-Za-z\s]+)', caseSensitive: false);
    final partyMatch = partyPattern.firstMatch(text);
    if (partyMatch != null) {
      metadata['party'] = partyMatch.group(1)?.trim() ?? '';
    }

    return metadata;
  }

  double _calculateStructureConfidence(List<DocumentSection> sections) {
    if (sections.isEmpty) return 0.0;
    if (sections.length < 3) return 0.3;
    if (sections.length < 5) return 0.6;
    if (sections.length < 10) return 0.8;
    return 0.95;
  }

  Future<String> extractTextFromPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  Future<String> extractTextFromPdfStreaming(
    File pdfFile, {
    int maxMemoryBytes = _defaultMaxMemoryBytes,
    int batchSize = _defaultBatchSize,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    final fileStream = pdfFile.openRead();
    final chunks = <int>[];
    int totalBytesRead = 0;

    await for (final chunk in fileStream) {
      cancellationToken?.throwIfCancelled();

      totalBytesRead += chunk.length;
      if (totalBytesRead > maxMemoryBytes) {
        throw Exception('PDF exceeds maximum memory limit of $maxMemoryBytes bytes');
      }
      chunks.addAll(chunk);
    }

    final bytes = Uint8List.fromList(chunks);
    final document = PdfDocument(inputBytes: bytes);
    final pageCount = document.pages.count;
    final textBuffer = StringBuffer();

    for (var i = 0; i < pageCount; i++) {
      cancellationToken?.throwIfCancelled();

      onProgress?.call(i + 1, pageCount, 'Extracting text from page ${i + 1} of $pageCount');

      if (i > 0 && i % batchSize == 0) {
        await Future.delayed(const Duration(milliseconds: 10));
      }

      try {
        final pageText = PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
        textBuffer.write(pageText);
      } catch (e) {
        if (e is CancellationException) rethrow;
        continue;
      }
    }

    document.dispose();
    return textBuffer.toString();
  }

  Future<void> cleanupTempFiles() async {
    final filesToDelete = List<String>.from(_tempFiles);
    _tempFiles.clear();

    for (final filePath in filesToDelete) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }
  }

  MemoryPressureLevel checkMemoryPressure() {
    return MemoryPressureLevel.none;
  }

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    cleanupTempFiles();
  }

  bool isPdfFile(File file) {
    return file.path.toLowerCase().endsWith('.pdf');
  }

  bool isImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.bmp') ||
        extension.endsWith('.webp');
  }

  String cleanExtractedText(String text) {
    if (text.isEmpty) return text;

    var cleaned = text;

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    cleaned = cleaned.replaceAll(RegExp(r'[^\x00-\x7F]+'), '');

    cleaned = cleaned.replaceAll(RegExp(r'([.!?])\s*([A-Z])'), r'$1 $2');

    cleaned = cleaned.trim();

    return cleaned;
  }
}
