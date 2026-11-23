import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_fonts.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/pa_document.dart';
import '../dialogs/image_viewer_dialog.dart';

/// Right column: the payment slip of the selected document (image or PDF).
class SlipPanel extends StatelessWidget {
  const SlipPanel({super.key, required this.document});

  final PaDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final url = document.slipUrl;
    if (url == null || url.isEmpty) {
      return const EmptyState(icon: Icons.image_not_supported_rounded, message: 'ไม่มีสลิป');
    }
    if (document.slipIsPdf) {
      return _PdfSlipCard(onOpen: () => _openInNewTab(url));
    }
    return GestureDetector(
      onTap: () => showImageViewer(context, url),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const EmptyState(icon: Icons.broken_image_rounded, message: 'โหลดรูปสลิปไม่สำเร็จ'),
      ),
    );
  }

  Future<void> _openInNewTab(String url) async {
    try {
      await launchUrl(Uri.parse(Uri.encodeFull(url)), webOnlyWindowName: '_blank');
    } catch (e) {
      debugPrint('ไม่สามารถเปิดไฟล์ PDF ได้: $e');
    }
  }
}

class _PdfSlipCard extends StatelessWidget {
  const _PdfSlipCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade200.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.picture_as_pdf_rounded, size: 40, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                'สลิปรูปแบบ PDF',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade800, fontFamily: AppFonts.pgVim),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('แตะเพื่อเปิดดูเอกสาร', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
