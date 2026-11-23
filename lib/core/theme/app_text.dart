import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Text styles for the Lagoon UI.
///
/// [display] uses Prompt (headings, amounts, KPIs).
/// [body] uses Anuphan, a variable font, so the weight is also passed as a
/// `wght` font variation.
class AppText {
  AppText._();

  static TextStyle display(double size, {FontWeight weight = FontWeight.w600, Color color = AppColors.ink}) {
    return TextStyle(
      fontFamily: AppFonts.prompt,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.25,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color color = AppColors.ink}) {
    return TextStyle(
      fontFamily: AppFonts.anuphan,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: 1.4,
    );
  }

  static TextStyle muted(double size, {FontWeight weight = FontWeight.w400}) =>
      body(size, weight: weight, color: AppColors.muted);
}
