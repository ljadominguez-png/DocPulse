import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class SummaryDataScreen extends StatelessWidget {
  final String? summary;
  final String? errorMessage;
  final bool isLoading;

  const SummaryDataScreen({
    super.key,
    this.summary,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Generating AI summary...'),
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      );
    }

    final text = summary;
    if (text == null || text.trim().isEmpty) {
      return const Center(child: Text('No summary generated yet.'));
    }

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Copy summary',
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Summary copied')),
                        );
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 6),
                SelectionArea(
                  child: GptMarkdown(
                    text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
