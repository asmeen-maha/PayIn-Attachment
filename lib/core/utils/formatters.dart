import 'package:intl/intl.dart';

/// Number and date formatting helpers.
class Fmt {
  Fmt._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  static const List<String> _thaiMonths = [
    '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  static const List<String> _thaiMonthsShort = [
    '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  static const List<String> _thaiWeekdaysShort = ['', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
  static const List<String> _thaiWeekdays = ['', 'จันทร์', 'อังคาร', 'พุธ', 'พฤหัสบดี', 'ศุกร์', 'เสาร์', 'อาทิตย์'];

  /// 1234.5 → `1,234.50`
  static String money(double value) => _money.format(value);

  /// 1234.5 → `฿1,234.50`
  static String baht(double value) => '฿${_money.format(value)}';

  /// `พ.ย.`
  static String thaiMonthShort(DateTime d) => _thaiMonthsShort[d.month];

  /// `จ.`
  static String thaiWeekdayShort(DateTime d) => _thaiWeekdaysShort[d.weekday];

  /// `จันทร์ 23 พ.ย. 2026`
  static String thaiDayLabel(DateTime d) => '${_thaiWeekdays[d.weekday]} ${d.day} ${thaiMonthShort(d)} ${d.year}';

  /// `16 – 23 พ.ย. 2026` or `28 ต.ค. – 3 พ.ย. 2026`
  static String thaiRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return start.day == end.day
          ? '${end.day} ${thaiMonthShort(end)} ${end.year}'
          : '${start.day} – ${end.day} ${thaiMonthShort(end)} ${end.year}';
    }
    final startYear = start.year == end.year ? '' : ' ${start.year}';
    return '${start.day} ${thaiMonthShort(start)}$startYear – ${end.day} ${thaiMonthShort(end)} ${end.year}';
  }

  /// `2026-11-23` — format expected by the API.
  static String apiDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// `23 November 2026`
  static String longDate(DateTime d) => DateFormat('dd MMMM yyyy').format(d);

  /// `23 Nov 2026`
  static String shortDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  /// `23-11-2026`
  static String dashedDate(DateTime d) => DateFormat('dd-MM-yyyy').format(d);

  /// `23/11/2026`
  static String slashedDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

  /// `23 พฤศจิกายน 2569` (Buddhist year)
  static String thaiDate(DateTime d) =>
      '${DateFormat('dd').format(d)} ${_thaiMonths[d.month]} ${d.year + 543}';

  /// True for reference numbers that hold a date such as `29-08-26`.
  static bool looksLikeDate(String? text) {
    final value = text?.trim() ?? '';
    if (value.isEmpty || value == '-') return false;
    return RegExp(r'^\d{2}-\d{2}-\d{2,4}$').hasMatch(value);
  }

  /// Parses a `dd-MM-yy` reference date, or returns null.
  static DateTime? parseRefDate(String? text) {
    if (text == null || text.isEmpty) return null;
    try {
      return DateFormat('dd-MM-yy').parse(text);
    } catch (_) {
      return null;
    }
  }
}
