import java.util.*;

public class BagOfWords {

    public static void main(String[] args) {

        Scanner input = new Scanner(System.in);

        // Ask the user how many documents they want to enter
        System.out.print("How many documents/sentences? ");
        int numDocs = Integer.parseInt(input.nextLine().trim());

        // Let the user type each document
        String[] docs = new String[numDocs];
        for (int i = 0; i < numDocs; i++) {
            System.out.print("Enter Doc " + (i + 1) + ": ");
            docs[i] = input.nextLine();
        }

        // Stop words: common words that carry little meaning (you can add more)
        Set<String> stopWords = new HashSet<>(Arrays.asList(
            "a", "an", "the", "is", "am", "are", "was", "were", "be", "been",
            "and", "or", "but", "if", "of", "to", "in", "on", "at", "by",
            "for", "with", "as", "it", "its", "this", "that", "these", "those",
            "i", "you", "he", "she", "we", "they", "me", "him", "her", "us", "them",
            "my", "your", "his", "our", "their", "do", "does", "did", "has", "have", "had"
        ));

        // Tokenize: lowercase, remove punctuation, split, remove stop words
        List<String[]> tokenized = new ArrayList<>();
        for (String doc : docs) {
            String clean = doc.toLowerCase().replaceAll("[^a-z0-9\\s]", "").trim();
            List<String> words = new ArrayList<>();
            if (!clean.isEmpty()) {
                for (String word : clean.split("\\s+")) {
                    if (!stopWords.contains(word)) {
                        words.add(word);
                    }
                }
            }
            tokenized.add(words.toArray(new String[0]));
        }

        System.out.println("\n After Stop Word Removal");
        for (int d = 0; d < numDocs; d++) {
            System.out.println("Doc " + (d + 1) + ": " + Arrays.toString(tokenized.get(d)));
        }

        // Master Vocabulary Index (TreeSet = unique + alphabetical)
        TreeSet<String> vocabSet = new TreeSet<>();
        for (String[] tokens : tokenized) {
            vocabSet.addAll(Arrays.asList(tokens));
        }
        List<String> vocab = new ArrayList<>(vocabSet);
        int vocabSize = vocab.size();

        System.out.println("\nMaster Vocabulary Index");
        System.out.println("Alphabetical sorting gives a fixed " + vocabSize + "-dimensional feature space.");
        for (int i = 0; i < vocabSize; i++) {
            System.out.println("Index " + i + " : " + vocab.get(i));
        }

        // Frequency Vectorization (Bag of Words)
        int[][] bow = new int[numDocs][vocabSize];
        for (int d = 0; d < numDocs; d++) {
            for (String word : tokenized.get(d)) {
                bow[d][vocab.indexOf(word)]++;
            }
        }

        System.out.println("\nFrequency Vectorization (Bag of Words)");
        for (int d = 0; d < numDocs; d++) {
            System.out.println("Doc " + (d + 1) + " \"" + docs[d] + "\"");
            System.out.println("   Vector: " + Arrays.toString(bow[d]));
        }


        // STEP 1: Term Frequency  TF = Term Count / Total Words in Doc
        double[][] tf = new double[numDocs][vocabSize];
        int[] totalWords = new int[numDocs];

        System.out.println("\n STEP 1: Term Frequency (TF)");
        System.out.println("TF = Term Count / Total Words in Doc");
        printHeader("Document", vocab);
        for (int d = 0; d < numDocs; d++) {
            totalWords[d] = tokenized.get(d).length;
            System.out.printf("%-14s", "Doc " + (d + 1));
            for (int w = 0; w < vocabSize; w++) {
                tf[d][w] = totalWords[d] == 0 ? 0 : (double) bow[d][w] / totalWords[d];
                System.out.printf("%-26s", bow[d][w] + "/" + totalWords[d] + " = " + String.format("%.3f", tf[d][w]));
            }
            System.out.println();
        }

        // STEP 2: Inverse Document Frequency  IDF = log10(Total Docs / Docs Containing Term)
        double[] idf = new double[vocabSize];

        System.out.println("\nSTEP 2: Inverse Document Frequency (IDF) ");
        System.out.println("IDF = log(Total Docs / Docs Containing Term)");
        System.out.printf("%-14s%-12s%-16s%-18s%-10s%n",
                "Term", "Total Docs", "Docs with Term", "IDF Calculation", "Final IDF");
        for (int w = 0; w < vocabSize; w++) {
            int docsWithTerm = 0;
            for (int d = 0; d < numDocs; d++) {
                if (bow[d][w] > 0) docsWithTerm++;
            }
            idf[w] = Math.log10((double) numDocs / docsWithTerm);
            System.out.printf("%-14s%-12d%-16d%-18s%-10.3f%n",
                    vocab.get(w), numDocs, docsWithTerm,
                    "log(" + numDocs + " / " + docsWithTerm + ")", idf[w]);
        }

        // STEP 3: TF-IDF Matrix  TF-IDF = TF x IDF
        System.out.println("\nSTEP 3: The TF-IDF Matrix");
        System.out.println("TF-IDF = TF x IDF");
        List<String> headerWithIdf = new ArrayList<>();
        for (int w = 0; w < vocabSize; w++) {
            headerWithIdf.add(vocab.get(w) + "(IDF:" + String.format("%.3f", idf[w]) + ")");
        }
        printHeader("Document", headerWithIdf);
        for (int d = 0; d < numDocs; d++) {
            System.out.printf("%-14s", "Doc " + (d + 1));
            for (int w = 0; w < vocabSize; w++) {
                double value = tf[d][w] * idf[w];
                String cell = String.format("%.3f x %.3f = %.3f", tf[d][w], idf[w], value);
                System.out.printf("%-26s", cell);
            }
            System.out.println();
        }

        input.close();
    }

    // Prints a header row (first column + one column per term)
    static void printHeader(String first, List<String> terms) {
        System.out.printf("%-14s", first);
        for (String t : terms) {
            System.out.printf("%-26s", t);
        }
        System.out.println();
    }
}