import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum PillTone { neutral, danger, success, accent }

/// Rounded action button: icon + label, 28–40px tall.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.tone = PillTone.neutral,
    this.filled = false,
    this.height = 30,
    this.tooltip,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final PillTone tone;
  final bool filled;
  final double height;
  final String? tooltip;

  Color get _color => switch (tone) {
        PillTone.neutral => AppColors.ink,
        PillTone.danger => AppColors.danger,
        PillTone.success => AppColors.success,
        PillTone.accent => AppColors.accent,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = filled ? Colors.white : _color;
    final iconColor = filled || tone != PillTone.neutral ? fg : AppColors.muted;

    Widget pill = Opacity(
      opacity: enabled ? 1 : .45,
      child: Material(
        color: filled ? _color : Colors.white.withOpacity(.85),
        shape: StadiumBorder(
          side: filled
              ? BorderSide.none
              : BorderSide(color: tone == PillTone.neutral ? AppColors.hairline : _color.withOpacity(.3)),
        ),
        elevation: 0,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: height / 2.6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: height * .46, color: iconColor),
                  const SizedBox(width: 6),
                ],
                Text(label, style: AppText.body(height > 34 ? 13 : 12, weight: FontWeight.w600, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) pill = Tooltip(message: tooltip!, child: pill);
    return pill;
  }
}

/// Small status label, e.g. "ตรวจแล้ว" / "รอตรวจ".
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: verified ? Colors.transparent : AppColors.warningSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          verified
              ? Icon(Icons.check_rounded, size: 13, color: color)
              : Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(verified ? 'ตรวจแล้ว' : 'รอตรวจ', style: AppText.body(11.5, weight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

/// PA number chip.
class DocNoChip extends StatelessWidget {
  const DocNoChip({super.key, required this.docNo, this.verified = false, this.linked = false});

  final String docNo;
  final bool verified;

  /// Linked CP document (accent colored, with link icon).
  final bool linked;

  @override
  Widget build(BuildContext context) {
    final Color fg = linked ? AppColors.accent : (verified ? AppColors.success : AppColors.ink);
    final Color bg = linked ? AppColors.accentSoft : (verified ? AppColors.successSoft : AppColors.tint);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (linked) ...[Icon(Icons.link_rounded, size: 13, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              docNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(12, weight: FontWeight.w500, color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
