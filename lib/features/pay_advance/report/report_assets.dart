import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fonts and images embedded in the PDF report.
class ReportAssets {
  const ReportAssets({required this.logo, required this.pgVim, required this.trajanPro});

  final pw.ImageProvider logo;
  final pw.Font pgVim;
  final pw.Font trajanPro; // bold cut, used for numbers and English titles

  static Future<ReportAssets>? _cached;

  /// Loaded and parsed once per session; later reports reuse them.
  static Future<ReportAssets> load() {
    return _cached ??= _load().catchError((Object e) {
      _cached = null; // allow a retry next time
      throw e;
    });
  }

  static Future<ReportAssets> _load() async {
    Future<Uint8List> bytes(String path) async => (await rootBundle.load(path)).buffer.asUint8List();

    return ReportAssets(
      logo: pw.MemoryImage(await bytes('assets/images/logo_cm_bk.jpg')),
      pgVim: pw.Font.ttf(await rootBundle.load('assets/fonts/pgvim.ttf')),
      trajanPro: pw.Font.ttf(await rootBundle.load('assets/fonts/trajanpro-bold.ttf')),
    );
  }
}
