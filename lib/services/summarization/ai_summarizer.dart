import 'package:googleai_dart/googleai_dart.dart';

class AiSummarizer {
  final String apiKey;
  final String model;

  const AiSummarizer({
    required this.apiKey,
    this.model = 'gemini-3.5-flash-lite',
  });

  Future<String> summarize(String text) async {
    if (apiKey.trim().isEmpty) {
      throw StateError(
        'Missing GEMINI_API_KEY. Run with --dart-define=GEMINI_API_KEY=your_key',
      );
    }

    // Cap extreme inputs (e.g., 7k+ words) to keep requests fast and well within limits
    final trimmed = text.trim();
    final safeInput = trimmed.length > 25000
        ? '${trimmed.substring(0, 25000)}\n\n[Truncated for summary]'
        : trimmed;

    final client = GoogleAIClient(
      config: GoogleAIConfig.googleAI(
        authProvider: ApiKeyProvider(apiKey),
      ),
    );

    try {
      final response = await client.models.generateContent(
        model: model,
        request: GenerateContentRequest(
          contents: [
            Content.text(
              'Summarize the following document clearly into a concise overview followed by 3 to 5 key bullet points:\n\n$safeInput',
            ),
          ],
        ),
      );

      final summary = response.text?.trim() ?? '';
      if (summary.isEmpty) {
        throw StateError('The model returned an empty summary.');
      }
      return summary;
    } finally {
      client.close();
    }
  }
}