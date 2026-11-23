import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/account.dart';

/// Searchable account picker. Runs [onSave] with the chosen account and
/// stays open (with a spinner) until it completes.
Future<Account?> showSelectAccountDialog(
  BuildContext context, {
  required List<Account> accounts,
  required Future<void> Function(Account account) onSave,
  String? currentName,
}) {
  return showDialog<Account>(
    context: context,
    barrierColor: AppColors.ink.withOpacity(.30),
    builder: (_) => _SelectAccountDialog(accounts: accounts, onSave: onSave, currentName: currentName),
  );
}

class _SelectAccountDialog extends StatefulWidget {
  const _SelectAccountDialog({required this.accounts, required this.onSave, this.currentName});

  final List<Account> accounts;
  final Future<void> Function(Account account) onSave;
  final String? currentName;

  @override
  State<_SelectAccountDialog> createState() => _SelectAccountDialogState();
}

class _SelectAccountDialogState extends State<_SelectAccountDialog> {
  Account? _selected;
  String _query = '';
  bool _saving = false;
  String? _error;

  List<Account> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return widget.accounts;
    return widget.accounts.where((a) => a.name.toLowerCase().contains(q) || a.code.toLowerCase().contains(q)).toList();
  }

  Future<void> _save() async {
    final account = _selected!;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(account);
      if (mounted) Navigator.pop(context, account);
    } catch (e) {
      debugPrint('Save account failed: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'บันทึกไม่สำเร็จ กรุณาลองใหม่';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final height = MediaQuery.sizeOf(context).height;

    return Dialog(
      backgroundColor: Colors.white.withOpacity(.96),
      child: SizedBox(
        width: 460,
        height: (height * .7).clamp(360, 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text('เปลี่ยนบัญชี', style: AppText.display(18))),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                    splashRadius: 18,
                  ),
                ],
              ),
              if (widget.currentName != null)
                Text('ปัจจุบัน: ${widget.currentName}', style: AppText.muted(12.5)),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: AppText.body(13),
                decoration: InputDecoration(
                  hintText: 'พิมพ์ชื่อหรือรหัสบัญชี',
                  hintStyle: AppText.body(13, color: AppColors.faint),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.faint),
                  filled: true,
                  fillColor: AppColors.tint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.accent.withOpacity(.5), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text('ไม่พบบัญชี', style: AppText.muted(13)))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (_, i) => _tile(items[i]),
                      ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: AppText.body(12, color: AppColors.danger)),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(label: 'ยกเลิก', height: 40, onPressed: _saving ? null : () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  PillButton(
                    label: _saving ? 'กำลังบันทึก…' : 'บันทึก',
                    icon: _saving ? null : Icons.check_rounded,
                    height: 40,
                    filled: true,
                    tone: PillTone.accent,
                    onPressed: _selected != null && !_saving ? _save : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(Account account) {
    final selected = account.code == _selected?.code;
    final current = account.name == widget.currentName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selected = account),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(account.code, style: AppText.display(12, weight: FontWeight.w500, color: selected ? AppColors.accent : AppColors.muted)),
                ),
                Expanded(
                  child: Text(
                    account.name,
                    style: AppText.body(13, weight: selected || current ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
                if (current && !selected)
                  Text('ปัจจุบัน', style: AppText.muted(11))
                else if (selected)
                  const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
