import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pills.dart';

/// Asks for a new reference number.
///
/// If the current value looks like a date (`dd-MM-yy`) a date picker is shown,
/// otherwise a text field. Returns null when cancelled or unchanged.
Future<String?> showEditRefNoDialog(BuildContext context, String? current) async {
  final Future<String?> dialog =
      Fmt.looksLikeDate(current) ? _pickRefDate(context, current) : _editRefText(context, current);
  final result = await dialog;
  return result == current ? null : result;
}

Future<String?> _pickRefDate(BuildContext context, String? current) async {
  final picked = await showDatePicker(
    context: context,
    helpText: 'เลือกวันที่อ้างอิง',
    initialDate: Fmt.parseRefDate(current) ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
  );
  return picked == null ? null : Fmt.dashedDate(picked);
}

Future<String?> _editRefText(BuildContext context, String? current) {
  return showDialog<String>(
    context: context,
    barrierColor: AppColors.ink.withOpacity(.30),
    builder: (_) => _EditTextDialog(initialText: (current == null || current == '-') ? '' : current),
  );
}

class _EditTextDialog extends StatefulWidget {
  const _EditTextDialog({required this.initialText});

  final String initialText;

  @override
  State<_EditTextDialog> createState() => _EditTextDialogState();
}

class _EditTextDialogState extends State<_EditTextDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(.96),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('แก้เลขอ้างอิง', style: AppText.display(18)),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (_) => _save(),
                style: AppText.body(14),
                decoration: InputDecoration(
                  hintText: 'เช่น INV-2611-0381',
                  hintStyle: AppText.body(14, color: AppColors.faint),
                  filled: true,
                  fillColor: AppColors.tint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent.withOpacity(.5), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(label: 'ยกเลิก', height: 40, onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  PillButton(label: 'บันทึก', icon: Icons.check_rounded, height: 40, filled: true, tone: PillTone.accent, onPressed: _save),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
