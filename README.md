# DocPulse Text Analyzer — Project & Development Documentation

## 1. Project Overview

**DocPulse Text Analyzer** is a Flutter Web application designed to take typed text or text-based PDF documents, perform classical text representation and analysis (Bag of Words and TF-IDF), and generate concise AI summaries.

* **Target Platform:** Flutter Web (Chrome)
* **Input Modes:** Manual text entry via text field and `.pdf` file upload (text-based PDFs; scanned/image-only OCR PDFs are out of scope)
* **Core Outputs:**
* **Bag of Words (BOG):** Stop-word filtering, sorted master vocabulary index, and term occurrence count vectors
* **TF-IDF:** Term Frequency ($\text{TF}$), Inverse Document Frequency ($\text{IDF}$ using $\log_{10}$), and weighted $\text{TF-IDF}$ scores
* **AI Summary:** Overview and key bullet points generated from the input document text


* **License:** MIT License

---

## 2. Tools, Packages & AI Models Used

| Category | Tool / Package / Model | Role in DocPulse |
| --- | --- | --- |
| **UI & Language** | Flutter & Dart (Web) | Cross-platform UI components, state handling, and pure Dart analysis logic |
| **File Selection** | `file_picker` | Opens the browser file dialog for `.pdf` selection and reads file bytes (`Uint8List`) in memory |
| **PDF Text Extraction** | `pdfrx` (PDFium WASM) | Opens in-memory PDF bytes in the browser, extracts page text, and disposes documents cleanly |
| **Text Representation** | Custom Tokenizer, BOG & TF-IDF Analyzers | Lowercases, strips punctuation, filters stop words, builds vocabulary/vectors, and computes $\text{TF}$, $\text{IDF}$, and $\text{TF-IDF}$ |
| **AI Summarization** | `googleai_dart` + `gemini-3.5-flash-lite` | Sends cleaned input text to Gemini via Google AI Studio API key (`--dart-define=GEMINI_API_KEY=...`) |
| **Licensing & Attribution** | MIT `LICENSE` + Modular About Dialog | Documents project licensing, contributors, packages, and AI model in-app |

---

## 3. Architecture & File Structure

* **Presentation Layer (`Frontpage` & Widgets):**
* `DocumentField`: Multiline text input (`TextEditingController` + `onChanged` updates)
* `FileUpload`: Upload trigger, loading spinner state, active PDF filename display, and clear action
* `Button`: Action trigger for running analysis (`_handleAnalyzer`)
* `TabBar` & `TabBarView`: Switches between **BOG**, **TF-IDF**, and **Summary** result screens
* `DocPulseAboutDialog`: Separate dialog component displaying project info, contributors, packages, and the summarization model


* **Data Models:**
* `ExtractedPdf`: Holds picked `fileName`, raw `bytes` (`Uint8List`), and extracted `text`


* **Service Layer:**
* `PdfExtractor`: Picks `.pdf` files and extracts text via `pdfrx` in the browser
* Text tokenizer, `BagOfWordsAnalyzer`, and `TfIdfAnalyzer`: Pure Dart implementations translating the original Java `BagOfWords` algorithm
* `AiSummarizer`: Wraps `googleai_dart` calls and handles input truncation, empty checks, and client cleanup



---

## 4. How AI Assistance Was Used to Build the App

Throughout development, the AI assistant acted as a collaborative coding, debugging, and architectural pair across every stage of the project:

1. **Scope & Architecture Planning:**
* Helped narrow target platforms to **Flutter Web** after evaluating cross-platform file/PDF constraints, avoiding mobile-only or native desktop build overhead.
* Separated file picking/extraction, text analyzers, AI summarization, result tabs, and the About dialog into modular files so UI components stayed clean and maintainable.


2. **File Picker & PDF WASM Troubleshooting:**
* Adapted `file_picker` usage to match modern static/byte-based APIs (`pickFile` / `readAsBytes`) without relying on local OS paths.
* Diagnosed `FileUpload` loading-state issues (such as checking `isInteractive` instead of `isUploading` for the spinner) and traced `pdfrx` browser console/network 404 errors on `pdfium_client.js` to stale Web asset bundles requiring a clean restart.


3. **Java-to-Dart Porting & Performance Tuning:**
* Translated the Java `BagOfWords` logic (stop-word removal, sorted vocabulary, frequency vectors, $\text{TF}$, $\log_{10}$ $\text{IDF}$, and $\text{TF-IDF}$ matrix) into modular Dart analyzers (`BagOfWordsAnalyzer` and `TfIdfAnalyzer`).
* Fixed stale tab rendering (`_resultsTabs` initialized once with `null` results instead of rebuilding with updated state) and optimized heavy multi-thousand-word runs (~7,000+ words / ~2,126 unique terms) by pre-computing ranked/indexed data and capping visual previews in the UI.


4. **AI Summary & Documentation Integration:**
* Clarified that summarization models take **document text** rather than BOG/TF-IDF vectors, and wired `AiSummarizer` (`googleai_dart` + `gemini-3.5-flash-lite`) into `SummaryDataScreen` with `--dart-define=GEMINI_API_KEY=...` configuration, copy support, and loading/error states.
* Helped structure the modular About dialog, MIT license setup, and this project documentation.



---

## 5. Running & Configuration Notes

* **Run with API Key (Flutter Web):**
```bash
flutter run -d chrome --dart-define=GEMINI_API_KEY=YOUR_API_KEY

```


* **Security Reminder:** Do not commit real API keys into source files or tracked `.vscode/launch.json` configurations.
* **Known Limitations:** Scanned/image-only PDFs without embedded text return empty extracted text; very large documents are truncated before summarization to keep responses fast and reliable.