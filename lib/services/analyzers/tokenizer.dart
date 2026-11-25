class TextTokenizer {
  static const Set<String> defaultStopWords = {
    'a', 'an', 'the', 'is', 'am', 'are', 'was', 'were', 'be', 'been',
    'and', 'or', 'but', 'if', 'of', 'to', 'in', 'on', 'at', 'by',
    'for', 'with', 'as', 'it', 'its', 'this', 'that', 'these', 'those',
    'i', 'you', 'he', 'she', 'we', 'they', 'me', 'him', 'her', 'us', 'them',
    'my', 'your', 'his', 'our', 'their', 'do', 'does', 'did', 'has', 'have', 'had',
  };

  final Set<String> stopWords;

  const TextTokenizer({this.stopWords = defaultStopWords});

  List<String> splitIntoDocuments(String rawInput) {
    return rawInput
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  List<String> tokenize(String text) {
    final cleaned = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim();
    if (cleaned.isEmpty) return const [];

    return cleaned
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !stopWords.contains(word))
        .toList();
  }
}