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

  final trimmed = text.trim();
  final safeInput = trimmed.length > 25000
      ? '${trimmed.substring(0, 25000)}\n\n[Truncated for summary]'
      : trimmed;

  final client = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      authProvider: ApiKeyProvider(apiKey),
    ),
  );

  // Try primary model first, then fallback models if Google's servers return 503
  final modelsToTry = [
    model,
    if (model != 'gemini-2.5-flash') 'gemini-2.5-flash',
    if (model != 'gemini-2.0-flash') 'gemini-2.0-flash',
  ];

  try {
    Object? lastError;
    for (final currentModel in modelsToTry) {
      try {
        final response = await client.models.generateContent(
          model: currentModel,
          request: GenerateContentRequest(
            contents: [
              Content.text(
                'Summarize the following document clearly into a concise overview followed by 3 to 5 key bullet points:\n\n$safeInput',
              ),
            ],
          ),
        );

        final summary = response.text?.trim() ?? '';
        if (summary.isNotEmpty) return summary;
      } catch (e) {
        lastError = e;
        if (!e.toString().contains('503')) rethrow;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    throw StateError(
      'The AI summarization service is temporarily overloaded (503). Please try again in a moment. ($lastError)',
    );
  } finally {
    client.close();
  }
}
}