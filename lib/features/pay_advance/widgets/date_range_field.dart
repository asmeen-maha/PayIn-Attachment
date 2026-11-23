import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

/// Tappable field showing the selected date range; opens a range picker.
class DateRangeField extends StatefulWidget {
  const DateRangeField({super.key, required this.initialRange, required this.onChanged});

  final DateTimeRange initialRange;
  final ValueChanged<DateTimeRange> onChanged;

  @override
  State<DateRangeField> createState() => _DateRangeFieldState();
}

class _DateRangeFieldState extends State<DateRangeField> {
  late DateTimeRange _range = widget.initialRange;

  Future<void> _pick() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: AppTheme.dateRangePickerTheme,
    );
    if (picked == null) return;
    setState(() => _range = picked);
    widget.onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4)),
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _pick,
          borderRadius: BorderRadius.circular(13),
          splashColor: AppColors.pickerAccent.withOpacity(0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.pickerAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ช่วงเวลา',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade500, letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${Fmt.shortDate(_range.start)}  –  ${Fmt.shortDate(_range.end)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
