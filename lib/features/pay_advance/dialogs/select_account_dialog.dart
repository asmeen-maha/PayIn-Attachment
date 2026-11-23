import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/account.dart';

/// Lets the user pick an account, then runs [onSave] with it.
///
/// The dialog stays open (with a spinner) until [onSave] completes.
/// Returns the saved account, or null when cancelled.
Future<Account?> showSelectAccountDialog(
  BuildContext context, {
  required List<Account> accounts,
  required Future<void> Function(Account account) onSave,
}) {
  return showDialog<Account>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SelectAccountDialog(accounts: accounts, onSave: onSave),
  );
}

class _SelectAccountDialog extends StatefulWidget {
  const _SelectAccountDialog({required this.accounts, required this.onSave});

  final List<Account> accounts;
  final Future<void> Function(Account account) onSave;

  @override
  State<_SelectAccountDialog> createState() => _SelectAccountDialogState();
}

class _SelectAccountDialogState extends State<_SelectAccountDialog> {
  Account? _selected;
  bool _saving = false;

  Future<void> _save() async {
    final account = _selected!;
    setState(() => _saving = true);
    try {
      await widget.onSave(account);
      if (mounted) Navigator.pop(context, account);
    } catch (e) {
      debugPrint('Save account failed: $e');
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('เลือกบัญชีที่ต้องการแก้ไข', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            splashRadius: 20,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      content: SizedBox(
        width: size.width * 0.3,
        height: size.height * 0.6,
        child: ListView.builder(
          itemCount: widget.accounts.length,
          itemBuilder: (_, i) {
            final account = widget.accounts[i];
            final isSelected = account.code == _selected?.code;
            return ListTile(
              title: Text(account.name),
              tileColor: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark) : null,
              onTap: () => setState(() => _selected = account),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: _selected != null && !_saving ? _save : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('บันทึก', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }
}
