import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/legal_dictionary/data/models/legal_term.dart';
import 'package:legalease/features/legal_dictionary/domain/services/dictionary_service.dart';

final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return DictionaryService();
});

final dictionarySearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final dictionarySelectedCategoryProvider = StateProvider.autoDispose<LegalTermCategory?>((ref) => null);

final dictionarySearchResultsProvider = Provider.autoDispose<List<LegalTerm>>((ref) {
  final service = ref.watch(dictionaryServiceProvider);
  final query = ref.watch(dictionarySearchQueryProvider);
  final category = ref.watch(dictionarySelectedCategoryProvider);
  
  var results = service.searchTerms(query);
  
  if (category != null) {
    results = results.where((t) => t.category == category).toList();
  }
  
  return results;
});

final dictionarySelectedTermProvider = StateProvider.autoDispose<LegalTerm?>((ref) => null);

final dictionaryRelatedTermsProvider = Provider.autoDispose<List<LegalTerm>>((ref) {
  final service = ref.watch(dictionaryServiceProvider);
  final selectedTerm = ref.watch(dictionarySelectedTermProvider);
  
  if (selectedTerm == null) return [];
  
  return service.getRelatedTerms(selectedTerm);
});

final dictionaryAutocompleteProvider = Provider.autoDispose<List<String>>((ref) {
  final service = ref.watch(dictionaryServiceProvider);
  final query = ref.watch(dictionarySearchQueryProvider);
  
  return service.getAutocompleteSuggestions(query);
});
