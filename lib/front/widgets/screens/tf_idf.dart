import 'package:flutter/material.dart';
import 'package:textrepresentation/services/analyzers/tfidf_analyzer.dart';

class TfIdfscreen extends StatelessWidget {
  final TfIdfResult? result;

  const TfIdfscreen({
    super.key,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final data = result;

    if (data == null || data.documents.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 36,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                'No TF-IDF Data Yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter text or upload a text-based PDF and tap Analyze to inspect TF, IDF, and TF-IDF scores.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        // Step 1: Term Frequency (TF)
        _TfIdfSectionCard(
          title: 'Step 1: Term Frequency (TF)',
          subtitle: 'TF = Term Count / Total Words in Doc',
          badgeText: '${data.documents.length} Docs',
          child: Column(
            children: [
              for (int i = 0; i < data.documents.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _TfDocumentCard(doc: data.documents[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Step 2: Inverse Document Frequency (IDF)
        _TfIdfSectionCard(
          title: 'Step 2: Inverse Document Frequency (IDF)',
          subtitle: 'IDF = log10(Total Docs / Docs Containing Term)',
          badgeText: '${data.vocabulary.length} Terms',
          child: data.vocabulary.isEmpty
              ? Text(
                  'No vocabulary terms available for IDF calculation.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Column(
                  children: [
                    for (int w = 0; w < data.vocabulary.length; w++) ...[
                      if (w > 0) const Divider(height: 16),
                      _IdfTermRow(
                        term: data.vocabulary[w],
                        totalDocs: data.documents.length,
                        docsContainingTerm: data.docsContainingTerm[w],
                        idf: data.idfVector[w],
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 14),

        // Step 3: TF-IDF Matrix
        _TfIdfSectionCard(
          title: 'Step 3: TF-IDF Matrix',
          subtitle: 'TF-IDF = TF × IDF',
          badgeText: 'Weighted Scores',
          child: Column(
            children: [
              for (int i = 0; i < data.documents.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _TfIdfMatrixCard(doc: data.documents[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TfIdfSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Widget child;

  const _TfIdfSectionCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _TfDocumentCard extends StatelessWidget {
  final TfIdfDocumentResult doc;

  const _TfDocumentCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeScores = doc.scores.where((s) => s.count > 0).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Doc ${doc.docIndex + 1}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${doc.totalFilteredWords} filtered words)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          activeScores.isEmpty
              ? Text(
                  'No matching vocabulary terms in this document.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in activeScores)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.term}: ${item.count}/${doc.totalFilteredWords} = ${item.tf.toStringAsFixed(3)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _IdfTermRow extends StatelessWidget {
  final String term;
  final int totalDocs;
  final int docsContainingTerm;
  final double idf;

  const _IdfTermRow({
    required this.term,
    required this.totalDocs,
    required this.docsContainingTerm,
    required this.idf,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            term,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'log10($totalDocs / $docsContainingTerm)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            idf.toStringAsFixed(3),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _TfIdfMatrixCard extends StatelessWidget {
  final TfIdfDocumentResult doc;

  const _TfIdfMatrixCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final vectorSummary = doc.scores
        .map((s) => '${s.term}: ${s.tfIdf.toStringAsFixed(3)}')
        .join('  |  ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doc ${doc.docIndex + 1}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              vectorSummary.isEmpty ? 'No terms' : vectorSummary,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in doc.scores)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: item.tfIdf > 0
                        ? colorScheme.primaryContainer.withValues(alpha: 0.7)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    '${item.term}: ${item.tf.toStringAsFixed(3)} × ${item.idf.toStringAsFixed(3)} = ${item.tfIdf.toStringAsFixed(3)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}