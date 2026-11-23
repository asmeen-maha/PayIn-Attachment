import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/pa_document.dart';

/// One PA document in the list: number chip, verify checkbox, customer,
/// account lines and total.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.selected,
    required this.canEdit,
    required this.onTap,
    required this.onDocNoTap,
    required this.onVerify,
    required this.onEditAccount,
    required this.onEditRefNo,
  });

  final PaDocument document;
  final bool selected;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onDocNoTap;
  final VoidCallback onVerify;
  final ValueChanged<PaLine> onEditAccount;
  final ValueChanged<PaLine> onEditRefNo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: _decoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topRow(),
              const SizedBox(height: 12),
              _customerRow(),
              const SizedBox(height: 13),
              _LinesTable(
                document: document,
                canEdit: canEdit,
                onEditAccount: onEditAccount,
                onEditRefNo: onEditRefNo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() => BoxDecoration(
        color: selected ? AppColors.primaryDark.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primaryDark : Colors.grey.shade200,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          selected
              ? BoxShadow(color: AppColors.primaryDark.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6))
              : BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      );

  Widget _topRow() {
    final verified = document.isVerified;
    final chipColor = verified ? Colors.green.shade700 : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onDocNoTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: verified ? Colors.green.shade50 : Colors.grey.shade100,
                  border: Border.all(color: verified ? Colors.green.shade400 : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 18, color: verified ? Colors.green.shade700 : Colors.black54),
                    const SizedBox(width: 6),
                    Text(document.runNo, style: TextStyle(fontSize: 14, fontFamily: AppFonts.trajanProBold, color: chipColor)),
                  ],
                ),
              ),
            ),
            if (document.hasSlip)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: document.slipIsPdf
                    ? const Icon(Icons.picture_as_pdf_outlined, color: Colors.redAccent, size: 25)
                    : const Icon(Icons.image_outlined, color: Colors.teal, size: 25),
              ),
          ],
        ),
        Row(
          children: [
            const Text('ตรวจสอบ', style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(width: 8),
            Checkbox(
              value: verified,
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (_) => onVerify(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _customerRow() {
    return Row(
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Account / Ref No. / Amount table with the document total.
/// Only the first line is editable.
class _LinesTable extends StatelessWidget {
  const _LinesTable({
    required this.document,
    required this.canEdit,
    required this.onEditAccount,
    required this.onEditRefNo,
  });

  final PaDocument document;
  final bool canEdit;
  final ValueChanged<PaLine> onEditAccount;
  final ValueChanged<PaLine> onEditRefNo;

  static const _headerStyle = TextStyle(fontSize: 14, color: Colors.black45);
  static const _cellStyle = TextStyle(fontSize: 15, color: Colors.black87);

  @override
  Widget build(BuildContext context) {
    final lines = document.lines;
    final total = document.amount;
    final totalColor = document.isVerified
        ? Colors.green.shade700
        : total > 0
            ? Colors.black
            : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          if (lines.isNotEmpty)
            const Row(
              children: [
                Expanded(flex: 3, child: Text('รายการ (Account)', style: _headerStyle)),
                Expanded(flex: 2, child: Text('อ้างอิง (Ref No.)', style: _headerStyle)),
                Expanded(flex: 2, child: Text('จำนวนเงิน (Amount)', textAlign: TextAlign.right, style: _headerStyle)),
              ],
            ),
          for (var i = 0; i < lines.length; i++) _lineRow(lines[i], editable: i == 0),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: Colors.black12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ยอดรวม', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(
                Fmt.money(total),
                style: TextStyle(fontSize: 20, fontFamily: AppFonts.trajanProBold, color: totalColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineRow(PaLine line, {required bool editable}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(children: [
              Text(line.accountName ?? '-', style: _cellStyle),
              const SizedBox(width: 8),
              if (editable) _EditButton(enabled: canEdit, onTap: () => onEditAccount(line)),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              Text(line.refNo ?? '-', style: _cellStyle),
              const SizedBox(width: 8),
              if (editable) _EditButton(enabled: canEdit, onTap: () => onEditRefNo(line)),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Text(
              Fmt.money(line.amount),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, fontFamily: AppFonts.trajanPro, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary.withOpacity(.1) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.edit_rounded, size: 16, color: enabled ? AppColors.primaryDark : Colors.grey.shade600),
        ),
      ),
    );
  }
}
