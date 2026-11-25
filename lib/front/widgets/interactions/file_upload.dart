import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUpload extends StatelessWidget {
  final String? fileName;
  final bool isUploading;
  final bool isDisabled;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const FileUpload({
    super.key,
    this.fileName,
    required this.isUploading,
    required this.isDisabled,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = !isUploading && !isDisabled;
    return Material(
      color: ThemeData().colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
        side: BorderSide(
          color: ThemeData().colorScheme.onSurfaceVariant,
          width: 1.2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        mouseCursor: isInteractive
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onTap: isInteractive ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: isUploading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    SizedBox(width: 12),
                    Text('Uploading and reading PDF...'),
                  ],
                )
              : fileName != null
              ? Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: ThemeData().colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName!,
                        overflow: TextOverflow.ellipsis,
                        style: ThemeData().textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove PDF',
                      onPressed: isDisabled ? null : onClear,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 32,
                      color: ThemeData().colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload your PDF file here',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to select a .pdf document',
                      style: ThemeData().textTheme.bodySmall?.copyWith(
                        color: ThemeData().colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
