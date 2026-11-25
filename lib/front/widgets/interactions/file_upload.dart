import 'package:flutter/material.dart';

class FileUpload extends StatefulWidget {
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
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheenController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  void _updateSheenAnimation({required bool shouldAnimate}) {
    if (shouldAnimate && !_sheenController.isAnimating) {
      _sheenController.repeat();
    } else if (!shouldAnimate && _sheenController.isAnimating) {
      _sheenController.stop();
      _sheenController.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isInteractive = !widget.isUploading && !widget.isDisabled;
    final hasFile = widget.fileName != null;

    final shouldAnimateSheen =
        widget.isUploading || (_isHovered && isInteractive);
    _updateSheenAnimation(shouldAnimate: shouldAnimateSheen);

    final borderColor = hasFile
        ? colorScheme.primary.withValues(alpha: 0.65)
        : (_isHovered && isInteractive)
            ? colorScheme.primary
            : colorScheme.outlineVariant;

    final surfaceColor = hasFile
        ? colorScheme.primaryContainer.withValues(alpha: 0.24)
        : colorScheme.surfaceContainerLow;

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          (_isHovered && isInteractive) ? -1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (_isHovered && isInteractive) || hasFile ? 1.5 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: (_isHovered && isInteractive) ? 0.08 : 0.03,
              ),
              blurRadius: (_isHovered && isInteractive) ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isInteractive ? widget.onTap : null,
                  splashColor: colorScheme.primary.withValues(alpha: 0.08),
                  highlightColor: colorScheme.primary.withValues(alpha: 0.04),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slideIn = Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideIn,
                              child: child,
                            ),
                          );
                        },
                        child: _buildStateContent(
                          key: ValueKey(
                            widget.isUploading
                                ? 'uploading'
                                : hasFile
                                    ? 'file_${widget.fileName}'
                                    : 'empty',
                          ),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Wider sliding shiny light sweep
if (shouldAnimateSheen)
  Positioned.fill(
    child: IgnorePointer(
      child: AnimatedBuilder(
        animation: _sheenController,
        builder: (context, _) {
          // Smoothly sweeps from left (-1.5) to right (+1.5)
          final dx = (_sheenController.value * 3.0) - 1.5;
          return Align(
            alignment: Alignment(dx, 0),
            child: Transform.scale(
              scale: 1.8,
              child: Transform.rotate(
                angle: -0.22,
                child: SizedBox(
                  width: 240,
                  height: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          colorScheme.onSurface.withValues(alpha: 0.05),
                          colorScheme.onSurface.withValues(alpha: 0.14),
                          colorScheme.onSurface.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent({
    required Key key,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    if (widget.isUploading) {
      return Center(
        key: key,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Uploading and reading PDF...',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (widget.fileName != null) {
      return Row(
        key: key,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.fileName!,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PDF ready for analysis',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove PDF',
            onPressed: widget.isDisabled ? null : widget.onClear,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      );
    }

    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file_rounded,
              size: 26,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload your PDF file here',
            textAlign: TextAlign.center,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Click to select a text-based .pdf document',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}