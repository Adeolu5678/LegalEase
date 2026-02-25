import 'dart:io';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:legalease/features/document_scan/data/models/ocr_result_model.dart';

typedef ProgressCallback = void Function(int current, int total, String status);

class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void reset() {
    _isCancelled = false;
  }
}

class CancellationException implements Exception {
  final String message;
  const CancellationException([this.message = 'Operation was cancelled']);

  @override
  String toString() => 'CancellationException: $message';
}

class OcrService {
  final TextRecognizer _textRecognizer;
  bool _isDisposed = false;

  OcrService() : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  OcrService.withScript(TextRecognitionScript script)
      : _textRecognizer = TextRecognizer(script: script);

  Future<OcrResultModel> extractTextFromImage(
    File imageFile, {
    int maxImageDimension = 2048,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    if (_isDisposed) {
      throw StateError('OcrService has been disposed');
    }

    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    onProgress?.call(0, 3, 'Starting OCR processing');

    final stopwatch = Stopwatch()..start();

    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    onProgress?.call(1, 3, 'Preparing image');

    if (await shouldResizeImage(imageFile, maxImageDimension)) {
      onProgress?.call(1, 3, 'Image would be resized (stub implementation)');
    }

    final inputImage = InputImage.fromFile(imageFile);

    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    onProgress?.call(2, 3, 'Processing image with OCR');

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      stopwatch.stop();

      if (cancellationToken?.isCancelled == true) {
        throw const CancellationException();
      }

      onProgress?.call(3, 3, 'Extracting text blocks');

      final blocks = _extractTextBlocks(recognizedText);
      final confidence = _calculateConfidence(recognizedText);
      final imageSize = await _getImageSize(imageFile);

      final rawText = recognizedText.text;
      final cleanedText = preprocessText(rawText);

      return OcrResultModel(
        text: cleanedText,
        blocks: blocks,
        imageSize: imageSize,
        processingTime: stopwatch.elapsed,
        confidence: confidence,
        filePath: imageFile.path,
        pageIndex: 0,
      );
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }

  Future<List<OcrResultModel>> extractTextFromImages(
    List<File> images, {
    int maxConcurrency = 3,
    int maxImageDimension = 2048,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    if (_isDisposed) {
      throw StateError('OcrService has been disposed');
    }

    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    final results = <OcrResultModel>[];

    for (var i = 0; i < images.length; i++) {
      if (cancellationToken?.isCancelled == true) {
        throw const CancellationException();
      }

      onProgress?.call(i, images.length, 'Processing image ${i + 1} of ${images.length}');

      try {
        final result = await extractTextFromImage(
          images[i],
          maxImageDimension: maxImageDimension,
          cancellationToken: cancellationToken,
        );
        results.add(result.copyWith(pageIndex: i));
      } catch (e) {
        if (e is CancellationException) {
          rethrow;
        }
        results.add(OcrResultModel(
          text: '',
          blocks: [],
          imageSize: Size.zero,
          processingTime: Duration.zero,
          filePath: images[i].path,
          pageIndex: i,
        ));
      }
    }

    onProgress?.call(images.length, images.length, 'Processing complete');

    return results;
  }

  Future<MultiPageOcrResult> extractTextFromImagesCombined(
    List<File> images, {
    int maxConcurrency = 3,
    int maxImageDimension = 2048,
    bool useParallel = false,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    final stopwatch = Stopwatch()..start();

    final results = useParallel
        ? await extractTextFromImagesParallel(
            images,
            maxConcurrency: maxConcurrency,
            maxImageDimension: maxImageDimension,
            onProgress: onProgress,
            cancellationToken: cancellationToken,
          )
        : await extractTextFromImages(
            images,
            maxConcurrency: maxConcurrency,
            maxImageDimension: maxImageDimension,
            onProgress: onProgress,
            cancellationToken: cancellationToken,
          );

    stopwatch.stop();

    final validResults = results.where((r) => r.isNotEmpty).toList();
    final avgConfidence = validResults.isEmpty
        ? 0.0
        : validResults.map((r) => r.confidence).reduce((a, b) => a + b) / validResults.length;

    return MultiPageOcrResult(
      pages: results,
      totalProcessingTime: stopwatch.elapsed,
      averageConfidence: avgConfidence,
    );
  }

  String preprocessText(String rawText) {
    if (rawText.isEmpty) return rawText;

    var text = rawText;

    text = text.replaceAll(RegExp(r'\r\n'), '\n');
    text = text.replaceAll(RegExp(r'\r'), '\n');

    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    text = text.replaceAll(RegExp(r' +\n'), '\n');
    text = text.replaceAll(RegExp(r'\n +'), '\n');

    text = _fixBrokenWords(text);

    text = text.replaceAll(RegExp(r'([.!?])\s*([A-Z])'), r'$1 $2');

    text = text.trim();

    return text;
  }

  String _fixBrokenWords(String text) {
    return text.replaceAllMapped(
      RegExp(r'(\w)-\n(\w)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );
  }

  List<OcrTextBlock> _extractTextBlocks(RecognizedText recognizedText) {
    final blocks = <OcrTextBlock>[];

    for (final block in recognizedText.blocks) {
      final lines = block.lines.map((line) => line.text).toList();
      final confidence = _calculateBlockConfidenceFromMlKit(block);

      blocks.add(OcrTextBlock(
        text: block.text,
        boundingBox: block.boundingBox,
        lines: lines,
        confidence: confidence,
      ));
    }

    return blocks;
  }

  double _calculateConfidence(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;

    var totalConfidence = 0.0;
    var count = 0;

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          totalConfidence += element.confidence ?? 0.5;
          count++;
        }
      }
    }

    return count > 0 ? totalConfidence / count : 0.0;
  }

  double _calculateBlockConfidenceFromMlKit(TextBlock block) {
    var totalConfidence = 0.0;
    var count = 0;

    for (final line in block.lines) {
      for (final element in line.elements) {
        totalConfidence += element.confidence ?? 0.5;
        count++;
      }
    }

    return count > 0 ? totalConfidence / count : 0.0;
  }

  Future<Size> _getImageSize(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } catch (e) {
      return Size.zero;
    }
  }

  Future<bool> shouldResizeImage(File imageFile, int maxDimension) async {
    try {
      final imageSize = await _getImageSize(imageFile);
      if (imageSize == Size.zero) return false;

      return imageSize.width > maxDimension || imageSize.height > maxDimension;
    } catch (e) {
      return false;
    }
  }

  Future<List<OcrResultModel>> extractTextFromImagesParallel(
    List<File> images, {
    int maxConcurrency = 3,
    int maxImageDimension = 2048,
    ProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    if (_isDisposed) {
      throw StateError('OcrService has been disposed');
    }

    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    if (images.isEmpty) {
      return [];
    }

    final results = List<OcrResultModel?>.filled(images.length, null);
    var completedCount = 0;

    for (var batchStart = 0; batchStart < images.length; batchStart += maxConcurrency) {
      if (cancellationToken?.isCancelled == true) {
        throw const CancellationException();
      }

      final batchEnd = (batchStart + maxConcurrency).clamp(0, images.length);
      final batchIndices = List.generate(batchEnd - batchStart, (i) => batchStart + i);

      onProgress?.call(completedCount, images.length, 'Processing batch of ${batchIndices.length} images');

      final batchFutures = <Future<void>>[];

      for (final index in batchIndices) {
        batchFutures.add(_processImageWithIndex(
          images[index],
          index,
          results,
          maxImageDimension,
          cancellationToken,
        ).then((_) {
          completedCount++;
          onProgress?.call(completedCount, images.length, 'Completed image ${index + 1} of ${images.length}');
        }).catchError((e) {
          if (e is CancellationException) {
            throw e;
          }
          results[index] = OcrResultModel(
            text: '',
            blocks: [],
            imageSize: Size.zero,
            processingTime: Duration.zero,
            filePath: images[index].path,
            pageIndex: index,
          );
          completedCount++;
          onProgress?.call(completedCount, images.length, 'Failed image ${index + 1} of ${images.length}');
        }));
      }

      try {
        await Future.wait(batchFutures);
      } catch (e) {
        if (e is CancellationException) {
          rethrow;
        }
      }
    }

    onProgress?.call(images.length, images.length, 'Processing complete');

    return results.cast<OcrResultModel>();
  }

  Future<void> _processImageWithIndex(
    File imageFile,
    int index,
    List<OcrResultModel?> results,
    int maxImageDimension,
    CancellationToken? cancellationToken,
  ) async {
    if (cancellationToken?.isCancelled == true) {
      throw const CancellationException();
    }

    final result = await extractTextFromImage(
      imageFile,
      maxImageDimension: maxImageDimension,
      cancellationToken: cancellationToken,
    );

    results[index] = result.copyWith(pageIndex: index);
  }

  Future<void> close() async {
    if (!_isDisposed) {
      await _textRecognizer.close();
      _isDisposed = true;
    }
  }

  void dispose() {
    close();
  }
}
