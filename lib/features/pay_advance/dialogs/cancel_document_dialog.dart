import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/pa_document.dart';

/// Shows the PA (and its linked CP document, if any) with a two-step
/// delete button for each. [onCancelDocument] is called with the doc number.
Future<void> showCancelDocumentDialog(
  BuildContext context, {
  required PaDocument document,
  required Future<void> Function(String docNo) onCancelDocument,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CancelDocumentDialog(document: document, onCancelDocument: onCancelDocument),
  );
}

class _CancelDocumentDialog extends StatelessWidget {
  const _CancelDocumentDialog({required this.document, required this.onCancelDocument});

  final PaDocument document;
  final Future<void> Function(String docNo) onCancelDocument;

  @override
  Widget build(BuildContext context) {
    final cpDocNo = document.cpDocNo;
    final width = MediaQuery.sizeOf(context).width;

    Widget section(String docNo) => _DocSection(
          docNo: docNo,
          amount: document.amount,
          onConfirm: () async {
            await onCancelDocument(docNo);
            if (context.mounted) Navigator.pop(context);
          },
        );

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width * (cpDocNo != null ? 0.5 : 0.3),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    document.customerLabel,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.black12),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: section(document.runNo)),
                  if (cpDocNo != null) ...[
                    const VerticalDivider(width: 40, thickness: 1, color: Colors.black12),
                    Expanded(child: section(cpDocNo)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _DeleteStep { idle, confirming, deleting }

class _DocSection extends StatefulWidget {
  const _DocSection({required this.docNo, required this.amount, required this.onConfirm});

  final String docNo;
  final double amount;
  final Future<void> Function() onConfirm;

  @override
  State<_DocSection> createState() => _DocSectionState();
}

class _DocSectionState extends State<_DocSection> {
  _DeleteStep _step = _DeleteStep.idle;

  Future<void> _confirm() async {
    setState(() => _step = _DeleteStep.deleting);
    try {
      await widget.onConfirm();
    } catch (e) {
      debugPrint('Cancel ${widget.docNo} failed: $e');
      if (mounted) setState(() => _step = _DeleteStep.confirming);
    }
  }

  @override
  Widget build(BuildContext context) {
    final danger = Colors.red.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: danger),
                  const SizedBox(width: 6),
                  Text(widget.docNo, style: TextStyle(fontSize: 18, fontFamily: AppFonts.trajanProBold, color: danger)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: switch (_step) {
                _DeleteStep.idle => IconButton(
                    key: const ValueKey('delete'),
                    tooltip: 'Delete ${widget.docNo}',
                    onPressed: () => setState(() => _step = _DeleteStep.confirming),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade600, size: 20),
                    ),
                  ),
                _DeleteStep.confirming => Row(
                    key: const ValueKey('confirm'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('ยืนยันลบ?', style: TextStyle(fontSize: 14, color: danger, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _RoundButton(icon: Icons.check_rounded, color: Colors.red.shade600, iconColor: Colors.white, onTap: _confirm),
                      const SizedBox(width: 6),
                      _RoundButton(
                        icon: Icons.close_rounded,
                        color: Colors.grey.shade200,
                        iconColor: Colors.black54,
                        onTap: () => setState(() => _step = _DeleteStep.idle),
                      ),
                    ],
                  ),
                _DeleteStep.deleting => Row(
                    key: const ValueKey('deleting'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.red.shade400, strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text('กำลังลบ...', style: TextStyle(fontSize: 14, color: danger, fontWeight: FontWeight.bold)),
                    ],
                  ),
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('จำนวนเงิน', style: TextStyle(fontSize: 14, color: Colors.black54)),
              Text(
                Fmt.money(widget.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: AppFonts.trajanProBold,
                  color: widget.amount > 0 ? Colors.green.shade700 : danger,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.color, required this.iconColor, required this.onTap});

  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
