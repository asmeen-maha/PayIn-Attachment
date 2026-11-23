import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/pa_document.dart';

/// One PA document as a glass card.
///
/// Edit / delete actions appear only on the selected card.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.selected,
    required this.canEdit,
    required this.canVerify,
    required this.onTap,
    required this.onVerify,
    required this.onEditAccount,
    required this.onEditRefNo,
    required this.onDelete,
  });

  final PaDocument document;
  final bool selected;
  final bool canEdit;
  final bool canVerify;
  final VoidCallback onTap;
  final VoidCallback onVerify;
  final VoidCallback onEditAccount;
  final VoidCallback onEditRefNo;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final doc = document;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: GlassPanel(
          radius: 18,
          highlight: selected,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 10),
              Text(
                doc.customerName ?? '-',
                style: AppText.body(14, weight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(doc.extCode ?? '', style: AppText.muted(11.5)),
                  if (doc.cpDocNo != null) ...[
                    const SizedBox(width: 8),
                    Text('ผูกกับ', style: AppText.muted(11)),
                    const SizedBox(width: 4),
                    Flexible(child: DocNoChip(docNo: doc.cpDocNo!, linked: true)),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              for (final line in doc.lines) _LineRow(line: line),
              if (selected && canEdit) ...[
                const SizedBox(height: 10),
                _actions(),
              ],
              const Spacer(),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.hairline),
              const SizedBox(height: 10),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final doc = document;
    return Row(
      children: [
        DocNoChip(docNo: doc.runNo, verified: doc.isVerified),
        const SizedBox(width: 6),
        StatusChip(verified: doc.isVerified),
        const Spacer(),
        _SlipBadge(document: doc),
      ],
    );
  }

  Widget _actions() {
    final firstRef = document.lines.firstOrNull?.refNo;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        PillButton(label: 'เปลี่ยนบัญชี', icon: Icons.edit_outlined, height: 28, onPressed: onEditAccount),
        PillButton(
          label: Fmt.looksLikeDate(firstRef) ? 'แก้วันที่อ้างอิง' : 'แก้เลขอ้างอิง',
          icon: Fmt.looksLikeDate(firstRef) ? Icons.calendar_today_outlined : Icons.tag_rounded,
          height: 28,
          onPressed: onEditRefNo,
        ),
        PillButton(label: 'ลบ', icon: Icons.delete_outline_rounded, height: 28, tone: PillTone.danger, onPressed: onDelete),
      ],
    );
  }

  Widget _footer() {
    final doc = document;
    final zero = doc.amount <= 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ยอดรวม', style: AppText.muted(11)),
              Text(Fmt.baht(doc.amount), style: AppText.display(19, color: zero ? AppColors.danger : AppColors.ink)),
            ],
          ),
        ),
        VerifyButton(verified: doc.isVerified, enabled: canVerify, onPressed: onVerify),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final PaLine line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(line.accountName ?? '-', style: AppText.body(12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Text(line.refNo ?? '-', style: AppText.muted(11.5)),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 70),
            child: Text(Fmt.money(line.amount), textAlign: TextAlign.right, style: AppText.display(12.5, weight: FontWeight.w400)),
          ),
        ],
      ),
    );
  }
}

class _SlipBadge extends StatelessWidget {
  const _SlipBadge({required this.document});

  final PaDocument document;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label, Color color) = !document.hasSlip
        ? (Icons.error_outline_rounded, 'ไม่มีสลิป', AppColors.danger)
        : document.slipIsPdf
            ? (Icons.picture_as_pdf_outlined, 'PDF', AppColors.muted)
            : (Icons.image_outlined, 'รูปภาพ', AppColors.muted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.7), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppText.body(11, color: color)),
        ],
      ),
    );
  }
}

/// Pill used to verify a document; solid green once verified.
class VerifyButton extends StatelessWidget {
  const VerifyButton({
    super.key,
    required this.verified,
    required this.enabled,
    required this.onPressed,
    this.large = false,
  });

  final bool verified;
  final bool enabled;
  final VoidCallback onPressed;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final height = large ? 38.0 : 34.0;

    if (verified) {
      return Container(
        height: height,
        padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text('ตรวจแล้ว', style: AppText.body(12.5, weight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      );
    }

    final button = Opacity(
      opacity: enabled ? 1 : .5,
      child: Material(
        color: large ? AppColors.success : Colors.white.withOpacity(.75),
        shape: StadiumBorder(side: large ? BorderSide.none : const BorderSide(color: AppColors.success, width: 1.5)),
        elevation: large && enabled ? 4 : 0,
        shadowColor: AppColors.success.withOpacity(.4),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: enabled ? onPressed : null,
          child: Container(
            height: height,
            padding: EdgeInsets.fromLTRB(large ? 14 : 10, 0, large ? 18 : 14, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                large
                    ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                    : Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.success, width: 1.5),
                        ),
                      ),
                const SizedBox(width: 7),
                Text(
                  'ตรวจสอบ',
                  style: AppText.body(large ? 13 : 12.5, weight: FontWeight.w600, color: large ? Colors.white : AppColors.success),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Tooltip(
      message: enabled ? 'ยืนยันแล้วแก้กลับไม่ได้' : 'เฉพาะฝ่ายการเงินเท่านั้น',
      child: button,
    );
  }
}
