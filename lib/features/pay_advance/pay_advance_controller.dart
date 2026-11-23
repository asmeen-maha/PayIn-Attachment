import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange, DateUtils;

import '../../core/config/api_config.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/access_flag.dart';
import '../../data/models/account.dart';
import '../../data/models/pa_document.dart';
import '../../data/services/pa_api_service.dart';

enum DocFilter { all, pending, verified }

enum QuickRange { today, week, month }

/// Verified / total counts and amounts for one day.
class DayStats {
  const DayStats({
    this.total = 0,
    this.verified = 0,
    this.totalAmount = 0,
    this.verifiedAmount = 0,
  });

  factory DayStats.of(List<PaDocument> docs) {
    var verified = 0;
    var total = 0.0;
    var verifiedAmount = 0.0;
    for (final d in docs) {
      final amount = d.amount;
      total += amount;
      if (d.isVerified) {
        verified++;
        verifiedAmount += amount;
      }
    }
    return DayStats(total: docs.length, verified: verified, totalAmount: total, verifiedAmount: verifiedAmount);
  }

  static const empty = DayStats();

  final int total;
  final int verified;
  final double totalAmount;
  final double verifiedAmount;

  int get pending => total - verified;
  double get pendingAmount => totalAmount - verifiedAmount;
  double get progress => total == 0 ? 0 : verified / total;
  double get amountProgress => totalAmount == 0 ? 0 : verifiedAmount / totalAmount;
  bool get isComplete => total > 0 && verified == total;
}

/// State and actions for the Pay Advance screen.
///
/// Transient problems (failed save, failed verify…) are emitted on [notices]
/// for the page to show as a snackbar; load failures are kept in
/// [datesError] / [documentsError] so the page can offer a retry.
class PayAdvanceController extends ChangeNotifier {
  PayAdvanceController({PaApiService? api}) : _api = api ?? PaApiService();

  final PaApiService _api;
  final _notices = StreamController<String>.broadcast();
  bool _disposed = false;

  /// Incremented on every new dates / documents request; a response whose
  /// token is no longer current is ignored (user already moved on).
  int _datesRequest = 0;
  int _documentsRequest = 0;

  // ------------------------------------------------------------------ state

  AccessFlag? user;
  AccessFlag? department;
  List<Account> accounts = [];

  DateTimeRange range = rangeFor(QuickRange.week);
  QuickRange? quickRange = QuickRange.week;

  List<String> dates = [];
  bool datesLoaded = false;
  String? datesError;
  bool datesAscending = false;

  /// Stats of days whose documents have been loaded in this session.
  final Map<String, DayStats> dayStats = {};

  String? selectedDate;
  List<PaDocument>? documents;
  DayStats stats = DayStats.empty;
  bool documentsLoaded = false;
  String? documentsError;
  bool documentsAscending = true;

  DocFilter filter = DocFilter.all;

  // Search runs against an index of all PA documents, fetched on first use.
  List<PaDocument>? _searchIndex;
  DateTime? _searchIndexAt;
  Future<void>? _searchIndexLoading;
  Timer? _searchDebounce;
  String searchQuery = '';
  bool searchLoading = false;
  List<PaDocument> _searchResults = [];

  PaDocument? selectedDocument;

  Stream<String> get notices => _notices.stream;

  // ---------------------------------------------------------------- derived

  /// May edit account / ref no. and cancel documents.
  bool get canEdit => user?.chk == 'Y';

  /// May verify documents.
  bool get canVerify => department?.chk == 'finance';

  bool get isSearching => searchQuery.isNotEmpty;

  List<PaDocument> get visibleDocuments {
    final source = isSearching ? _searchResults : (documents ?? const <PaDocument>[]);
    return switch (filter) {
      DocFilter.all => source,
      DocFilter.pending => source.where((d) => !d.isVerified).toList(),
      DocFilter.verified => source.where((d) => d.isVerified).toList(),
    };
  }

  /// Only verified documents go into the printed report.
  List<PaDocument> get reportDocuments => (documents ?? const []).where((d) => d.isVerified).toList();

  // --------------------------------------------------------------- loading

