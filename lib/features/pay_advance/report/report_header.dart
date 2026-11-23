import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import 'report_assets.dart';

/// Logo, English + Thai title and "as of" date.
List<pw.Widget> buildReportHeader({
  required ReportAssets assets,
  required String title,
  required String thaiTitle,
  required DateTime date,
}) {
  return [
    pw.Row(
      children: [
        pw.Image(assets.logo, width: 120),
        pw.SizedBox(height: 90, width: 15),
        pw.Container(height: 75, width: 1, color: PdfColors.black),
        pw.SizedBox(width: 15),
        pw.Container(
          padding: const pw.EdgeInsets.only(top: 10),
          width: 400,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(font: assets.trajanPro, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(thaiTitle, style: pw.TextStyle(font: assets.pgVim, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 10),
    pw.Text(
      'ณ วันที่ ${Fmt.thaiDate(date)}',
      style: pw.TextStyle(font: assets.pgVim, fontSize: 10, fontWeight: pw.FontWeight.bold),
    ),
    pw.SizedBox(height: 5),
  ];
}
