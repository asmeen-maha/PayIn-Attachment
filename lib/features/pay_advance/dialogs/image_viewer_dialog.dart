import 'package:flutter/material.dart';

/// Full-screen, zoomable image. Tap anywhere to close.
Future<void> showImageViewer(BuildContext context, String imageUrl) {
  return showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported_rounded, size: 100, color: Colors.grey),
            ),
          ),
        ),
      ),
    ),
  );
}
