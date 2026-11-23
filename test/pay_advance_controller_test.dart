import 'package:flutter_test/flutter_test.dart';
import 'package:payin_attachment/data/models/access_flag.dart';
import 'package:payin_attachment/data/models/account.dart';
import 'package:payin_attachment/data/models/pa_document.dart';
import 'package:payin_attachment/data/services/pa_api_service.dart';
import 'package:payin_attachment/features/pay_advance/pay_advance_controller.dart';

PaDocument _doc(String runNo, {String flag = 'N', double amount = 100}) =>
    PaDocument(runNo: runNo, flagCheck: flag, lines: [PaLine(accountName: 'A', refNo: 'R', amount: amount)]);

/// Fake backend whose per-day responses can be delayed or made to fail.
class _Api extends PaApiService {
  final delays = <String, Duration>{};
  bool failDates = false;
  bool failVerify = false;
  int allDocumentsCalls = 0;

  @override
  Future<List<String>> fetchDocumentDates({required String start, required String end}) async {
    if (failDates) throw const ApiException('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    return ['2026-11-22', '2026-11-23'];
  }

  @override
  Future<List<PaDocument>> fetchDocumentsByDate(String docDate) async {
    await Future<void>.delayed(delays[docDate] ?? Duration.zero);
    return [_doc('PA-$docDate')];
  }

  @override
  Future<List<PaDocument>> fetchAllDocuments() async {
    allDocumentsCalls++;
    return [_doc('PA6811-0001'), _doc('PA6811-0002')];
  }

  @override
  Future<void> markVerified(String runNo) async {
    if (failVerify) throw const ApiException('เซิร์ฟเวอร์ตอบกลับผิดปกติ (500)');
  }

  @override
  Future<List<Account>> fetchAccounts() async => const [];

  @override
  Future<AccessFlag?> fetchCurrentUser() async => const AccessFlag(chk: 'Y');

  @override
  Future<AccessFlag?> fetchDepartment() async => const AccessFlag(chk: 'finance');
}

void main() {
  test('a slow response for an older day does not overwrite the newer day', () async {
    final api = _Api()..delays['2026-11-22'] = const Duration(milliseconds: 80);
    final c = PayAdvanceController(api: api);
    await c.init(); // auto-selects 2026-11-23

    final slow = c.selectDate('2026-11-22'); // slow
    final fast = c.selectDate('2026-11-23'); // fast, picked last
    await Future.wait([slow, fast]);

    expect(c.selectedDate, '2026-11-23');
    expect(c.documents!.single.runNo, 'PA-2026-11-23');
    c.dispose();
  });

  test('load failure is reported as an error, not as "no data"', () async {
    final c = PayAdvanceController(api: _Api()..failDates = true);
    await c.init();

    expect(c.datesLoaded, isTrue);
    expect(c.datesError, 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้');
    c.dispose();
  });

  test('failed verify rolls back and emits a notice', () async {
    final api = _Api()..failVerify = true;
    final c = PayAdvanceController(api: api);
    final notices = <String>[];
    c.notices.listen(notices.add);
    await c.init();

    final doc = c.documents!.single;
    await c.verify(doc);
    await Future<void>.delayed(Duration.zero);

    expect(doc.isVerified, isFalse);
    expect(c.stats.verified, 0);
    expect(notices.single, contains('ไม่สำเร็จ'));
    c.dispose();
  });

  test('search index is loaded lazily, once, and searches are debounced', () async {
    final api = _Api();
    final c = PayAdvanceController(api: api);
    await c.init();
    expect(api.allDocumentsCalls, 0, reason: 'not loaded at startup');

    c.search('P');
    c.search('PA6811');
    c.search('PA6811-0002');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(api.allDocumentsCalls, 1);
    expect(c.visibleDocuments.map((d) => d.runNo), ['PA6811-0002']);
    c.dispose();
  });

  test('no notifications after dispose', () async {
    final api = _Api()..delays['2026-11-23'] = const Duration(milliseconds: 50);
    final c = PayAdvanceController(api: api);
    final pending = c.init();
    c.dispose();
    await expectLater(pending, completes); // would throw "used after disposed"
  });
}