  static DateTimeRange rangeFor(QuickRange quick) {
    final today = DateUtils.dateOnly(DateTime.now());
    return switch (quick) {
      QuickRange.today => DateTimeRange(start: today, end: today),
      QuickRange.week => DateTimeRange(start: today.subtract(const Duration(days: 7)), end: today),
      QuickRange.month => DateTimeRange(start: DateTime(today.year, today.month), end: today),
    };
  }

  Future<void> init() async {
    await Future.wait([
      _loadLookups(),
      _loadDates(),
    ]);
  }

  /// User, department and account list. Each is independent; a failure only
  /// disables the related feature and shows a notice.
  Future<void> _loadLookups() async {
    Future<void> guard(Future<void> Function() load, String what) async {
      try {
        await load();
      } on ApiException catch (e) {
        _notice('โหลด$whatไม่สำเร็จ: ${e.message}');
      }
    }

    await Future.wait([
      guard(() async => department = await _api.fetchDepartment(), 'ข้อมูลแผนก'),
      guard(() async => user = await _api.fetchCurrentUser(), 'ข้อมูลผู้ใช้'),
      guard(() async => accounts = await _api.fetchAccounts(), 'รายการบัญชี'),
    ]);
    _notify();
  }

  Future<void> setQuickRange(QuickRange quick) => setRange(rangeFor(quick), quick: quick);

  Future<void> setRange(DateTimeRange newRange, {QuickRange? quick}) async {
    range = newRange;
    quickRange = quick;
    await _loadDates();
  }

  Future<void> retryDates() => _loadDates();

  Future<void> _loadDates() async {
    final token = ++_datesRequest;
    datesLoaded = false;
    datesError = null;
    _notify();

    try {
      final result = await _api.fetchDocumentDates(start: Fmt.apiDate(range.start), end: Fmt.apiDate(range.end));
      if (token != _datesRequest) return;
      dates = result;
      _sortDates();
    } on ApiException catch (e) {
      if (token != _datesRequest) return;
      dates = [];
      datesError = e.message;
    }
    datesLoaded = true;
    _notify();

    // Open the newest day automatically if nothing (still valid) is selected.
    if (dates.isNotEmpty && !dates.contains(selectedDate)) {
      final newest = dates.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
      await selectDate(newest);
    }
  }

  Future<void> selectDate(String date) async {
    selectedDate = date;
    selectedDocument = null;
    documents = null;
    stats = dayStats[date] ?? DayStats.empty;
    documentsLoaded = false;
    _clearSearchState();
    _notify();
    await reloadDocuments();
  }

  /// Fetches the selected day again. [quiet] keeps the current list on
  /// screen while loading (used after verify / edit / delete).
  Future<void> reloadDocuments({bool quiet = false}) async {
    final date = selectedDate;
    if (date == null) return;
    final token = ++_documentsRequest;
    if (!quiet) {
      documentsLoaded = false;
      documentsError = null;
      _notify();
    }

    try {
      final docs = await _api.fetchDocumentsByDate(date);
      if (token != _documentsRequest || date != selectedDate) return;
      _sortDocuments(docs);
      documents = docs;
      stats = dayStats[date] = DayStats.of(docs);
      documentsError = null;
      _restoreSelection();
    } on ApiException catch (e) {
      if (token != _documentsRequest || date != selectedDate) return;
      if (quiet && documents != null) {
        _notice('รีเฟรชรายการไม่สำเร็จ: ${e.message}');
      } else {
        documentsError = e.message;
      }
    }
    documentsLoaded = true;
    _notify();
  }

  /// Keeps the same document selected after a reload, otherwise picks the
  /// first pending one (or the first document).
  void _restoreSelection() {
    final docs = documents ?? const <PaDocument>[];
    final previous = selectedDocument?.runNo;
    selectedDocument = docs.where((d) => d.runNo == previous).firstOrNull ??
        docs.where((d) => !d.isVerified).firstOrNull ??
        docs.firstOrNull;
  }

  // ------------------------------------------------- sort / filter / search

  void toggleDateSort() {
    datesAscending = !datesAscending;
    _sortDates();
    _notify();
  }

  void _sortDates() => dates.sort((a, b) => datesAscending ? a.compareTo(b) : b.compareTo(a));

  void toggleDocumentSort() {
    documentsAscending = !documentsAscending;
    if (documents != null) _sortDocuments(documents!);
    _notify();
  }

