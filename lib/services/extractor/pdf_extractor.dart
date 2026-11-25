
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:textrepresentation/model/extracted_pdf.dart';

class PdfExtractor {
  Future<ExtractedPdf?> pickAndExtractPdf() async{
    final PlatformFile? pickedfile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (pickedfile == null) {return null;}

    final Uint8List bytes = await pickedfile.readAsBytes();
    if (bytes.isEmpty) {
      throw StateError('Unable to read PDF bytes in the browser.');
    }

    final String extractedText = await _extractTextFromBytes(bytes);

    return ExtractedPdf(
      fileName: pickedfile.name,
      bytes: bytes,
      text: extractedText, );
  }

  Future<String> _extractTextFromBytes(Uint8List bytes) async {
    await pdfrxFlutterInitialize();
    final PdfDocument doc = await PdfDocument.openData(bytes);
    try {
      final StringBuffer buffer = StringBuffer();
      for (final PdfPage page in doc.pages) {
        final pageText = await page.loadText();
        final String text = pageText?.fullText.trim() ?? '';
        if (text.isNotEmpty) {
          buffer.writeln(text);
          buffer.writeln();
        }
      }
      return buffer.toString().trim();
    } finally {
      await doc.dispose();
    }
  }
}