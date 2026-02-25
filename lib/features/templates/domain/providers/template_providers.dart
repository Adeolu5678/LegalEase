import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/templates/data/models/legal_template.dart';
import 'package:legalease/features/templates/data/services/template_service.dart';

final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

final allTemplatesProvider = Provider<List<LegalTemplate>>((ref) {
  final service = ref.watch(templateServiceProvider);
  return service.allTemplates;
});

final templateSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final selectedCategoryProvider = StateProvider.autoDispose<TemplateCategory?>((ref) => null);

final filteredTemplatesProvider = Provider<List<LegalTemplate>>((ref) {
  final templates = ref.watch(allTemplatesProvider);
  final query = ref.watch(templateSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  var filtered = templates;

  if (category != null) {
    filtered = filtered.where((t) => t.category == category).toList();
  }

  if (query.isNotEmpty) {
    final normalizedQuery = query.toLowerCase();
    filtered = filtered.where((t) {
      return t.name.toLowerCase().contains(normalizedQuery) ||
          t.description.toLowerCase().contains(normalizedQuery) ||
          t.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
    }).toList();
  }

  return filtered;
});

final selectedTemplateProvider = StateProvider<LegalTemplate?>((ref) => null);

final templateByIdProvider = Provider.family<LegalTemplate?, String>((ref, id) {
  final service = ref.watch(templateServiceProvider);
  return service.getTemplateById(id);
});

final templateFieldValuesProvider = StateProvider.family<Map<String, dynamic>, String>((ref, templateId) {
  return {};
});

final categoriesProvider = Provider<List<TemplateCategory>>((ref) {
  return TemplateCategory.values;
});
