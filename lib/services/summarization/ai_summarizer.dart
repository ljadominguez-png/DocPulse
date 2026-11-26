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
      if (model != 'gemini-3.6-flash') 'gemini-3.6-flash',
      if (model != 'gemini-3.1-flash-lite') 'gemini-3.1-flash-lite',
    ];

    try {
      String? lastSafeError;

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
          final safeMessage = _formatSafeError(e);
          lastSafeError = safeMessage;

          final raw = e.toString();
          final isOverloaded =
              raw.contains('503') || raw.toUpperCase().contains('UNAVAILABLE');
          if (!isOverloaded) {
            throw StateError(safeMessage);
          }

          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }

      throw StateError(
        lastSafeError ??
            'The AI summarization service is temporarily overloaded (503). Please try again in a moment.',
      );
    } on StateError {
      rethrow;
    } catch (e) {
      throw StateError(_formatSafeError(e));
    } finally {
      client.close();
    }
  }

  String _formatSafeError(Object error) {
    var message = error.toString();

    // Scrub configured apiKey and any query/header/token key patterns
    if (apiKey.trim().isNotEmpty) {
      message = message.replaceAll(apiKey.trim(), '[REDACTED]');
    }
    message = message.replaceAll(
      RegExp(r'([?&]key=)[^&\s\)\]]+', caseSensitive: false),
      r'$1[REDACTED]',
    );
    message = message.replaceAll(
      RegExp(r'\bAIza[0-9A-Za-z\-_]{10,}\b'),
      '[REDACTED_KEY]',
    );
    message = message.replaceAll(
      RegExp(r'\bAQ\.[0-9A-Za-z\-_]{10,}\b'),
      '[REDACTED_KEY]',
    );

    // Strip verbose Request URL / headers block if an exception includes it
    final requestIndex = message.indexOf('Request:');
    if (requestIndex != -1) {
      message = message.substring(0, requestIndex).trim();
    }

    if (message.contains('503') ||
        message.toUpperCase().contains('UNAVAILABLE')) {
      return 'The AI model is temporarily experiencing high demand (503). Please try again in a moment.';
    }
    if (message.contains('429')) {
      return 'Rate limit reached (429). Please wait a few seconds before summarizing again.';
    }
    if (message.contains('401') || message.contains('403')) {
      return 'API authentication failed. Check that GEMINI_API_KEY is valid and permitted.';
    }

    return message.isEmpty
        ? 'An unexpected error occurred while generating the summary.'
        : message;
  }
}