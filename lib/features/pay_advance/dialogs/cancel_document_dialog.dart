import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/pa_document.dart';

/// One dialog that lists the PA and its linked CP document (if any).
/// Each can be ticked separately; both are ticked by default.
Future<void> showCancelDocumentDialog(
  BuildContext context, {
  required PaDocument document,
  required Future<void> Function(List<String> docNos) onCancel,
}) {
  return showDialog(
    context: context,
    barrierColor: AppColors.ink.withOpacity(.30),
    builder: (_) => _CancelDocumentDialog(document: document, onCancel: onCancel),
  );
}

class _CancelDocumentDialog extends StatefulWidget {
  const _CancelDocumentDialog({required this.document, required this.onCancel});

  final PaDocument document;
  final Future<void> Function(List<String> docNos) onCancel;

  @override
  State<_CancelDocumentDialog> createState() => _CancelDocumentDialogState();
}

class _CancelDocumentDialogState extends State<_CancelDocumentDialog> {
  late final Map<String, bool> _selected = {
    widget.document.runNo: true,
    if (widget.document.cpDocNo != null) widget.document.cpDocNo!: true,
  };
  bool _deleting = false;
  String? _error;

  List<String> get _chosen => [for (final e in _selected.entries) if (e.value) e.key];

  Future<void> _confirm() async {
    setState(() {
      _deleting = true;
      _error = null;
    });
    try {
      await widget.onCancel(_chosen);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint('Cancel documents failed: $e');
      if (mounted) {
        setState(() {
          _deleting = false;
          _error = 'ลบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final warnings = [
      if (doc.amount <= 0) 'ยอดเอกสารเป็น 0.00',
      if (!doc.hasSlip) 'ยังไม่มีสลิปแนบ',
    ];

    return Dialog(
      backgroundColor: Colors.white.withOpacity(.94),
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 430,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.dangerSoft, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.delete_outline_rounded, size: 22, color: AppColors.danger),
              ),
              const SizedBox(height: 14),
              Text('ลบเอกสาร ${doc.runNo}?', style: AppText.display(19)),
              const SizedBox(height: 4),
              Text(
                doc.cpDocNo == null
                    ? 'ลบแล้วกู้คืนไม่ได้'
                    : 'เลือกเอกสารที่ต้องการลบ เอกสาร CP ที่ผูกกันจะถูกเลือกไว้ด้วย ลบแล้วกู้คืนไม่ได้',
                style: AppText.muted(13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(color: AppColors.tint, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _row(doc.runNo, doc.customerName ?? '', doc.amount, linked: false),
                    if (doc.cpDocNo != null) ...[
                      const Divider(height: 1, color: AppColors.hairline, indent: 8, endIndent: 8),
                      _row(doc.cpDocNo!, 'CP ที่ผูกกัน', doc.amount, linked: true),
                    ],
                  ],
                ),
              ),
              if (warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Banner(icon: Icons.info_outline_rounded, text: warnings.join(' และ'), color: AppColors.warning, background: AppColors.warningSoft),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                _Banner(icon: Icons.error_outline_rounded, text: _error!, color: AppColors.danger, background: AppColors.dangerSoft),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(label: 'ยกเลิก', height: 40, onPressed: _deleting ? null : () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  _deleting
                      ? const _DeletingPill()
                      : PillButton(
                          label: 'ลบ ${_chosen.length} เอกสาร',
                          icon: Icons.delete_outline_rounded,
                          height: 40,
                          filled: true,
                          tone: PillTone.danger,
                          onPressed: _chosen.isEmpty ? null : _confirm,
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String docNo, String caption, double amount, {required bool linked}) {
    return CheckboxListTile(
      value: _selected[docNo],
      onChanged: _deleting ? null : (v) => setState(() => _selected[docNo] = v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.danger,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Row(
        children: [
          DocNoChip(docNo: docNo, linked: linked),
          const SizedBox(width: 10),
          Expanded(child: Text(caption, style: AppText.body(12.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(Fmt.baht(amount), style: AppText.display(12.5)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color, required this.background});

  final IconData icon;
  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppText.body(12, color: color))),
        ],
      ),
    );
  }
}

class _DeletingPill extends StatelessWidget {
  const _DeletingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(color: AppColors.danger.withOpacity(.85), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
          const SizedBox(width: 8),
          Text('กำลังลบ…', style: AppText.body(13, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
