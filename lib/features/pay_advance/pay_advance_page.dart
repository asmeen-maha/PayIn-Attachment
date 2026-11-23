import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/models/pa_document.dart';
import '../../data/services/pa_api_service.dart';
import 'dialogs/cancel_document_dialog.dart';
import 'dialogs/edit_ref_dialogs.dart';
import 'dialogs/report_preview_dialog.dart';
import 'dialogs/select_account_dialog.dart';
import 'pay_advance_controller.dart';
import 'report/pa_report.dart';
import 'widgets/date_list_panel.dart';
import 'widgets/document_card.dart';
import 'widgets/document_toolbar.dart';
import 'widgets/kpi_row.dart';
import 'widgets/slip_panel.dart';
import 'widgets/top_nav_bar.dart';

/// Pay Advance screen ("Lagoon" design):
/// nav bar · dates | KPIs + document cards | slip.
class PayAdvancePage extends StatefulWidget {
  const PayAdvancePage({super.key, this.api});

  /// Injectable for tests; defaults to the real backend.
  final PaApiService? api;

  @override
  State<PayAdvancePage> createState() => _PayAdvancePageState();
}

class _PayAdvancePageState extends State<PayAdvancePage> {
  static const double _gap = 14;

  late final _controller = PayAdvanceController(api: widget.api);
  final _searchField = TextEditingController();
  late final StreamSubscription<String> _noticeSub;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncSearchField);
    _noticeSub = _controller.notices.listen(_showError);
    _controller.init();
  }

  @override
  void dispose() {
    _noticeSub.cancel();
    _controller.dispose();
    _searchField.dispose();
    super.dispose();
  }

  /// Keeps the search box empty when the controller resets the query.
  void _syncSearchField() {
    if (!_controller.isSearching && _searchField.text.isNotEmpty) _searchField.clear();
  }

  // ------------------------------------------------------------- actions

  Future<void> _printReport() async {
    final date = DateTime.tryParse(_controller.selectedDate ?? '');
    if (date == null || _printing) return;
    final docs = _controller.reportDocuments;
    if (docs.isEmpty) {
      _showError('ยังไม่มีเอกสารที่ตรวจแล้วในวันนี้');
      return;
    }
    _controller.clearSearch();

    setState(() => _printing = true);
    try {
      final pdf = await PaReport.generate(date: date, documents: docs);
      if (!mounted) return;
      await showReportPreview(context, pdf: pdf, fileName: 'รายงานเงินรับล่วงหน้าคงเหลือ ${Fmt.dashedDate(date)}');
    } catch (e) {
      debugPrint('Report failed: $e');
      _showError('สร้างรายงานไม่สำเร็จ');
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  void _delete(PaDocument doc) {
    showCancelDocumentDialog(context, document: doc, onCancel: _controller.cancelDocuments);
  }

  Future<void> _editAccount(PaDocument doc) async {
    final line = doc.lines.firstOrNull;
    if (line == null) return;
    await showSelectAccountDialog(
      context,
      accounts: _controller.accounts,
      currentName: line.accountName,
      onSave: (account) => _controller.updateAccount(doc, line, account),
    );
  }

  Future<void> _editRefNo(PaDocument doc) async {
    final line = doc.lines.firstOrNull;
    if (line == null) return;
    final newRef = await showEditRefNoDialog(context, line.refNo);
    if (newRef != null) await _controller.updateRefNo(doc, line, newRef);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        width: 440,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(message, style: AppText.body(13, color: Colors.white)),
      ),
    );
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LagoonBackground(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final c = _controller;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TopNavBar(
                    range: c.range,
                    quickRange: c.quickRange,
                    onRangeChanged: c.setRange,
                    onQuickRange: c.setQuickRange,
                    user: c.user,
                    printing: _printing,
                    onPrint: c.selectedDate != null && c.documents != null && !_printing ? _printReport : null,
                  ),
                  const SizedBox(height: _gap),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 188,
                          child: DateListPanel(
                            dates: c.dates,
                            loaded: c.datesLoaded,
                            selectedDate: c.selectedDate,
                            ascending: c.datesAscending,
                            stats: c.dayStats,
                            onSelect: c.selectDate,
                            onToggleSort: c.toggleDateSort,
                            error: c.datesError,
                            onRetry: c.retryDates,
                          ),
                        ),
                        const SizedBox(width: _gap),
                        Expanded(child: _centerColumn()),
                        const SizedBox(width: _gap),
                        SizedBox(
                          width: 352,
                          child: SlipPanel(
                            document: c.selectedDocument,
                            canVerify: c.canVerify,
                            onVerify: () {
                              final doc = c.selectedDocument;
                              if (doc != null) c.verify(doc);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _centerColumn() {
    final c = _controller;
    final date = c.selectedDate == null ? null : DateTime.parse(c.selectedDate!);
    final stats = c.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KpiRow(stats: stats, date: date),
        const SizedBox(height: _gap),
        DocumentToolbar(
          date: date,
          stats: stats,
          filter: c.filter,
          onFilter: c.setFilter,
          ascending: c.documentsAscending,
          onToggleSort: c.toggleDocumentSort,
          searchController: _searchField,
          onSearch: c.search,
          onClearSearch: c.clearSearch,
        ),
        const SizedBox(height: _gap),
        Expanded(child: _documentArea()),
      ],
    );
  }

  Widget _documentArea() {
    final c = _controller;

    if (c.selectedDate == null && !c.isSearching) {
      if (c.datesError != null) {
        return const EmptyState(
          icon: Icons.cloud_off_rounded,
          message: 'ยังโหลดรายการวันที่ไม่ได้',
          hint: 'กด "ลองใหม่" ที่คอลัมน์วันที่',
        );
      }
      return c.datesLoaded && c.dates.isEmpty
          ? const EmptyState(icon: Icons.event_busy_outlined, message: 'ไม่มีเอกสารในช่วงวันที่นี้', hint: 'ลองเลือกช่วงวันที่อื่น')
          : const EmptyState(icon: Icons.inbox_outlined, message: 'เลือกวันที่เพื่อดูเอกสาร');
    }
    if (c.isSearching && c.searchLoading) return const LoadingIndicator();
    if (!c.isSearching) {
      if (!c.documentsLoaded) return const LoadingIndicator();
      if (c.documentsError != null) {
        return ErrorState(message: c.documentsError!, onRetry: c.reloadDocuments);
      }
    }

    final docs = c.visibleDocuments;
    if (docs.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        message: c.isSearching ? 'ไม่พบหมายเลข PA "${c.searchQuery}"' : 'ไม่มีเอกสารในตัวกรองนี้',
      );
    }

    // Two-column card grid; each row takes the height of its taller card.
    final rows = (docs.length / 2).ceil();
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.black, Colors.transparent],
        stops: [0, .94, 1],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: rows,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, row) {
          final left = docs[row * 2];
          final right = row * 2 + 1 < docs.length ? docs[row * 2 + 1] : null;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _card(left)),
                const SizedBox(width: 12),
                Expanded(child: right == null ? const SizedBox() : _card(right)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(PaDocument doc) {
    final c = _controller;
    return DocumentCard(
      document: doc,
      selected: doc.runNo == c.selectedDocument?.runNo,
      canEdit: c.canEdit,
      canVerify: c.canVerify,
      onTap: () => c.selectDocument(doc),
      onVerify: () => c.verify(doc),
      onEditAccount: () => _editAccount(doc),
      onEditRefNo: () => _editRefNo(doc),
      onDelete: () => _delete(doc),
    );
  }
}
