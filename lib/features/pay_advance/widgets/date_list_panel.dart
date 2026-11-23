import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../pay_advance_controller.dart';

/// Left glass panel: day cards with a progress ring.
class DateListPanel extends StatelessWidget {
  const DateListPanel({
    super.key,
    required this.dates,
    required this.loaded,
    required this.selectedDate,
    required this.ascending,
    required this.stats,
    required this.onSelect,
    required this.onToggleSort,
    required this.onRetry,
    this.error,
  });

  final List<String> dates;
  final bool loaded;
  final String? selectedDate;
  final bool ascending;
  final Map<String, DayStats> stats;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleSort;
  final VoidCallback onRetry;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 0, 6),
            child: Row(
              children: [
                Text('วันที่', style: AppText.display(14)),
                const Spacer(),
                Tooltip(
                  message: ascending ? 'เก่า → ใหม่' : 'ใหม่ → เก่า',
                  child: InkWell(
                    onTap: onToggleSort,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(8)),
                      child: Icon(
                        ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 14,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: !loaded
                ? const LoadingIndicator(size: 36)
                : error != null
                    ? ErrorState(message: error!, onRetry: onRetry, compact: true)
                    : dates.isEmpty
                        ? Center(child: Text('ไม่มีเอกสารในช่วงนี้', style: AppText.muted(12)))
                        : ListView.separated(
                            itemCount: dates.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 4),
                            itemBuilder: (_, i) => _DayTile(
                              date: DateTime.parse(dates[i]),
                              stats: stats[dates[i]],
                              selected: dates[i] == selectedDate,
                              onTap: () => onSelect(dates[i]),
                            ),
                          ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(999)),
                  child: Text(AppInfo.version, style: AppText.muted(11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.date, required this.stats, required this.selected, required this.onTap});

  final DateTime date;
  final DayStats? stats;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(.92) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.accent.withOpacity(.5) : Colors.transparent, width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: AppColors.accent.withOpacity(.16), blurRadius: 16, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '${date.day}',
                textAlign: TextAlign.center,
                style: AppText.display(20, color: selected ? AppColors.accent : AppColors.ink),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Fmt.thaiMonthShort(date)} · ${Fmt.thaiWeekdayShort(date)}',
                    style: AppText.body(11.5, weight: FontWeight.w600),
                  ),
                  Text(
                    s == null ? 'ยังไม่ได้เปิดดู' : '${s.verified}/${s.total} ตรวจแล้ว',
                    style: AppText.muted(10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ProgressRing(stats: s),
          ],
        ),
      ),
    );
  }
}

/// 26px ring; solid green with a check when the day is fully verified.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.stats});

  final DayStats? stats;

  @override
  Widget build(BuildContext context) {
    final s = stats;
    if (s != null && s.isComplete) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
      );
    }
    return SizedBox(
      width: 26,
      height: 26,
      child: CircularProgressIndicator(
        value: s?.progress ?? 0,
        strokeWidth: 4,
        strokeCap: StrokeCap.round,
        color: AppColors.success,
        backgroundColor: AppColors.hairline,
      ),
    );
  }
}
