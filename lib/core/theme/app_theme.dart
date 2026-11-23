import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: AppFonts.pgVim,
      );

  /// Theme wrapper for Material date pickers so they match the brand colors.
  static Widget datePickerTheme(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryDark,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
          surface: Colors.white,
        ),
        datePickerTheme: DatePickerThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          headerBackgroundColor: AppColors.primaryDark,
          headerForegroundColor: Colors.white,
        ),
      ),
      child: child!,
    );
  }

  /// Theme wrapper for the date-range picker in the app bar.
  static Widget dateRangePickerTheme(BuildContext context, Widget? child) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: AppColors.pickerAccent,
          surface: Colors.white,
        ),
        datePickerTheme: const DatePickerThemeData(
          headerBackgroundColor: AppColors.pickerAccent,
          headerForegroundColor: Colors.white,
        ),
      ),
      child: child!,
    );
  }
}
