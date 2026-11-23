import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-screen peach / orchid / lagoon / lavender gradient.
class LagoonBackground extends StatelessWidget {
  const LagoonBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    RadialGradient blob(Alignment at, Color color) => RadialGradient(
          center: at,
          radius: 0.9,
          colors: [color, color.withOpacity(0)],
          stops: const [0, .7],
        );

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.base),
      child: Stack(
        children: [
          // Painted once into its own layer; never repainted when content changes.
          Positioned.fill(
            child: RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  for (final g in [
                    blob(Alignment.topLeft, AppColors.peach),
                    blob(Alignment.topRight, AppColors.orchid),
                    blob(const Alignment(.7, 1), AppColors.lagoon),
                    blob(Alignment.bottomLeft, AppColors.lavender),
                  ])
                    DecoratedBox(decoration: BoxDecoration(gradient: g)),
                ],
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Frosted-look glass panel: translucent white fill + white hairline + soft shadow.
///
/// Deliberately no BackdropFilter: the background is a smooth gradient, so a
/// real blur looks the same but costs a full-screen blur pass per panel per
/// frame on Flutter web. Each panel is its own RepaintBoundary.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 20,
    this.strong = false,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// More opaque fill (80% instead of 58%).
  final bool strong;

  /// Accent ring + glow, used for the selected card.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: highlight ? Colors.white.withOpacity(.92) : (strong ? AppColors.glassStrong : AppColors.glass),
        borderRadius: shape,
        border: Border.all(
          color: highlight ? AppColors.accent.withOpacity(.45) : AppColors.glassBorder,
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: highlight
            ? [BoxShadow(color: AppColors.accent.withOpacity(.16), blurRadius: 30, offset: const Offset(0, 12))]
            : AppColors.panelShadow,
      ),
      child: child,
    );

    return RepaintBoundary(child: decorated);
  }
}
