import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

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
    initialDate: Fmt.parseRefDate(current) ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: AppTheme.datePickerTheme,
  );
  return picked == null ? null : Fmt.dashedDate(picked);
}

Future<String?> _editRefText(BuildContext context, String? current) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'แก้ไขข้อมูลอ้างอิง',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * .3,
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'กรอกข้อมูลที่ต้องการ...',
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
