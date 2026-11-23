import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass.dart';
import '../pay_advance_controller.dart';

/// Four KPI cards: total · verified · pending · day amount.
class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.stats, required this.date});

  final DayStats stats;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 100,
            child: _Kpi(
              label: 'เอกสารทั้งหมด',
              value: '${s.total}',
              footer: Text(date == null ? '—' : Fmt.thaiDayLabel(date!), style: AppText.muted(11.5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 100,
            child: _Kpi(
              label: 'ตรวจแล้ว',
              dot: AppColors.success,
              value: '${s.verified}',
              of: s.total,
              bar: [_Seg(s.progress, AppColors.success)],
              footer: Text(Fmt.baht(s.verifiedAmount), style: AppText.muted(11.5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 100,
            child: _Kpi(
              label: 'รอตรวจ',
              dot: AppColors.warningDot,
              value: '${s.pending}',
              of: s.total,
              bar: [_Seg(s.total == 0 ? 0 : s.pending / s.total, AppColors.warningDot)],
              footer: Text(Fmt.baht(s.pendingAmount), style: AppText.muted(11.5)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 155,
            child: _Kpi(
              label: 'ยอดรวมทั้งวัน',
              value: Fmt.baht(s.totalAmount),
              valueSize: 24,
              bar: s.totalAmount == 0
                  ? const []
                  : [_Seg(s.amountProgress, AppColors.success), _Seg(1 - s.amountProgress, AppColors.warningDot)],
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ตรวจแล้ว ${(s.amountProgress * 100).round()}%', style: AppText.muted(11)),
                  Text('รอตรวจ ${s.totalAmount == 0 ? 0 : 100 - (s.amountProgress * 100).round()}%', style: AppText.muted(11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg {
  const _Seg(this.fraction, this.color);
  final double fraction;
  final Color color;
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.footer,
    this.dot,
    this.of,
    this.bar,
    this.valueSize = 26,
  });

  final String label;
  final String value;
  final Widget footer;
  final Color? dot;
  final int? of;
  final List<_Seg>? bar;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dot != null) ...[
                Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                const SizedBox(width: 6),
              ],
              Text(label, style: AppText.muted(11.5)),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: value,
                style: AppText.display(valueSize),
                children: [
                  if (of != null) TextSpan(text: ' / $of', style: AppText.display(14, weight: FontWeight.w500, color: AppColors.muted)),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (bar != null) ...[
            const SizedBox(height: 3),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final seg in bar!)
                      if (seg.fraction > 0)
                        Expanded(flex: (seg.fraction * 1000).round(), child: ColoredBox(color: seg.color)),
                    if (bar!.fold<double>(0, (s, e) => s + e.fraction) < 1)
                      Expanded(
                        flex: ((1 - bar!.fold<double>(0, (s, e) => s + e.fraction)) * 1000).round().clamp(1, 1000),
                        child: const ColoredBox(color: AppColors.hairline),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
          ],
          footer,
        ],
      ),
    );
  }
}
