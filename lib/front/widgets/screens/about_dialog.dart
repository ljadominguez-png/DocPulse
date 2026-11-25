import 'package:flutter/material.dart';

class DocPulseAboutDialog extends StatelessWidget {
  final String summaryModelLabel;
  final List<String> developers;

  const DocPulseAboutDialog({
    super.key,
    this.summaryModelLabel = 'Not configured yet',
    this.developers = const [],
  });

  static Future<void> show(
    BuildContext context, {
    String summaryModelLabel = 'Not configured yet',
    List<String> developers = const [],
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => DocPulseAboutDialog(
        summaryModelLabel: summaryModelLabel,
        developers: developers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('About DocPulse'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Flutter Web text analysis and summarization app for typed text and text-based PDFs.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Text(
              'Packages & Tools',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text('• Flutter & Dart (Web)'),
            const Text('• file_picker (browser PDF selection)'),
            const Text('• pdfrx (PDFium WASM text extraction)'),
            const SizedBox(height: 14),
            Text(
              'Analysis & AI Models',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text('• Bag of Words (BOG) & TF-IDF analyzers'),
            Text('• Summarization Model: $summaryModelLabel'),
            if (developers.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Developed By',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              for (final name in developers) Text('• $name'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showLicensePage(
              context: context,
              applicationName: 'DocPulse Text Analyzer',
            );
          },
          child: const Text('Licenses'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
