import 'dart:math' as math;

import 'package:textrepresentation/services/analyzers/bag_of_words_analyzer.dart';


class TfIdfTermScore {
  const TfIdfTermScore({
    required this.term,
    required this.count,
    required this.tf,
    required this.docsContainingTerm,
    required this.idf,
    required this.tfIdf,
  });

  final String term;
  final int count;
  final double tf;
  final int docsContainingTerm;
  final double idf;
  final double tfIdf;
}

class TfIdfDocumentResult {
  const TfIdfDocumentResult({
    required this.docIndex,
    required this.rawText,
    required this.totalFilteredWords,
    required this.tfVector,
    required this.scores,
  });

  final int docIndex;
  final String rawText;
  final int totalFilteredWords;
  final List<double> tfVector;
  final List<TfIdfTermScore> scores;
}

class TfIdfResult {
  const TfIdfResult({
    required this.vocabulary,
    required this.idfVector,
    required this.docsContainingTerm,
    required this.documents,
  });

  final List<String> vocabulary;
  final List<double> idfVector;
  final List<int> docsContainingTerm;
  final List<TfIdfDocumentResult> documents;
}

class TfIdfAnalyzer {
  const TfIdfAnalyzer();

  double _log10(num value) => math.log(value) / math.ln10;

  TfIdfResult analyzeFromBow(BagOfWordsResult bowResult) {
    final vocab = bowResult.vocabulary;
    final vocabSize = vocab.length;
    final numDocs = bowResult.documents.length;

    final docsWithTerm = List<int>.filled(vocabSize, 0);
    for (int w = 0; w < vocabSize; w++) {
      int count = 0;
      for (final doc in bowResult.documents) {
        if (doc.vector[w] > 0) count++;
      }
      docsWithTerm[w] = count;
    }

    final idfVector = List<double>.generate(vocabSize, (w) {
      if (numDocs == 0 || docsWithTerm[w] == 0) return 0.0;
      return _log10(numDocs / docsWithTerm[w]);
    });

    final documents = <TfIdfDocumentResult>[];
    for (final doc in bowResult.documents) {
      final totalWords = doc.tokens.length;
      final tfVector = List<double>.filled(vocabSize, 0.0);
      final scores = <TfIdfTermScore>[];

      for (int w = 0; w < vocabSize; w++) {
        final count = doc.vector[w];
        final tf = totalWords == 0 ? 0.0 : count / totalWords;
        final idf = idfVector[w];

        tfVector[w] = tf;
        scores.add(
          TfIdfTermScore(
            term: vocab[w],
            count: count,
            tf: tf,
            docsContainingTerm: docsWithTerm[w],
            idf: idf,
            tfIdf: tf * idf,
          ),
        );
      }

      documents.add(
        TfIdfDocumentResult(
          docIndex: doc.docIndex,
          rawText: doc.rawText,
          totalFilteredWords: totalWords,
          tfVector: tfVector,
          scores: scores,
        ),
      );
    }

    return TfIdfResult(
      vocabulary: vocab,
      idfVector: idfVector,
      docsContainingTerm: docsWithTerm,
      documents: documents,
    );
  }
}