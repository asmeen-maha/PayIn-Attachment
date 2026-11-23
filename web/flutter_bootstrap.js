{{flutter_js}}
{{flutter_build_config}}

// Internal-network deployment: nothing may be fetched from the internet.
// By default Flutter web pulls CanvasKit from www.gstatic.com and fallback
// fonts (Roboto / Noto) from fonts.gstatic.com. Point them at this server.

// pdf.js for the report preview is loaded from assets/pdfjs/ by index.html.
// Do NOT set window.dartPdfJsBaseUrl: printing 5.14.2 reads it with an untyped
// getProperty() and crashes ("type 'String' is not a subtype of type 'Never'").

_flutter.loader.load({
  config: {
    // Bundled by `flutter build web --no-web-resources-cdn` into build/web/canvaskit.
    canvasKitBaseUrl: "canvaskit/",
    // Roboto is bundled under web/assets/fallback_fonts/. Glyphs that no
    // bundled font covers (e.g. emoji) are requested here too; a 404 just
    // renders a blank box instead of calling Google.
    fontFallbackBaseUrl: "assets/fallback_fonts/",
  },
});
