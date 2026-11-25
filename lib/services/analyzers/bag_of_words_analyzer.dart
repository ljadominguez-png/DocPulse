

import 'package:textrepresentation/services/analyzers/tokenizer.dart';

class BagOfWordsDocument {
  const BagOfWordsDocument({
    required this.docIndex,
    required this.rawText,
    required this.tokens,
    required this.vector,
  });

  final int docIndex;
  final String rawText;
  final List<String> tokens;
  final List<int> vector;
}

class BagOfWordsResult {
  const BagOfWordsResult({
    required this.vocabulary,
    required this.documents,
  });

  final List<String> vocabulary;
  final List<BagOfWordsDocument> documents;
}

class BagOfWordsAnalyzer {
  final TextTokenizer tokenizer;

  const BagOfWordsAnalyzer({this.tokenizer = const TextTokenizer()});

  BagOfWordsResult analyze(List<String> docs) {
    final tokenizedDocs = docs.map(tokenizer.tokenize).toList();

    final vocabSet = <String>{};
    for (final tokens in tokenizedDocs) {
      vocabSet.addAll(tokens);
    }

    final vocabulary = vocabSet.toList()..sort();
    final indexByTerm = <String, int>{
      for (int i = 0; i < vocabulary.length; i++) vocabulary[i]: i,
    };

    final documents = <BagOfWordsDocument>[];
    for (int d = 0; d < docs.length; d++) {
      final vector = List<int>.filled(vocabulary.length, 0);
      for (final token in tokenizedDocs[d]) {
        final idx = indexByTerm[token];
        if (idx != null) {
          vector[idx]++;
        }
      }

      documents.add(
        BagOfWordsDocument(
          docIndex: d,
          rawText: docs[d],
          tokens: tokenizedDocs[d],
          vector: vector,
        ),
      );
    }

    return BagOfWordsResult(
      vocabulary: vocabulary,
      documents: documents,
    );
  }
}