  void _sortDocuments(List<PaDocument> docs) =>
      docs.sort((a, b) => documentsAscending ? a.runNo.compareTo(b.runNo) : b.runNo.compareTo(a.runNo));

  void setFilter(DocFilter value) {
    filter = value;
    _notify();
  }

  /// Debounced PA-number search across all documents.
  void search(String query) {
    final q = query.trim();
    _searchDebounce?.cancel();
    if (q.isEmpty) {
      clearSearch();
      return;
    }
    searchQuery = q;
    _searchDebounce = Timer(const Duration(milliseconds: 250), () => _runSearch(q));
  }

  Future<void> _runSearch(String query) async {
    final stale = _searchIndexAt == null || DateTime.now().difference(_searchIndexAt!) > ApiConfig.searchIndexTtl;
    if (_searchIndex == null || stale) {
      searchLoading = true;
      _notify();
      try {
        await (_searchIndexLoading ??= _loadSearchIndex());
      } finally {
        _searchIndexLoading = null;
        searchLoading = false;
      }
    }
    if (query != searchQuery) return; // user kept typing

    final q = query.toLowerCase();
    _searchResults = (_searchIndex ?? const <PaDocument>[]).where((d) => d.runNo.toLowerCase().contains(q)).toList();
    _notify();
  }

  Future<void> _loadSearchIndex() async {
    try {
      _searchIndex = await _api.fetchAllDocuments();
      _searchIndexAt = DateTime.now();
    } on ApiException catch (e) {
      _notice('โหลดข้อมูลสำหรับค้นหาไม่สำเร็จ: ${e.message}');
    }
  }

  void clearSearch() {
    _clearSearchState();
    _notify();
  }

  void _clearSearchState() {
    _searchDebounce?.cancel();
    searchQuery = '';
    searchLoading = false;
    _searchResults = [];
  }

  void selectDocument(PaDocument doc) {
    selectedDocument = doc;
    _notify();
  }

  // --------------------------------------------------------------- actions

  Future<void> verify(PaDocument doc) async {
    if (doc.isVerified || !canVerify) return;
    final previous = doc.flagCheck;
    doc.flagCheck = 'Y'; // optimistic
    _recountStats();
    _notify();
    try {
      await _api.markVerified(doc.runNo);
      _searchIndexAt = null; // index now stale
    } on ApiException catch (e) {
      doc.flagCheck = previous;
      _recountStats();
      _notice('ตรวจสอบ ${doc.runNo} ไม่สำเร็จ: ${e.message}');
      _notify();
      return;
    }
    await reloadDocuments(quiet: true);
  }

  /// Throws [ApiException] so the account dialog can show the error.
  Future<void> updateAccount(PaDocument doc, PaLine line, Account account) async {
    await _api.updateAccount(runNo: doc.runNo, accountCode: account.code);
    line.accountName = account.name;
    _searchIndexAt = null;
    _notify();
  }

  Future<void> updateRefNo(PaDocument doc, PaLine line, String refNo) async {
    final previous = line.refNo;
    line.refNo = refNo; // optimistic
    _notify();
    try {
      await _api.updateRefNo(runNo: doc.runNo, refNo: refNo);
      _searchIndexAt = null;
    } on ApiException catch (e) {
      line.refNo = previous;
      _notice('บันทึกเลขอ้างอิงไม่สำเร็จ: ${e.message}');
      _notify();
    }
  }

  /// Cancels the given PA and/or CP document numbers, then refreshes.
  /// Throws [ApiException] so the dialog can show the error.
  Future<void> cancelDocuments(List<String> docNos) async {
    try {
      for (final docNo in docNos) {
        await _api.cancelDocument(docNo);
      }
    } finally {
      _searchIndexAt = null;
      _clearSearchState();
      await reloadDocuments(quiet: true);
    }
  }

  // -------------------------------------------------------------- helpers

  void _recountStats() {
    final docs = documents;
    if (docs == null || selectedDate == null) return;
    stats = dayStats[selectedDate!] = DayStats.of(docs);
  }

  void _notice(String message) {
    if (!_disposed) _notices.add(message);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounce?.cancel();
    _notices.close();
    super.dispose();
  }
}
