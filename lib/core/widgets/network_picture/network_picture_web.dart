import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation: `<div style="overflow:auto"><img></div>` in a
/// platform view. `<img>` loads cross-origin images without CORS.
///
/// Zoom > 1 enlarges the image inside the scrollable div, so the user can
/// pan with the scroll wheel / scrollbars or by dragging.
class PlatformPicture extends StatefulWidget {
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
  State<PlatformPicture> createState() => _PlatformPictureState();
}

class _PlatformPictureState extends State<PlatformPicture> {
  web.HTMLDivElement? _box;
  web.HTMLImageElement? _img;
  bool _loaded = false;
  bool _failed = false;

  @override
  void didUpdateWidget(PlatformPicture old) {
    super.didUpdateWidget(old);
    if (old.zoom != widget.zoom || old.fit != widget.fit) _applyStyle();
    if (old.onTap != widget.onTap) _applyCursor();
  }

  void _onCreated(Object element) {
    final box = element as web.HTMLDivElement;
    final img = web.HTMLImageElement()
      ..alt = ''
      ..draggable = false
      ..decoding = 'async';

    box.style
      ..width = '100%'
      ..height = '100%'
      ..overflow = 'hidden'
      ..setProperty('overscroll-behavior', 'contain');
    img.style
      ..display = 'block'
      ..setProperty('user-select', 'none');

    img.addEventListener('load', ((web.Event _) {
      if (mounted) setState(() => _loaded = true);
    }).toJS);
    img.addEventListener('error', ((web.Event _) {
      if (mounted) setState(() => _failed = true);
    }).toJS);
    img.addEventListener('click', ((web.Event _) => widget.onTap?.call()).toJS);
    _enableDragToPan(box);

    box.append(img);
    _box = box;
    _img = img;
    _applyStyle();
    _applyCursor();
    img.src = widget.url;
  }

  void _applyStyle() {
    final box = _box, img = _img;
    if (box == null || img == null) return;
    final zoomed = widget.zoom > 1.001;

    box.style.overflow = zoomed ? 'auto' : 'hidden';
    if (!zoomed) {
      img.style
        ..width = '100%'
        ..height = '100%'
        ..maxWidth = 'none'
        ..margin = '0'
        ..objectFit = widget.fit == BoxFit.cover ? 'cover' : 'contain';
    } else {
      // Zoom relative to the "fit inside the box" size, so 200% means twice
      // the fitted slip — not twice the box width (which, for a tall slip in
      // a wide viewer, would be far larger).
      final natW = img.naturalWidth, natH = img.naturalHeight;
      final boxW = box.clientWidth, boxH = box.clientHeight;
      final fitted = (natW > 0 && natH > 0 && boxW > 0 && boxH > 0)
          ? (natW * (boxW / natW < boxH / natH ? boxW / natW : boxH / natH))
          : boxW.toDouble();
      img.style
        ..width = '${(fitted * widget.zoom).round()}px'
        ..height = 'auto'
        ..maxWidth = 'none'
        ..margin = '0 auto'
        ..objectFit = 'contain';
    }
  }

  void _applyCursor() {
    _img?.style.cursor = widget.onTap != null ? 'zoom-in' : 'default';
  }

  /// Click-and-drag scrolling when zoomed (a plain click still triggers onTap).
  void _enableDragToPan(web.HTMLDivElement box) {
    var dragging = false;
    var moved = false;
    double startX = 0, startY = 0, startLeft = 0, startTop = 0;

    box.addEventListener('mousedown', ((web.MouseEvent e) {
      if (widget.zoom <= 1.001) return;
      dragging = true;
      moved = false;
      startX = e.clientX.toDouble();
      startY = e.clientY.toDouble();
      startLeft = box.scrollLeft;
      startTop = box.scrollTop;
      e.preventDefault();
    }).toJS);
    box.addEventListener('mousemove', ((web.MouseEvent e) {
      if (!dragging) return;
      final dx = e.clientX - startX, dy = e.clientY - startY;
      if (dx.abs() + dy.abs() > 3) moved = true;
      box.scrollLeft = startLeft - dx;
      box.scrollTop = startTop - dy;
    }).toJS);
    void stop(web.Event _) => dragging = false;
    box.addEventListener('mouseup', stop.toJS);
    box.addEventListener('mouseleave', stop.toJS);
    // Swallow the click that ends a drag so it does not open the viewer.
    box.addEventListener(
      'click',
      ((web.Event e) {
        if (moved) {
          e.stopPropagation();
          moved = false;
        }
      }).toJS,
      true.toJS, // capture phase, before the <img> click handler
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.errorBuilder(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        HtmlElementView.fromTagName(tagName: 'div', onElementCreated: _onCreated),
        if (!_loaded && widget.loading != null) IgnorePointer(child: widget.loading!),
      ],
    );
  }
}
