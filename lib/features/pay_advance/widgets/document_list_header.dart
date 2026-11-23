import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

/// Title row above the document list: date, sort, search box and print button.
class DocumentListHeader extends StatelessWidget {
  const DocumentListHeader({
    super.key,
    required this.date,
    required this.showSort,
    required this.ascending,
    required this.onToggleSort,
    required this.searchController,
    required this.onSearch,
    required this.onClearSearch,
    this.onPrint,
  });

  final DateTime date;
  final bool showSort;
  final bool ascending;
  final VoidCallback onToggleSort;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearSearch;

  /// Hidden when null.
  final VoidCallback? onPrint;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pay Advance', style: TextStyle(fontSize: 20, color: Colors.black)),
            Row(
              children: [
                Text(
                  'รายการเอกสารวันที่ ${Fmt.longDate(date)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 10),
                if (showSort)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      onPressed: onToggleSort,
                      tooltip: 'เรียงลำดับ (PA)',
                      icon: Icon(
                        ascending ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(width: 300, child: _searchField()),
            ),
            if (onPrint != null)
              IconButton(
                onPressed: onPrint,
                tooltip: 'รายงาน Pay Advance',
                icon: const Icon(Icons.print_rounded, color: AppColors.primaryDark, size: 22),
              ),
          ],
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller: searchController,
      onChanged: onSearch,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: 'ค้นหาหมายเลข PA',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
        suffixIcon: searchController.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500, size: 20),
                onPressed: onClearSearch,
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryDark.withOpacity(0.5), width: 1.5),
        ),
      ),
    );
  }
}
