import '../../core/utils/json.dart';
import '../models/pa_document.dart';

/// The API returns one flat row per account line. This groups rows that
/// share the same `trrunno` into a single [PaDocument], keeping API order.
List<PaDocument> groupRowsIntoDocuments(List<Map<String, dynamic>> rows) {
  final Map<String, _DocumentBuilder> byRunNo = {};

  for (final row in rows) {
    final runNo = row['trrunno'].toString();
    byRunNo.putIfAbsent(runNo, () => _DocumentBuilder(runNo, row)).lines.add(PaLine.fromJson(row));
  }

  return byRunNo.values.map((builder) => builder.build()).toList();
}

class _DocumentBuilder {
  _DocumentBuilder(this.runNo, this.firstRow);

  final String runNo;
  final Map<String, dynamic> firstRow;
  final List<PaLine> lines = [];

  PaDocument build() => PaDocument(
        runNo: runNo,
        id: asString(firstRow['id']),
        docDate: asString(firstRow['docdate']),
        extCode: asString(firstRow['extcode']),
        customerName: asString(firstRow['customer_name']),
        accountCode: asString(firstRow['accode']),
        slipUrl: asString(firstRow['picurl']),
        flagCheck: asString(firstRow['flagcheck']),
        cpDocNo: asString(firstRow['doccp']),
        lines: lines,
      );
}
