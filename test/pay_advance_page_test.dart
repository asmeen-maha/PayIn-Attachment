import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:payin_attachment/core/theme/app_theme.dart';
import 'package:payin_attachment/data/mappers/pa_document_mapper.dart';
import 'package:payin_attachment/data/models/access_flag.dart';
import 'package:payin_attachment/data/models/account.dart';
import 'package:payin_attachment/data/models/pa_document.dart';
import 'package:payin_attachment/data/services/pa_api_service.dart';
import 'package:payin_attachment/features/pay_advance/pay_advance_page.dart';

/// Fake backend with one day of sample documents.
class FakeApi extends PaApiService {
  static final _rows = <Map<String, dynamic>>[
    _row('PA6811-0042', 'AG0123', 'Phuket Happy Tour Co., Ltd.', 'บัตรเข้าชม', '23-11-26', 12500, 'Y'),
    _row('PA6811-0043', 'AG0457', 'Andaman Sea Travel Co., Ltd.', 'Show & Buffet', '23-11-26', 38400, 'N'),
    _row('PA6811-0044', 'AG0219', 'Siam Smile Holiday Co., Ltd.', 'Group Package', 'BK-881204', 24000, 'N', pdf: true),
    _row('PA6811-0044', 'AG0219', 'Siam Smile Holiday Co., Ltd.', 'รถรับส่ง', 'BK-881204', 1600, 'N', pdf: true),
    _row('PA6811-0045', 'AG0088', 'Patong Joy Tours', 'บัตรเข้าชม', '22-11-26', 7800, 'Y'),
    _row('PA6811-0046', 'AG0612', 'Golden Kata Travel Agency', 'Group Package', 'INV-2611-0381', 64000, 'N', cp: 'CP6811-0030'),
    _row('PA6811-0051', 'AG0775', 'Krabi–Phuket Connect', 'บัตรเข้าชม', '24-11-26', 0, 'N', slip: false),
  ];

  static Map<String, dynamic> _row(String run, String ext, String name, String acc, String ref, double amt, String flag,
          {bool pdf = false, bool slip = true, String? cp}) =>
      {
        'trrunno': run,
        'id': run,
        'docdate': '2026-11-23',
        'extcode': ext,
        'customer_name': name,
        'accname': acc,
        'refno': ref,
        'amount': amt,
        'flagcheck': flag,
        'doccp': cp,
        'picurl': slip ? 'http://example.invalid/slip_${run.substring(7)}.${pdf ? 'pdf' : 'jpg'}' : '',
      };

  @override
  Future<List<String>> fetchDocumentDates({required String start, required String end}) async =>
      ['2026-11-21', '2026-11-22', '2026-11-23'];

  @override
  Future<List<PaDocument>> fetchDocumentsByDate(String docDate) async =>
      docDate == '2026-11-23' ? groupRowsIntoDocuments(_rows) : [];

  @override
  Future<List<PaDocument>> fetchAllDocuments() async => groupRowsIntoDocuments(_rows);

  @override
  Future<List<Account>> fetchAccounts() async => const [Account(code: '2130-01', name: 'บัตรเข้าชม')];

  @override
  Future<AccessFlag?> fetchCurrentUser() async => const AccessFlag(code: 'CM04127', name: 'สุภาวดี ศรีสุข', chk: 'Y');

  @override
  Future<AccessFlag?> fetchDepartment() async => const AccessFlag(code: 'FN', name: 'Finance', chk: 'finance');
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(rootBundle.load(f));
    }
    await loader.load();
  }

  await load('Prompt', [
    'assets/fonts/lagoon/Prompt-Regular.ttf',
    'assets/fonts/lagoon/Prompt-Medium.ttf',
    'assets/fonts/lagoon/Prompt-SemiBold.ttf',
    'assets/fonts/lagoon/Prompt-Bold.ttf',
  ]);
  await load('Anuphan', ['assets/fonts/lagoon/Anuphan.ttf']);
  await load('MaterialIcons', ['fonts/MaterialIcons-Regular.otf']);
}

void main() {
  testWidgets('Lagoon page renders at desktop size without overflow', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => RepaintBoundary(key: const Key('shot'), child: child),
      home: PayAdvancePage(api: FakeApi()),
    ));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Newest day and first pending document are selected automatically.
    expect(find.text('PA6811-0043'), findsWidgets);
    expect(find.text('ยอดรวมทั้งวัน'), findsOneWidget);

    await _screenshot(tester, '');

    // Delete dialog lists the PA (and CP when linked) with checkboxes.
    await tester.tap(find.text('PA6811-0046').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('ลบ'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ลบ 2 เอกสาร'), findsOneWidget);
    await _screenshot(tester, '_delete', of: find.byType(Dialog));
  });
}

/// Optional screenshot: SCREENSHOT=/path/out flutter test ... → out<suffix>.png
Future<void> _screenshot(WidgetTester tester, String suffix, {Finder? of}) async {
  final out = Platform.environment['SCREENSHOT'];
  if (out == null) return;
  await tester.pump(const Duration(milliseconds: 400));
  await tester.runAsync(() async {
    RenderObject? node = tester.renderObject(of ?? find.byKey(const Key('shot')));
    while (node is! RenderRepaintBoundary) {
      node = node!.parent;
    }
    final boundary = node;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$out$suffix.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
