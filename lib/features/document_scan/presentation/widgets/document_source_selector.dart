import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

enum DocumentSource { camera, gallery, file }

class DocumentSourceSelector extends StatelessWidget {
  final void Function(DocumentSource source, dynamic file)? onSourceSelected;
  final bool isEnabled;

  const DocumentSourceSelector({
    super.key,
    this.onSourceSelected,
    this.isEnabled = true,
  });

  Future<void> _handleCameraCapture() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      onSourceSelected?.call(DocumentSource.camera, image);
    }
  }

  Future<void> _handleGalleryPick() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      onSourceSelected?.call(DocumentSource.gallery, image);
    }
  }

  Future<void> _handleFilePick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      onSourceSelected?.call(DocumentSource.file, result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Choose Document Source',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SourceCard(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              color: colorScheme.primaryContainer,
              iconColor: colorScheme.onPrimaryContainer,
              onTap: isEnabled ? _handleCameraCapture : null,
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2),
            _SourceCard(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              color: colorScheme.secondaryContainer,
              iconColor: colorScheme.onSecondaryContainer,
              onTap: isEnabled ? _handleGalleryPick : null,
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2),
            _SourceCard(
              icon: Icons.picture_as_pdf_rounded,
              label: 'File',
              color: colorScheme.tertiaryContainer,
              iconColor: colorScheme.onTertiaryContainer,
              onTap: isEnabled ? _handleFilePick : null,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideX(begin: 0.2),
          ],
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: onTap != null ? color : color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: onTap != null ? iconColor : iconColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: onTap != null
                           ? iconColor
                           : iconColor.withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
