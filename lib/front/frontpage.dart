import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:textrepresentation/front/widgets/interactions/button.dart';
import 'package:textrepresentation/front/widgets/interactions/document_field.dart';
import 'package:textrepresentation/front/widgets/interactions/file_upload.dart';
import 'package:textrepresentation/front/widgets/screens/about_dialog.dart';
import 'package:textrepresentation/front/widgets/screens/bog_data.dart';
import 'package:textrepresentation/front/widgets/screens/quick_stat_card.dart';
import 'package:textrepresentation/front/widgets/screens/summary_data.dart';
import 'package:textrepresentation/front/widgets/screens/tf_idf.dart';
import 'package:textrepresentation/model/extracted_pdf.dart';
import 'package:textrepresentation/services/analyzers/bag_of_words_analyzer.dart';
import 'package:textrepresentation/services/analyzers/tfidf_analyzer.dart';
import 'package:textrepresentation/services/analyzers/tokenizer.dart';
import 'package:textrepresentation/services/extractor/pdf_extractor.dart';
import 'package:textrepresentation/services/summarization/ai_summarizer.dart';
import 'package:textrepresentation/theme/theme_controller.dart';

final TextTokenizer _tokenizer = const TextTokenizer();
final BagOfWordsAnalyzer _bowAnalyzer = const BagOfWordsAnalyzer();
final TfIdfAnalyzer _tfIdfAnalyzer = const TfIdfAnalyzer();
final AiSummarizer _summarizer = const AiSummarizer(
  apiKey: String.fromEnvironment('GEMINI_API_KEY'),
);
String? _summaryText;
String? _summaryError;
BagOfWordsResult? _bowResult;
TfIdfResult? _tfIdfResult;

class Frontpage extends StatefulWidget {
  const Frontpage({super.key});

  @override
  State<Frontpage> createState() => _FrontpageState();
}

class _FrontpageState extends State<Frontpage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController _textController = TextEditingController();
  final PdfExtractor _pdfExtractor = PdfExtractor();
  String? _uploadedFileName;
  String _extractedPdfText = '';
  bool _isUploading = false;
  bool _isAnalyzing = false;
  bool _hasResults = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _clearUploadedPdf() {
    setState(() {
      _uploadedFileName = null;
      _extractedPdfText = '';
    });
  }

  //Future placeholder for file upload
  Future<void> _handlePdfUpload() async {
    if (_isUploading || _isAnalyzing) return;

    setState(() => _isUploading = true);

    try {
      final ExtractedPdf? pdf = await _pdfExtractor.pickAndExtractPdf();
      if (!mounted || pdf == null) return;

      final String cleanedText = pdf.text.trim();
      if (cleanedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No selectable text found in this PDF. Try another PDF or enter text manually.',
            ),
          ),
        );
        return;
      }

      setState(() {
        _uploadedFileName = pdf.fileName;
        _extractedPdfText = cleanedText;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to extract PDF: $e')));
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  //future placeholder for textfield analyzer
  Future<void> _handleAnalyzer() async {
    if (_isUploading || _isAnalyzing) return;
    final rawText = _textController.text.trim();
    final pdfText = _extractedPdfText.trim();

    final combinedText = [
      if (rawText.isNotEmpty) rawText,
      if (pdfText.isNotEmpty) pdfText,
    ].join('\n\n');
    if (combinedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter text or upload a text-based PDF before analyzing.',
          ),
        ),
      );
      return;
    }
    setState(() => _isAnalyzing = true);
    try {
      final docs = _tokenizer.splitIntoDocuments(combinedText);
      final bowResult = _bowAnalyzer.analyze(docs);
      final tfIdfResult = _tfIdfAnalyzer.analyzeFromBow(bowResult);

      if (!mounted) return;
      setState(() {
        _bowResult = bowResult;
        _tfIdfResult = tfIdfResult;
        _hasResults = true;
      });
      try {
        final summary = await _summarizer.summarize(combinedText);
        if (!mounted) return;
        setState(() => _summaryText = summary);
      } catch (e) {
        if (!mounted) return;
        setState(() => _summaryError = 'Summary failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> resultsTabs = [
      BagofWordsScreen(result: _bowResult),
      TfIdfscreen(result: _tfIdfResult),
      SummaryDataScreen(
        summary: _summaryText,
        errorMessage: _summaryError,
        isLoading: _isAnalyzing && _summaryText == null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("DocPulse Text Analyzer"),
        titleSpacing: 20,
        actionsPadding: const EdgeInsets.only(right: 12),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: AppThemeController.mode,
            builder: (context, currentMode, _) {
              final isDark =
                  currentMode == ThemeMode.dark ||
                  (currentMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              return IconButton(
                tooltip: isDark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon),
                onPressed: () => AppThemeController.toggle(!isDark),
              );
            },
          ),
          IconButton(
            tooltip: 'About & Tools Used',
            icon: const Icon(Icons.info_outline),
            onPressed: () => DocPulseAboutDialog.show(
              context,
              summaryModelLabel: 'Gemini',
              developers: const [
                'Dominguez, Laurence Jhon A.',
                'Fieldad, Gabriel Joseph',
                'Subere, Christian Lloyd A.',
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DocumentField(
                  controller: _textController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                FileUpload(
                  fileName: _uploadedFileName,
                  isUploading: _isUploading,
                  isDisabled: _isAnalyzing,
                  onTap: _handlePdfUpload, //pdf uploader
                  onClear: _clearUploadedPdf, // clearUploadedPDF
                ),
                const SizedBox(height: 10),
                //analyze button
                Button(
                  buttonLabel: _isAnalyzing ? 'Analyze...' : 'Analyze',
                  enablebackground: true,
                  enableBorder: true,
                  enableBold: true,
                  onTap: (_isUploading || _isAnalyzing)
                      ? () {}
                      : _handleAnalyzer,
                ),

                const SizedBox(height: 10),
                if (_bowResult != null) ...[
                  QuickStatsCard(result: _bowResult),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: ThemeData().dividerColor,
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'BOG'),
                    Tab(text: 'TF-IDF'),
                    Tab(text: 'Summary'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    controller: _tabController,
                    children: resultsTabs,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
