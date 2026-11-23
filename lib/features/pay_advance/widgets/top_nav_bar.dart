import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/network_picture/network_picture.dart';
import '../../../core/widgets/pills.dart';
import '../../../data/models/access_flag.dart';
import '../pay_advance_controller.dart';

/// Glass navigation bar: brand, date range, quick ranges, report, user.
class TopNavBar extends StatelessWidget {
  const TopNavBar({
    super.key,
    required this.range,
    required this.quickRange,
    required this.onRangeChanged,
    required this.onQuickRange,
    required this.user,
    this.printing = false,
    this.onPrint,
  });

  final DateTimeRange range;
  final QuickRange? quickRange;
  final ValueChanged<DateTimeRange> onRangeChanged;
  final ValueChanged<QuickRange> onQuickRange;
  final AccessFlag? user;
  final VoidCallback? onPrint;
  final bool printing;

  Future<void> _pickRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: range,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) onRangeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const _Brand(),
            const SizedBox(width: 22),
            _RangePill(label: Fmt.thaiRange(range.start, range.end), onTap: () => _pickRange(context)),
            const SizedBox(width: 10),
            _QuickRanges(selected: quickRange, onSelected: onQuickRange),
            const Spacer(),
            PillButton(
              label: printing ? 'กำลังสร้างรายงาน…' : 'ออกรายงาน PDF',
              icon: printing ? Icons.hourglass_top_rounded : Icons.print_outlined,
              height: 36,
              onPressed: onPrint,
              tooltip: printing
                  ? null
                  : onPrint == null
                      ? 'เลือกวันที่ก่อนออกรายงาน'
                      : 'รายงานเฉพาะเอกสารที่ตรวจแล้ว',
            ),
            const SizedBox(width: 10),
            _UserPill(user: user),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Text('CM', style: AppText.display(12, color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PayIn', style: AppText.display(15)),
            Text('Carnival Magic · Finance', style: AppText.muted(11)),
          ],
        ),
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassStrong,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(label, style: AppText.body(13, weight: FontWeight.w500)),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickRanges extends StatelessWidget {
  const _QuickRanges({required this.selected, required this.onSelected});

  final QuickRange? selected;
  final ValueChanged<QuickRange> onSelected;

  static const _labels = {QuickRange.today: 'วันนี้', QuickRange.week: '7 วัน', QuickRange.month: 'เดือนนี้'};

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in _labels.entries)
          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: _QuickChip(
              label: entry.value,
              selected: entry.key == selected,
              onTap: () => onSelected(entry.key),
            ),
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF492D6E).withOpacity(.08), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: AppText.body(12, weight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppColors.ink : AppColors.muted),
        ),
      ),
    );
  }
}

class _UserPill extends StatelessWidget {
  const _UserPill({required this.user});

  final AccessFlag? user;

  String get _initials {
    final name = (user?.name ?? '').trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    return parts.length > 1 ? '${parts[0].characters.first}${parts[1].characters.first}' : name.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final code = user?.code ?? '';
    final photoUrl = ApiConfig.staffPhotoUrl(code);
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 14, 3),
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
            child: ClipOval(
              child: ColoredBox(
                color: Colors.white,
                child: photoUrl == null
                    ? _initialsText()
                    : NetworkPicture(
                        url: photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_) => _initialsText(),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.name ?? '—', style: AppText.body(12.5, weight: FontWeight.w600)),
              Text(code, style: AppText.muted(11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _initialsText() =>
      Center(child: Text(_initials, style: AppText.display(11, color: AppColors.accent)));
}
