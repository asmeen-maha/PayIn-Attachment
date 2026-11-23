import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;

import '../../core/utils/formatters.dart';
import '../../data/models/access_flag.dart';
import '../../data/models/account.dart';
import '../../data/models/pa_document.dart';
import '../../data/services/pa_api_service.dart';

/// State and actions for the Pay Advance screen.
class PayAdvanceController extends ChangeNotifier {
  PayAdvanceController({PaApiService? api}) : _api = api ?? PaApiService();

  final PaApiService _api;

  // ------------------------------------------------------------------ state

  AccessFlag? user;
  AccessFlag? department;
  List<Account> accounts = [];

  List<String> dates = [];
  bool datesLoaded = false;
  bool datesAscending = true;

  String? selectedDate;
  List<PaDocument>? documents;
  bool documentsLoaded = false;
  bool documentsAscending = true;

  List<PaDocument> _allDocuments = [];
  String searchQuery = '';
  List<PaDocument> _searchResults = [];

  PaDocument? selectedDocument;

  // ---------------------------------------------------------------- derived

  /// May edit account / ref no. and cancel documents.
  bool get canEdit => user?.chk == 'Y';

  /// May tick the "verified" checkbox.
  bool get canVerify => department?.chk == 'finance';

  bool get isSearching => searchQuery.isNotEmpty;

  List<PaDocument> get visibleDocuments => isSearching ? _searchResults : (documents ?? const []);

  /// Only verified documents go into the printed report.
  List<PaDocument> get reportDocuments => (documents ?? const []).where((d) => d.isVerified).toList();

  // --------------------------------------------------------------- loading

  static DateTimeRange get defaultRange {
    final now = DateTime.now();
    return DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);
  }

  Future<void> init() async {
    final range = defaultRange;
    await Future.wait([
      _api.fetchDepartment().then((v) => department = v),
      _api.fetchCurrentUser().then((v) => user = v),
      _api.fetchAccounts().then((v) => accounts = v),
      _api.fetchAllDocuments().then((v) => _allDocuments = v),
      loadDates(range),
    ]);
    notifyListeners();
  }

  Future<void> loadDates(DateTimeRange range) async {
    dates = await _api.fetchDocumentDates(
      start: Fmt.apiDate(range.start),
      end: Fmt.apiDate(range.end),
    );
    datesLoaded = true;
    notifyListeners();
  }

  Future<void> selectDate(String date) async {
    selectedDate = date;
    selectedDocument = null;
    documentsLoaded = false;
    searchQuery = '';
    notifyListeners();
    await reloadDocuments();
  }

  Future<void> reloadDocuments() async {
    final date = selectedDate;
    if (date == null) return;
    documents = await _api.fetchDocumentsByDate(date);
    documentsLoaded = true;
    notifyListeners();
  }

  // ------------------------------------------------------- sort & search

  void toggleDateSort() {
    datesAscending = !datesAscending;
    dates.sort((a, b) => datesAscending ? a.compareTo(b) : b.compareTo(a));
    notifyListeners();
  }

  void toggleDocumentSort() {
    documentsAscending = !documentsAscending;
    documents?.sort((a, b) => documentsAscending ? a.runNo.compareTo(b.runNo) : b.runNo.compareTo(a.runNo));
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query;
    final q = query.toLowerCase();
    _searchResults = _allDocuments.where((d) => d.runNo.toLowerCase().contains(q)).toList();
    notifyListeners();
  }

  void clearSearch() => search('');

  void selectDocument(PaDocument doc) {
    selectedDocument = doc;
    notifyListeners();
  }

  // --------------------------------------------------------------- actions

  Future<void> verify(PaDocument doc) async {
    if (doc.isVerified || !canVerify) return;
    doc.flagCheck = 'Y';
    notifyListeners();
    try {
      await _api.markVerified(doc.runNo);
    } catch (e) {
      debugPrint('verify ${doc.runNo} failed: $e');
    }
    await reloadDocuments();
  }

  Future<void> updateAccount(PaDocument doc, PaLine line, Account account) async {
    await _api.updateAccount(runNo: doc.runNo, accountCode: account.code);
    line.accountName = account.name;
    notifyListeners();
  }

  Future<void> updateRefNo(PaDocument doc, PaLine line, String refNo) async {
    line.refNo = refNo;
    notifyListeners();
    await _api.updateRefNo(runNo: doc.runNo, refNo: refNo);
  }

  /// Cancels a PA or its linked CP document, then refreshes the list.
  Future<void> cancelDocument(String docNo) async {
    await _api.cancelDocument(docNo);
    searchQuery = '';
    await reloadDocuments();
  }
}
