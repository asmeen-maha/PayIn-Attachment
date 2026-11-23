import 'package:flutter/material.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/loading_indicator.dart';

/// Left column: list of document dates, with sort toggle and app version.
class DateListPanel extends StatelessWidget {
  const DateListPanel({
    super.key,
    required this.dates,
    required this.loaded,
    required this.selectedDate,
    required this.ascending,
    required this.onSelect,
    required this.onToggleSort,
  });

  final List<String> dates;
  final bool loaded;
  final String? selectedDate;
  final bool ascending;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleSort;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            const Text('วันที่', style: TextStyle(fontSize: 20, color: Colors.black)),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onToggleSort,
              tooltip: 'เรียงวันที่',
              icon: Icon(
                ascending ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ],
        ),
        Expanded(
          child: loaded
              ? ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (_, i) => _DateTile(
                    date: dates[i],
                    selected: dates[i] == selectedDate,
                    onTap: () => onSelect(dates[i]),
                  ),
                )
              : const LoadingIndicator(),
        ),
        const _VersionTag(),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, required this.selected, required this.onTap});

  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.primaryDark.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3))]
                : const [],
          ),
          child: Text(
            Fmt.shortDate(DateTime.parse(date)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionTag extends StatelessWidget {
  const _VersionTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: const Text(
        AppInfo.version,
        style: TextStyle(fontFamily: AppFonts.trajanPro, fontSize: 11, color: Colors.black, letterSpacing: 0.5),
      ),
    );
  }
}
