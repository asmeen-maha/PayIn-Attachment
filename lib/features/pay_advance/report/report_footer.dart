import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/formatters.dart';
import 'report_assets.dart';

/// Company address block, print date and page number.
pw.Widget buildReportFooter(pw.Context context, {required ReportAssets assets, required String title}) {
  pw.TextStyle small(pw.Font font, double size) =>
      pw.TextStyle(font: font, fontSize: size, fontWeight: pw.FontWeight.normal);

  pw.Widget divider() => pw.Container(
        height: 25,
        width: 0.7,
        color: PdfColors.black,
        margin: const pw.EdgeInsets.only(top: 0.3 * PdfPageFormat.cm),
      );

  final pageLabel = context.pagesCount == 1 ? '' : '${context.pageNumber} / ${context.pagesCount}';

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.center,
    children: [
      pw.SizedBox(width: 50),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(title, style: small(assets.pgVim, 5)),
      ),
      pw.SizedBox(width: 25),
      divider(),
      pw.Container(
        width: 230,
        alignment: pw.Alignment.center,
        margin: const pw.EdgeInsets.only(top: 0.3 * PdfPageFormat.cm),
        child: pw.Column(
          children: [
            pw.Text(
              'บริษัท คาร์นิวัลเมจิก จำกัด 999 หมู่ 3 ตำบลกมลา อำเภอกะทู้ จังหวัดภูเก็ต 83150',
              style: small(assets.pgVim, 5.5),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Carnival Magic Co., Ltd. 999 Moo 3 Kamala Kathu phuket 83150 Thailand',
              style: small(assets.pgVim, 5.5),
            ),
            pw.SizedBox(height: 3),
            pw.Text('Tel: 076 385222  Email: Credit@carnivalmagic.fun', style: small(assets.trajanPro, 5.5)),
          ],
        ),
      ),
      divider(),
      pw.SizedBox(width: 25),
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Text(Fmt.slashedDate(DateTime.now()), style: small(assets.pgVim, 5)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 80),
        child: pw.Text(pageLabel, style: small(assets.trajanPro, 6)),
      ),
    ],
  );
}
