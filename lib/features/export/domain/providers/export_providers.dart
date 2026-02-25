import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/export/domain/services/export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

final isExportingProvider = StateProvider.autoDispose<bool>((ref) => false);

final exportErrorProvider = StateProvider.autoDispose<String?>((ref) => null);
