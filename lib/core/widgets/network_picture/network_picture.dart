import 'package:flutter/material.dart';

import 'network_picture_io.dart' if (dart.library.js_interop) 'network_picture_web.dart' as impl;

/// Network image that also works on Flutter web when the image server does
/// not send CORS headers.
///
/// CanvasKit fetches `Image.network` bytes with XHR, which the browser blocks
/// unless the server sends `Access-Control-Allow-Origin` — the slip server
/// (nginx on 172.2.200.49) and the staff photo server do not. On web this
/// widget therefore renders a plain HTML `<img>` (no CORS needed) through a
/// platform view; elsewhere it is a normal [Image.network].
class NetworkPicture extends StatelessWidget {
  const NetworkPicture({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.zoom = 1,
    this.onTap,
    required this.errorBuilder,
    this.loading,
  });

  final String url;

  /// [BoxFit.contain] or [BoxFit.cover].
  final BoxFit fit;

  /// 1 = fit to box. Above 1 the image grows and can be scrolled / dragged.
  final double zoom;

  final VoidCallback? onTap;
  final WidgetBuilder errorBuilder;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return impl.PlatformPicture(
      key: ValueKey(url),
      url: url,
      fit: fit,
      zoom: zoom,
      onTap: onTap,
      errorBuilder: errorBuilder,
      loading: loading,
    );
  }
}
