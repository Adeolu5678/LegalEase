import 'package:cloud_firestore/cloud_firestore.dart';

enum DiffType {
  equal,
  insertion,
  deletion,
  modification,
}

class DiffLine {
  final String content;
  final DiffType type;
  final int lineNumber1;
  final int lineNumber2;

  const DiffLine({
    required this.content,
    required this.type,
    required this.lineNumber1,
    required this.lineNumber2,
  });
}

class DiffResult {
  final List<DiffLine> lines;
  final int additions;
  final int deletions;
  final int modifications;
  final double similarityScore;

  const DiffResult({
    required this.lines,
    required this.additions,
    required this.deletions,
    required this.modifications,
    required this.similarityScore,
  });

  int get totalChanges => additions + deletions + modifications;
}

class ComparisonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDocument(String documentId) async {
    final doc = await _firestore.collection('documents').doc(documentId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    final snapshot = await _firestore
        .collection('documents')
        .where('userId', isEqualTo: userId)
        .orderBy('analyzedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  DiffResult compareTexts(String text1, String text2) {
    final lines1 = text1.split('\n');
    final lines2 = text2.split('\n');

    final diff = _myersDiff(lines1, lines2);

    int additions = 0;
    int deletions = 0;
    int modifications = 0;

    for (final line in diff) {
      switch (line.type) {
        case DiffType.insertion:
          additions++;
          break;
        case DiffType.deletion:
          deletions++;
          break;
        case DiffType.modification:
          modifications++;
          break;
        case DiffType.equal:
          break;
      }
    }

    final totalLines = lines1.length + lines2.length;
    final equalLines = diff.where((l) => l.type == DiffType.equal).length;
    final similarityScore = totalLines > 0 ? (equalLines * 2 / totalLines) : 1.0;

    return DiffResult(
      lines: diff,
      additions: additions,
      deletions: deletions,
      modifications: modifications,
      similarityScore: similarityScore,
    );
  }

  List<DiffLine> _myersDiff(List<String> a, List<String> b) {
    final diff = <DiffLine>[];
    final m = a.length;
    final n = b.length;

    final trace = _buildTrace(a, b);
    var x = m;
    var y = n;

    for (var d = trace.length - 1; d >= 0; d--) {
      final v = trace[d];
      final k = x - y;

      final prevK = _getPrevK(v, k, d);
      final prevX = v[prevK + (d + m + n)] ?? 0;
      final prevY = prevX - prevK;

      while (x > prevX && y > prevY) {
        diff.insert(0, DiffLine(
          content: a[x - 1],
          type: DiffType.equal,
          lineNumber1: x,
          lineNumber2: y,
        ));
        x--;
        y--;
      }

      if (d > 0) {
        if (x == prevX) {
          diff.insert(0, DiffLine(
            content: b[y - 1],
            type: DiffType.insertion,
            lineNumber1: x,
            lineNumber2: y,
          ));
          y--;
        } else {
          diff.insert(0, DiffLine(
            content: a[x - 1],
            type: DiffType.deletion,
            lineNumber1: x,
            lineNumber2: y,
          ));
          x--;
        }
      }
    }

    return _mergeModifications(diff);
  }

  List<Map<int, int>> _buildTrace(List<String> a, List<String> b) {
    final m = a.length;
    final n = b.length;
    final max = m + n;
    final trace = <Map<int, int>>[];
    final v = <int, int>{(-max): 0};

    outer:
    for (var d = 0; d <= max; d++) {
      final newV = Map<int, int>.from(v);
      trace.add(newV);

      for (var k = -d; k <= d; k += 2) {
        int x;
        if (k == -d || (k != d && (v[k - 1 + max] ?? 0) < (v[k + 1 + max] ?? 0))) {
          x = v[k + 1 + max] ?? 0;
        } else {
          x = (v[k - 1 + max] ?? 0) + 1;
        }

        var y = x - k;

        while (x < m && y < n && a[x] == b[y]) {
          x++;
          y++;
        }

        v[k + max] = x;

        if (x >= m && y >= n) {
          break outer;
        }
      }
    }

    return trace;
  }

  int _getPrevK(Map<int, int> v, int k, int d) {
    final max = v.length;
    final down = (k == -d) || (k != d && (v[k - 1 + max] ?? 0) < (v[k + 1 + max] ?? 0));
    return down ? k + 1 : k - 1;
  }

  List<DiffLine> _mergeModifications(List<DiffLine> diff) {
    final result = <DiffLine>[];
    
    for (var i = 0; i < diff.length; i++) {
      final current = diff[i];
      
      if (current.type == DiffType.deletion && i + 1 < diff.length) {
        final next = diff[i + 1];
        if (next.type == DiffType.insertion) {
          result.add(DiffLine(
            content: '${current.content} → ${next.content}',
            type: DiffType.modification,
            lineNumber1: current.lineNumber1,
            lineNumber2: next.lineNumber2,
          ));
          i++;
          continue;
        }
      }
      result.add(current);
    }

    return result;
  }

  List<Map<String, dynamic>> findRedFlagDifferences(
    List<dynamic> redFlags1,
    List<dynamic> redFlags2,
  ) {
    final differences = <Map<String, dynamic>>[];
    final flags1 = _normalizeRedFlags(redFlags1);
    final flags2 = _normalizeRedFlags(redFlags2);

    for (final flag1 in flags1) {
      final matchingFlag = flags2.firstWhere(
        (f) => f['originalClause'] == flag1['originalClause'],
        orElse: () => <String, dynamic>{},
      );

      if (matchingFlag.isEmpty) {
        differences.add({
          'type': 'removed',
          'flag': flag1,
          'document': 1,
        });
      }
    }

    for (final flag2 in flags2) {
      final matchingFlag = flags1.firstWhere(
        (f) => f['originalClause'] == flag2['originalClause'],
        orElse: () => <String, dynamic>{},
      );

      if (matchingFlag.isEmpty) {
        differences.add({
          'type': 'added',
          'flag': flag2,
          'document': 2,
        });
      } else if (matchingFlag['severity'] != flag2['severity']) {
        differences.add({
          'type': 'severity_changed',
          'oldSeverity': matchingFlag['severity'],
          'newSeverity': flag2['severity'],
          'flag': flag2,
        });
      }
    }

    return differences;
  }

  List<Map<String, dynamic>> _normalizeRedFlags(List<dynamic> redFlags) {
    return redFlags.map((f) {
      if (f is Map<String, dynamic>) {
        return f;
      }
      return <String, dynamic>{};
    }).toList();
  }

  String generateComparisonSummary(DiffResult result, String doc1Title, String doc2Title) {
    final buffer = StringBuffer();
    
    buffer.writeln('## Document Comparison Summary\n');
    buffer.writeln('**Document 1:** $doc1Title');
    buffer.writeln('**Document 2:** $doc2Title\n');
    
    buffer.writeln('### Statistics');
    buffer.writeln('- Similarity Score: ${(result.similarityScore * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Lines Added: ${result.additions}');
    buffer.writeln('- Lines Deleted: ${result.deletions}');
    buffer.writeln('- Lines Modified: ${result.modifications}');
    buffer.writeln('- Total Changes: ${result.totalChanges}\n');

    if (result.similarityScore > 0.9) {
      buffer.writeln('### Assessment');
      buffer.writeln('The documents are nearly identical with only minor differences.');
    } else if (result.similarityScore > 0.7) {
      buffer.writeln('### Assessment');
      buffer.writeln('The documents have significant similarities but notable differences.');
    } else if (result.similarityScore > 0.5) {
      buffer.writeln('### Assessment');
      buffer.writeln('The documents are moderately different with substantial changes.');
    } else {
      buffer.writeln('### Assessment');
      buffer.writeln('The documents are significantly different.');
    }

    return buffer.toString();
  }
}
