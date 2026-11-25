import 'package:flutter/material.dart';

class DocumentField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;
  const DocumentField({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 7,
      minLines: 5,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Input Text',
        hintText: 'Paste or type your document text here...',
        alignLabelWithHint: true,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        )
      ),
    );
  }
}