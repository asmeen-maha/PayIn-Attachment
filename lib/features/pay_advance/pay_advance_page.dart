import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../data/models/pa_document.dart';
import 'dialogs/cancel_document_dialog.dart';
import 'dialogs/edit_ref_dialogs.dart';
import 'dialogs/report_preview_dialog.dart';
import 'dialogs/select_account_dialog.dart';
import 'pay_advance_controller.dart';
import 'report/pa_report.dart';
import 'widgets/date_list_panel.dart';
import 'widgets/date_range_field.dart';
import 'widgets/document_card.dart';
import 'widgets/document_list_header.dart';
import 'widgets/slip_panel.dart';
import 'widgets/user_badge.dart';

/// Pay Advance screen: dates (left) · documents (center) · slip (right).
class PayAdvancePage extends StatefulWidget {
  const PayAdvancePage({super.key});

  @override
  State<PayAdvancePage> createState() => _PayAdvancePageState();
}

class _PayAdvancePageState extends State<PayAdvancePage> {
  final _controller = PayAdvanceController();
  final _searchField = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncSearchField);
    _controller.init();
  }

  @override
  void dispose() {
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
    final date = _controller.selectedDate;
    if (date == null) return;
    _controller.clearSearch();

    final pdf = await PaReport.generate(date: DateTime.parse(date), documents: _controller.reportDocuments);
    if (!mounted) return;
    await showReportPreview(
      context,
      pdf: pdf,
      fileName: 'รายงานเงินรับล่วงหน้าคงเหลือ ${Fmt.dashedDate(DateTime.parse(date))}',
    );
  }

  void _openCancelDialog(PaDocument doc) {
    if (!_controller.canEdit) return;
    showCancelDocumentDialog(context, document: doc, onCancelDocument: _controller.cancelDocument);
  }

  Future<void> _editAccount(PaDocument doc, PaLine line) async {
    await showSelectAccountDialog(
      context,
      accounts: _controller.accounts,
      onSave: (account) => _controller.updateAccount(doc, line, account),
    );
  }

  Future<void> _editRefNo(PaDocument doc, PaLine line) async {
    final newRef = await showEditRefNoDialog(context, line.refNo);
    if (newRef != null) await _controller.updateRefNo(doc, line, newRef);
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final c = _controller;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _appBar(),
          body: Row(
            children: [
              Container(
                width: width * .09,
                padding: const EdgeInsets.all(5),
                child: DateListPanel(
                  dates: c.dates,
                  loaded: c.datesLoaded,
                  selectedDate: c.selectedDate,
                  ascending: c.datesAscending,
                  onSelect: c.selectDate,
                  onToggleSort: c.toggleDateSort,
                ),
              ),
              Container(
                width: width * .64,
                padding: const EdgeInsets.all(5),
                child: _documentsColumn(),
              ),
              if (c.selectedDocument != null) Expanded(child: SlipPanel(document: c.selectedDocument!)),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 70,
      backgroundColor: AppColors.primary,
      centerTitle: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 300,
            child: DateRangeField(
              initialRange: PayAdvanceController.defaultRange,
              onChanged: _controller.loadDates,
            ),
          ),
          UserBadge(user: _controller.user),
        ],
      ),
    );
  }

  Widget _documentsColumn() {
    final c = _controller;
    final selectedDate = c.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentListHeader(
          date: selectedDate != null ? DateTime.parse(selectedDate) : DateTime.now(),
          showSort: c.documentsLoaded && (c.documents?.isNotEmpty ?? false),
          ascending: c.documentsAscending,
          onToggleSort: c.toggleDocumentSort,
          searchController: _searchField,
          onSearch: c.search,
          onClearSearch: c.clearSearch,
          onPrint: selectedDate != null && c.documents != null ? _printReport : null,
        ),
        Expanded(
          child: selectedDate == null
              ? const EmptyState(icon: Icons.inbox_rounded, message: 'ไม่พบข้อมูล')
              : c.documentsLoaded
                  ? _documentList()
                  : const LoadingIndicator(),
        ),
      ],
    );
  }

  Widget _documentList() {
    final c = _controller;
    final docs = c.visibleDocuments;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      itemBuilder: (_, i) {
        final doc = docs[i];
        return DocumentCard(
          document: doc,
          selected: doc.id == c.selectedDocument?.id,
          canEdit: c.canEdit,
          onTap: () => c.selectDocument(doc),
          onDocNoTap: () => _openCancelDialog(doc),
          onVerify: () => c.verify(doc),
          onEditAccount: (line) => _editAccount(doc, line),
          onEditRefNo: (line) => _editRefNo(doc, line),
        );
      },
    );
  }
}
