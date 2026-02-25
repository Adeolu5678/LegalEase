import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/features/search/data/services/search_service.dart';
import 'package:legalease/features/auth/domain/providers/providers.dart';

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final searchFilterProvider = StateProvider.autoDispose<SearchFilter>((ref) => SearchFilter.all);

final severityFilterProvider = StateProvider.autoDispose<SeverityFilter>((ref) => SeverityFilter.all);

final startDateFilterProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

final endDateFilterProvider = StateProvider.autoDispose<DateTime?>((ref) => null);

final isSearchingProvider = StateProvider.autoDispose<bool>((ref) => false);

final searchResultsProvider = FutureProvider.autoDispose<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final filter = ref.watch(searchFilterProvider);
  final severity = ref.watch(severityFilterProvider);
  final startDate = ref.watch(startDateFilterProvider);
  final endDate = ref.watch(endDateFilterProvider);
  final service = ref.watch(searchServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;

  return service.searchDocuments(
    query,
    userId: user?.uid,
    documentTypeFilter: filter,
    severityFilter: severity,
    startDate: startDate,
    endDate: endDate,
  );
});

final searchHistoryProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final service = ref.watch(searchServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  
  return service.getSearchHistory(userId: user?.uid);
});

final saveSearchQueryProvider = FutureProvider.family<void, String>((ref, query) async {
  final service = ref.watch(searchServiceProvider);
  final user = ref.watch(authStateChangesProvider).value;
  
  await service.saveSearchQuery(query, userId: user?.uid);
});
