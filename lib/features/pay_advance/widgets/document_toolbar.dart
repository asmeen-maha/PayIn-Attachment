import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/formatters.dart';
import '../pay_advance_controller.dart';

/// Title, status filter tabs, sort toggle and PA search.
class DocumentToolbar extends StatelessWidget {
  const DocumentToolbar({
    super.key,
    required this.date,
    required this.stats,
    required this.filter,
    required this.onFilter,
    required this.ascending,
    required this.onToggleSort,
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
  });

  final DateTime? date;
  final DayStats stats;
  final DocFilter filter;
  final ValueChanged<DocFilter> onFilter;
  final bool ascending;
  final VoidCallback onToggleSort;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pay Advance', style: AppText.display(18)),
            Text(date == null ? 'เลือกวันที่ทางซ้าย' : 'รายการเอกสาร ${Fmt.shortDate(date!)}', style: AppText.muted(12)),
          ],
        ),
        const Spacer(),
        _FilterTabs(
          selected: filter,
          counts: {DocFilter.all: stats.total, DocFilter.pending: stats.pending, DocFilter.verified: stats.verified},
          onSelected: onFilter,
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: ascending ? 'เลข PA น้อย → มาก' : 'เลข PA มาก → น้อย',
          child: _CircleIconButton(
            icon: ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            onTap: onToggleSort,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 190, child: _SearchField(controller: searchController, onChanged: onSearch, onClear: onClearSearch)),
      ],
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.counts, required this.onSelected});

  final DocFilter selected;
  final Map<DocFilter, int> counts;
  final ValueChanged<DocFilter> onSelected;

  static const _labels = {DocFilter.all: 'ทั้งหมด', DocFilter.pending: 'รอตรวจ', DocFilter.verified: 'ตรวจแล้ว'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          for (final f in DocFilter.values)
            InkWell(
              onTap: () => onSelected(f),
              customBorder: const StadiumBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: f == selected ? AppColors.accentGradient : null,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Text(
                      _labels[f]!,
                      style: AppText.body(12.5,
                          weight: f == selected ? FontWeight.w600 : FontWeight.w400,
                          color: f == selected ? Colors.white : AppColors.muted),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: f == selected ? Colors.white.withOpacity(.25) : AppColors.tint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${counts[f] ?? 0}',
                        style: AppText.body(11, color: f == selected ? Colors.white : AppColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassStrong,
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 36, height: 36, child: Icon(icon, size: 16, color: AppColors.muted)),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.body(12.5),
        decoration: InputDecoration(
          hintText: 'ค้นหาหมายเลข PA',
          hintStyle: AppText.body(12.5, color: AppColors.faint),
          prefixIcon: const Icon(Icons.search_rounded, size: 17, color: AppColors.faint),
          prefixIconConstraints: const BoxConstraints(minWidth: 38),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.muted),
                  splashRadius: 14,
                ),
          filled: true,
          fillColor: AppColors.glassStrong,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: AppColors.accent.withOpacity(.5), width: 1.5),
          ),
        ),
      ),
    );
  }
}
