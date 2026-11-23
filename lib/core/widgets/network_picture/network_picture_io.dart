import 'package:flutter/material.dart';

/// Non-web implementation (also used by tests): a regular [Image.network].
class PlatformPicture extends StatelessWidget {
  const PlatformPicture({
    super.key,
    required this.url,
    required this.fit,
    required this.zoom,
    required this.onTap,
    required this.errorBuilder,
    required this.loading,
  });

  final String url;
  final BoxFit fit;
  final double zoom;
  final VoidCallback? onTap;
  final WidgetBuilder errorBuilder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, _, __) => errorBuilder(context),
      loadingBuilder: (context, child, progress) =>
          progress == null || loading == null ? child : loading!,
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRect(child: Transform.scale(scale: zoom, child: image)),
    );
  }
}
