import '../../core/utils/json.dart';

/// One Pay Advance (PA) document, made of one or more account lines.
class PaDocument {
  PaDocument({
    required this.runNo,
    this.id,
    this.docDate,
    this.extCode,
    this.customerName,
    this.accountCode,
    this.slipUrl,
    this.flagCheck,
    this.cpDocNo,
    this.lines = const [],
  });

  final String runNo; // trrunno
  final String? id;
  final String? docDate;
  final String? extCode;
  final String? customerName;
  final String? accountCode;
  final String? slipUrl; // picurl (image or PDF)
  final String? cpDocNo; // doccp — linked CP document, if any
  String? flagCheck; // 'Y' once finance has verified it
  final List<PaLine> lines;

  bool get isVerified => flagCheck == 'Y';
  bool get hasSlip => slipUrl?.isNotEmpty ?? false;
  bool get slipIsPdf => slipUrl?.toLowerCase().contains('.pdf') ?? false;
  String get customerLabel => '${extCode ?? ''} ${customerName ?? ''}';

  /// Sum of all line amounts.
  double get amount => lines.fold(0, (sum, line) => sum + line.amount);
}

/// One account line of a PA document.
class PaLine {
  PaLine({this.accountName, this.refNo, this.amount = 0});

  String? accountName;
  String? refNo;
  final double amount;

  factory PaLine.fromJson(Map<String, dynamic> json) => PaLine(
        accountName: asString(json['accname']),
        refNo: asString(json['refno']),
        amount: asDouble(json['amount']),
      );
}
