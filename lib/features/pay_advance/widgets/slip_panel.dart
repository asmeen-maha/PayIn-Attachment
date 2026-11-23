import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/network_picture/network_picture.dart';
import '../../../data/models/pa_document.dart';
import '../dialogs/image_viewer_dialog.dart';
import 'document_card.dart' show VerifyButton;

/// Right glass panel: document amount + verify button above the slip,
/// so the amount and the slip can be compared without moving the eyes far.
class SlipPanel extends StatefulWidget {
  const SlipPanel({super.key, required this.document, required this.canVerify, required this.onVerify});

  final PaDocument? document;
  final bool canVerify;
  final VoidCallback onVerify;

  @override
  State<SlipPanel> createState() => _SlipPanelState();
}

class _SlipPanelState extends State<SlipPanel> {
  double _scale = 1;

  @override
  void didUpdateWidget(SlipPanel old) {
    super.didUpdateWidget(old);
    if (old.document?.runNo != widget.document?.runNo) _scale = 1;
  }

  void _setScale(double scale) => setState(() => _scale = scale.clamp(1.0, 4.0));

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return GlassPanel(
      padding: const EdgeInsets.all(14),
      child: doc == null
          ? const EmptyState(icon: Icons.receipt_long_outlined, message: 'ยังไม่ได้เลือกเอกสาร', hint: 'เลือกการ์ดเพื่อดูสลิป')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(doc),
                const SizedBox(height: 12),
                _amountBox(doc),
                const SizedBox(height: 12),
                Expanded(child: _stage(doc)),
                const SizedBox(height: 8),
                Text(
                  doc.slipIsPdf ? 'แตะเพื่อเปิด PDF ในแท็บใหม่' : 'แตะสลิปเพื่อดูเต็มจอ · ปุ่ม + / − เพื่อซูม แล้วลากเพื่อเลื่อน',
                  textAlign: TextAlign.center,
                  style: AppText.muted(11),
                ),
              ],
            ),
    );
  }

  Widget _header(PaDocument doc) {
    final fileName = doc.hasSlip ? Uri.decodeFull(doc.slipUrl!.split('/').last) : 'ไม่มีไฟล์แนบ';
    final canZoom = doc.hasSlip && !doc.slipIsPdf;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สลิปโอนเงิน', style: AppText.display(14)),
              Text('${doc.runNo} · $fileName', style: AppText.muted(11.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (canZoom)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.glassStrong,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                _zoomButton(Icons.remove_rounded, () => _setScale(_scale - .5)),
                SizedBox(width: 40, child: Text('${(_scale * 100).round()}%', textAlign: TextAlign.center, style: AppText.muted(11.5))),
                _zoomButton(Icons.add_rounded, () => _setScale(_scale + .5)),
                _zoomButton(Icons.open_in_full_rounded, () => showImageViewer(context, doc.slipUrl!)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _zoomButton(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(width: 26, height: 26, child: Icon(icon, size: 15, color: AppColors.ink)),
      );

  Widget _amountBox(PaDocument doc) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.85), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ยอดในเอกสาร', style: AppText.muted(11)),
                Text(
                  Fmt.baht(doc.amount),
                  style: AppText.display(20, color: doc.amount <= 0 ? AppColors.danger : AppColors.ink),
                ),
              ],
            ),
          ),
          VerifyButton(verified: doc.isVerified, enabled: widget.canVerify, onPressed: widget.onVerify, large: true),
        ],
      ),
    );
  }

  Widget _stage(PaDocument doc) {
    final url = doc.slipUrl;
    final Widget content;

    if (url == null || url.isEmpty) {
      content = const EmptyState(icon: Icons.image_not_supported_outlined, message: 'ไม่มีสลิป');
    } else if (doc.slipIsPdf) {
      content = _PdfCard(onOpen: () => _openInNewTab(url));
    } else {
      // NetworkPicture: plain <img> on web, so the slip server needs no CORS.
      content = NetworkPicture(
        url: url,
        zoom: _scale,
        // Only open the full-screen viewer from the fitted view; when zoomed,
        // clicks are used for dragging the image around.
        onTap: _scale > 1 ? null : () => showImageViewer(context, url),
        loading: const LoadingIndicator(size: 36),
        errorBuilder: (_) => const EmptyState(icon: Icons.broken_image_outlined, message: 'โหลดรูปสลิปไม่สำเร็จ'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(color: AppColors.tint, child: content),
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

class _PdfCard extends StatelessWidget {
  const _PdfCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.picture_as_pdf_rounded, size: 32, color: AppColors.danger),
                ),
                const SizedBox(height: 14),
                Text('สลิปรูปแบบ PDF', style: AppText.display(15)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('เปิดดูเอกสาร', style: AppText.body(12.5, weight: FontWeight.w600, color: AppColors.accent)),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.accent),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
