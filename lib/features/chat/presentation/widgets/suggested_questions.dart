import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legalease/shared/providers/ai_providers.dart';
import 'package:legalease/features/document_scan/presentation/providers/document_scan_providers.dart';

class SuggestedQuestions extends ConsumerStatefulWidget {
  final Function(String) onQuestionSelected;
  final List<String>? customQuestions;
  final bool useDynamicSuggestions;

  const SuggestedQuestions({
    super.key,
    required this.onQuestionSelected,
    this.customQuestions,
    this.useDynamicSuggestions = true,
  });

  @override
  ConsumerState<SuggestedQuestions> createState() => _SuggestedQuestionsState();
}

class _SuggestedQuestionsState extends ConsumerState<SuggestedQuestions> {
  List<String> _dynamicQuestions = [];
  bool _isLoading = false;

  static const _defaultQuestions = [
    'What are the key terms?',
    'Are there any hidden fees?',
    'Can I cancel this contract?',
    'What are my obligations?',
    'What happens if I breach?',
    'Any automatic renewal clauses?',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.useDynamicSuggestions && widget.customQuestions == null) {
      _loadDynamicQuestions();
    }
  }

  Future<void> _loadDynamicQuestions() async {
    final analysisResult = ref.read(currentAnalysisResultProvider);
    if (analysisResult == null) return;

    setState(() => _isLoading = true);

    try {
      final aiServiceAsync = ref.read(aiServiceNotifierProvider);
      aiServiceAsync.when(
        data: (aiService) async {
          final questions = await aiService.getSuggestedQuestions(
            documentText: analysisResult.originalText,
            documentType: analysisResult.metadata.typeName,
            maxQuestions: 5,
          );
          if (mounted) {
            setState(() {
              _dynamicQuestions = questions;
              _isLoading = false;
            });
          }
        },
        loading: () {
          if (mounted) setState(() => _isLoading = false);
        },
        error: (_, __) {
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> get _questions {
    if (widget.customQuestions != null) {
      return widget.customQuestions!;
    }
    if (_dynamicQuestions.isNotEmpty) {
      return _dynamicQuestions;
    }
    return _defaultQuestions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Generating suggestions...',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: 44,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _questions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return Material(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => widget.onQuestionSelected(_questions[index]),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Text(
                      _questions[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.2);
            },
          ),
        ),
        if (_dynamicQuestions.isNotEmpty && !widget.useDynamicSuggestions)
          TextButton.icon(
            onPressed: _loadDynamicQuestions,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh suggestions'),
          ),
      ],
    );
  }
}
