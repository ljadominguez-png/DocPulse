

import 'dart:typed_data';

class ExtractedPdf{
  final String fileName;
  final Uint8List bytes;
  final String text;
  const ExtractedPdf({
    required this.fileName, 
    required this.bytes, 
    required this.text});
}