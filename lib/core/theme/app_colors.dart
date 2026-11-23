import 'package:flutter/material.dart';

/// "Lagoon" palette: peach / orchid / lagoon gradient with frosted glass panels.
class AppColors {
  AppColors._();

  // Background gradient
  static const Color peach = Color(0xFFFFD9CC);
  static const Color orchid = Color(0xFFF7CDE6);
  static const Color lagoon = Color(0xFFC6EEE8);
  static const Color lavender = Color(0xFFE4DEFA);
  static const Color base = Color(0xFFF7F2F7);

  // Text
  static const Color ink = Color(0xFF2B2140);
  static const Color muted = Color(0xFF6F6787);
  static const Color faint = Color(0xFF9C95B0);

  // Accent & status
  static const Color accent = Color(0xFFC42A78);
  static const Color accentLight = Color(0xFFD63D6E);
  static const Color coral = Color(0xFFFF9A76);
  static const Color success = Color(0xFF0B7F64);
  static const Color warning = Color(0xFFC46A06);
  static const Color warningDot = Color(0xFFE39A35);
  static const Color danger = Color(0xFFD63A4A);

  // Glass
  static const Color glass = Color(0x94FFFFFF); // 58%
  static const Color glassStrong = Color(0xCCFFFFFF); // 80%
  static const Color glassBorder = Color(0xCCFFFFFF);
  static const Color hairline = Color(0x1F2B2140); // ink 12%
  static const Color tint = Color(0x0F2B2140); // ink 6%

  static Color successSoft = success.withOpacity(.12);
  static Color warningSoft = const Color(0xFFD97A0B).withOpacity(.14);
  static Color dangerSoft = danger.withOpacity(.12);
  static Color accentSoft = accent.withOpacity(.10);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, accent],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  static List<BoxShadow> panelShadow = [
    BoxShadow(color: const Color(0xFF492D6E).withOpacity(.10), blurRadius: 30, offset: const Offset(0, 10)),
  ];
}
