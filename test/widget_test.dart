import 'package:flutter_test/flutter_test.dart';
import 'package:payin_attachment/data/mappers/pa_document_mapper.dart';
import 'package:payin_attachment/features/pay_advance/report/pa_report.dart';

void main() {
  test('groups API rows by trrunno and sums line amounts', () {
    final docs = groupRowsIntoDocuments([
      {'trrunno': 'PA001', 'accname': 'Cash', 'refno': '01-02-26', 'amount': '100.50', 'flagcheck': 'Y'},
      {'trrunno': 'PA001', 'accname': 'Bank', 'refno': 'X1', 'amount': 49.5},
      {'trrunno': 'PA002', 'accname': 'Cash', 'refno': '-', 'amount': '20'},
    ]);

    expect(docs.length, 2);
    expect(docs[0].runNo, 'PA001');
    expect(docs[0].lines.length, 2);
    expect(docs[0].amount, 150.0);
    expect(docs[0].isVerified, isTrue);
    expect(docs[1].amount, 20.0);
  });

  testWidgets('PDF report still builds with fonts read from assets', (tester) async {
    final docs = groupRowsIntoDocuments([
      {'trrunno': 'PA001', 'accname': 'Cash', 'refno': '01-02-26', 'amount': '100.50', 'flagcheck': 'Y'},
      {'trrunno': 'PA001', 'accname': 'Bank', 'refno': 'X1', 'amount': 49.5, 'flagcheck': 'Y'},
    ]);
    final bytes = (await tester.runAsync(() => PaReport.generate(date: DateTime(2026, 11, 23), documents: docs)))!;
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
  });
}
