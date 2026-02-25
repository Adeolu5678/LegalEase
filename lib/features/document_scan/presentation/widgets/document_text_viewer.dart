import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DocumentTextViewer extends StatefulWidget {
  final String text;
  final List<RedFlagHighlight> redFlags;
  final void Function(RedFlagHighlight)? onRedFlagTap;
  final bool showSearch;

  const DocumentTextViewer({
    super.key,
    required this.text,
    this.redFlags = const [],
    this.onRedFlagTap,
    this.showSearch = true,
  });

  @override
  State<DocumentTextViewer> createState() => _DocumentTextViewerState();
}

class _DocumentTextViewerState extends State<DocumentTextViewer> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentSearchIndex = 0;
  List<int> _searchMatches = [];

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TextSpan> _buildTextSpans() {
    final spans = <TextSpan>[];
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.redFlags.isEmpty && _searchQuery.isEmpty) {
      return [TextSpan(text: widget.text)];
    }

    final flaggedRanges = widget.redFlags
        .map((rf) => (start: rf.startPosition, end: rf.endPosition, flag: rf))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    int currentPos = 0;

    for (final range in flaggedRanges) {
      if (range.start > currentPos) {
        final normalText = widget.text.substring(currentPos, range.start);
        spans.addAll(_highlightSearch(normalText, currentPos, colorScheme));
      }

      final flaggedText = widget.text.substring(range.start, range.end);
      spans.add(
        TextSpan(
          text: flaggedText,
          style: TextStyle(
            backgroundColor: _getSeverityColor(range.flag.severity, colorScheme).withValues(alpha: 0.3),
            decoration: TextDecoration.underline,
            decorationColor: _getSeverityColor(range.flag.severity, colorScheme),
            decorationStyle: TextDecorationStyle.wavy,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => widget.onRedFlagTap?.call(range.flag),
        ),
      );
      currentPos = range.end;
    }

    if (currentPos < widget.text.length) {
      final remainingText = widget.text.substring(currentPos);
      spans.addAll(_highlightSearch(remainingText, currentPos, colorScheme));
    }

    return spans;
  }

  List<TextSpan> _highlightSearch(String text, int offset, ColorScheme colorScheme) {
    if (_searchQuery.isEmpty) {
      return [TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    final matches = _searchMatches.where((m) => m >= offset && m < offset + text.length).toList();
    
    if (matches.isEmpty) {
      return [TextSpan(text: text)];
    }

    int localPos = 0;
    for (final matchPos in matches) {
      final localMatchPos = matchPos - offset;
      if (localMatchPos > localPos) {
        spans.add(TextSpan(text: text.substring(localPos, localMatchPos)));
      }
      spans.add(
        TextSpan(
          text: text.substring(localMatchPos, localMatchPos + _searchQuery.length),
          style: TextStyle(
            backgroundColor: colorScheme.tertiaryContainer,
            color: colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      localPos = localMatchPos + _searchQuery.length;
    }

    if (localPos < text.length) {
      spans.add(TextSpan(text: text.substring(localPos)));
    }

    return spans;
  }

  Color _getSeverityColor(String severity, ColorScheme colorScheme) {
    return switch (severity.toLowerCase()) {
      'critical' || 'high' => colorScheme.error,
      'warning' || 'medium' => Colors.orange,
      _ => colorScheme.primary,
    };
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchMatches = [];
      _currentSearchIndex = 0;

      if (query.isNotEmpty) {
        int pos = 0;
        while ((pos = widget.text.toLowerCase().indexOf(query.toLowerCase(), pos)) != -1) {
          _searchMatches.add(pos);
          pos += query.length;
        }
      }
    });
  }

  void _nextMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchMatches.length;
    });
  }

  void _previousMatch() {
    if (_searchMatches.isEmpty) return;
    setState(() {
      _currentSearchIndex = (_currentSearchIndex - 1 + _searchMatches.length) % _searchMatches.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (widget.showSearch) ...[
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in document...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_currentSearchIndex + 1}/${_searchMatches.length}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up_rounded),
                            onPressed: _previousMatch,
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            onPressed: _nextMatch,
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          ),
                        ],
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _performSearch,
            ),
          ).animate().fadeIn(duration: 200.ms),
          const Divider(height: 1),
        ],
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SelectableText.rich(
                TextSpan(
                  children: _buildTextSpans(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }
}

class RedFlagHighlight {
  final String id;
  final String severity;
  final int startPosition;
  final int endPosition;
  final String explanation;

  const RedFlagHighlight({
    required this.id,
    required this.severity,
    required this.startPosition,
    required this.endPosition,
    required this.explanation,
  });
}
