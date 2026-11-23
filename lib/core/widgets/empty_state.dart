import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Centered icon + message that fades and slides in.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.message, this.hint});

  final IconData icon;
  final String message;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Colors.white.withOpacity(.7), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 30, color: AppColors.faint),
            ),
            const SizedBox(height: 14),
            Text(message, style: AppText.display(16, weight: FontWeight.w500, color: AppColors.muted)),
            if (hint != null) ...[
              const SizedBox(height: 4),
              Text(hint!, style: AppText.body(12.5, color: AppColors.faint)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Load failure with a retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry, this.compact = false});

  final String message;
  final VoidCallback onRetry;

  /// Smaller layout for narrow panels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: compact ? 26 : 34, color: AppColors.danger),
            const SizedBox(height: 10),
            Text(
              compact ? 'โหลดไม่สำเร็จ' : 'โหลดข้อมูลไม่สำเร็จ',
              style: AppText.display(compact ? 13 : 16, weight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: AppText.muted(compact ? 11 : 12.5)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text('ลองใหม่', style: AppText.body(12.5, weight: FontWeight.w600, color: AppColors.accent)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withOpacity(.4)),
                shape: const StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
