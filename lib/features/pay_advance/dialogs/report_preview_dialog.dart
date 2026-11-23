import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';

/// Print/share preview of a generated PDF.
Future<void> showReportPreview(BuildContext context, {required Uint8List pdf, required String fileName}) {
  final size = MediaQuery.sizeOf(context);

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: size.width * .7,
        height: size.height * .9,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
        child: PdfPreview(
          pdfFileName: fileName,
          allowPrinting: true,
          allowSharing: true,
          canDebug: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          dynamicLayout: true,
          actionBarTheme: const PdfActionBarTheme(backgroundColor: AppColors.accent),
          loadingWidget: LoadingAnimationWidget.hexagonDots(color: AppColors.accent, size: 60),
          build: (_) => pdf,
          onError: (_, __) => const Center(child: Text('เกิดข้อผิดพลาด', style: TextStyle(fontSize: 18))),
        ),
      ),
    ),
  );
}
