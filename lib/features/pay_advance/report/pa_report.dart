import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import '../../../data/models/pa_document.dart';
import 'report_assets.dart';
import 'report_footer.dart';
import 'report_header.dart';

/// Builds the A4 "Pay advance records" PDF.
class PaReport {
  PaReport._(this._assets);

  final ReportAssets _assets;

  // Column widths (pt): Doc No. | Ref No. | Agent | Advance | Income
  static const double _colDoc = 70;
  static const double _colRef = 70;
  static const double _colAgent = 248;
  static const double _colAmount = 60;

  static Future<Uint8List> generate({required DateTime date, required List<PaDocument> documents}) async {
    final report = PaReport._(await ReportAssets.load());
    return report._build(date, documents);
  }

  Future<Uint8List> _build(DateTime date, List<PaDocument> documents) {
    final grandTotal = documents.fold<double>(0, (sum, d) => sum + d.amount);
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 1.5 * PdfPageFormat.cm, vertical: .5 * PdfPageFormat.cm),
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            ...buildReportHeader(
              assets: _assets,
              title: 'Pay advance records',
              thaiTitle: 'รายการบันทึกเงินรับล่วงหน้า',
              date: date,
            ),
            _tableHeader(),
            pw.SizedBox(height: 5),
          ],
        ),
        build: (_) => [
          ...documents.map(_documentRows),
          pw.SizedBox(height: 5),
          if (documents.isNotEmpty)
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Total     ${Fmt.money(grandTotal)}',
                style: pw.TextStyle(font: _assets.trajanPro, fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
        ],
        footer: (context) => buildReportFooter(context, assets: _assets, title: 'Pay Advance Records'),
      ),
    );

    return pdf.save();
  }

  /// Document row, its account lines, and (for multi-line docs) a subtotal.
  pw.Widget _documentRows(PaDocument doc) {
    final multiLine = doc.lines.length > 1;

    pw.Widget lineRow({required String account, required String ref, required double amount, required pw.Font amountFont}) {
      return pw.Row(children: [
        _cell('', 140),
        _cell(account, 193),
        _cell(ref, 55),
        _cell('', 60),
        _cell(Fmt.money(amount), _colAmount, align: pw.Alignment.centerRight, font: amountFont),
      ]);
    }

    return pw.Column(children: [
      pw.Row(children: [
        _cell(doc.runNo, _colDoc),
        _cell(doc.cpDocNo ?? '', _colRef),
        _cell(doc.customerLabel, _colAgent),
        _cell(Fmt.money(doc.amount), _colAmount, align: pw.Alignment.centerRight, font: _assets.trajanPro),
        _cell('', _colAmount),
      ]),
      pw.SizedBox(height: 2),
      for (final line in doc.lines)
        lineRow(
          account: line.accountName ?? '',
          ref: line.refNo ?? '',
          amount: line.amount,
          amountFont: multiLine ? _assets.pgVim : _assets.trajanPro,
        ),
      if (multiLine) lineRow(account: '', ref: '', amount: doc.amount, amountFont: _assets.trajanPro),
      pw.SizedBox(height: 10),
    ]);
  }

  pw.Widget _cell(String text, double width, {pw.Alignment align = pw.Alignment.centerLeft, pw.Font? font}) {
    return pw.Container(
      width: width,
      margin: const pw.EdgeInsets.only(left: 1),
      alignment: align,
      child: pw.Text(
        text,
        overflow: pw.TextOverflow.clip,
        style: pw.TextStyle(font: font ?? _assets.pgVim, fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tableHeader() {
    pw.Widget cell(String title, double width, {pw.Alignment align = pw.Alignment.centerLeft, pw.EdgeInsets? padding, double fontSize = 10}) {
      return pw.Container(
        height: 20,
        width: width,
        margin: const pw.EdgeInsets.only(left: 1),
        padding: padding ?? const pw.EdgeInsets.only(left: 5),
        alignment: align,
        color: PdfColors.grey400,
        child: pw.Text(title, style: pw.TextStyle(font: _assets.pgVim, fontSize: fontSize, fontWeight: pw.FontWeight.bold)),
      );
    }

    return pw.Row(children: [
      cell('Doc No.', _colDoc),
      cell('Ref No.', _colRef),
      cell('Agent', _colAgent),
      cell('เงินรับล่วงหน้า', _colAmount, padding: const pw.EdgeInsets.only(left: 1.5), fontSize: 9),
      cell('รายได้', _colAmount, align: pw.Alignment.centerRight, padding: const pw.EdgeInsets.only(right: 5)),
    ]);
  }
}
