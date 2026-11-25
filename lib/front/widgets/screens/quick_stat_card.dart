import 'package:flutter/material.dart';
import 'package:textrepresentation/services/analyzers/bag_of_words_analyzer.dart';

class QuickStatsCard extends StatelessWidget {
  final BagOfWordsResult? result;
  final int topN;

  const QuickStatsCard({
    super.key,
    required this.result,
    this.topN = 5,
  });

  @override
  Widget build(BuildContext context) {
    final data = result;
    if (data == null || data.documents.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Total filtered tokens across all documents
    final int totalFilteredWords = data.documents.fold<int>(
      0,
      (sum, doc) => sum + doc.tokens.length,
    );

    // Aggregate term counts across all documents
    final Map<String, int> totalsByTerm = <String, int>{};
    for (final doc in data.documents) {
      for (int i = 0; i < data.vocabulary.length; i++) {
        final count = doc.vector[i];
        if (count > 0) {
          final term = data.vocabulary[i];
          totalsByTerm[term] = (totalsByTerm[term] ?? 0) + count;
        }
      }
    }

    final List<MapEntry<String, int>> topWords = totalsByTerm.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final List<MapEntry<String, int>> topSlice = topWords.take(topN).toList();

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatMetric(
              label: 'Total Words (Filtered)',
              value: '$totalFilteredWords',
            ),
            _StatMetric(
              label: 'Documents',
              value: '${data.documents.length}',
            ),
            _StatMetric(
              label: 'Unique Terms',
              value: '${data.vocabulary.length}',
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Most Frequent Words',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                topSlice.isEmpty
                    ? Text(
                        'None',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final entry in topSlice)
                            Chip(
                              label: Text('${entry.key} (${entry.value})'),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatMetric extends StatelessWidget {
  final String label;
  final String value;

  const _StatMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}