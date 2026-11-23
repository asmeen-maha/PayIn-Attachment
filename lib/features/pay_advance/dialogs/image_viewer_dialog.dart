import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/network_picture/network_picture.dart';

/// Full-screen slip viewer with zoom buttons. Close with ✕, Esc or the dark area.
Future<void> showImageViewer(BuildContext context, String imageUrl) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(.85),
    builder: (_) => _ImageViewer(url: imageUrl),
  );
}

class _ImageViewer extends StatefulWidget {
  const _ImageViewer({required this.url});

  final String url;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  double _zoom = 1;

  void _setZoom(double z) => setState(() => _zoom = z.clamp(1.0, 5.0));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ToolButton(icon: Icons.remove_rounded, onTap: () => _setZoom(_zoom - .5)),
              SizedBox(
                width: 56,
                child: Text('${(_zoom * 100).round()}%', textAlign: TextAlign.center, style: AppText.body(13, color: Colors.white)),
              ),
              _ToolButton(icon: Icons.add_rounded, onTap: () => _setZoom(_zoom + .5)),
              const SizedBox(width: 6),
              _ToolButton(icon: Icons.fit_screen_rounded, onTap: () => _setZoom(1)),
              const SizedBox(width: 16),
              _ToolButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: NetworkPicture(
              url: widget.url,
              zoom: _zoom,
              loading: const LoadingIndicator(),
              errorBuilder: (_) => const EmptyState(icon: Icons.broken_image_outlined, message: 'โหลดรูปสลิปไม่สำเร็จ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 20, color: AppColors.glassStrong)),
      ),
    );
  }
}
