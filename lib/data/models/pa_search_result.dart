/// Result row of the `checkdata` lookup.
class PaSearchResult {
  const PaSearchResult({this.runNo, this.extCode, this.customerName, this.amount});

  final String? runNo;
  final String? extCode;
  final String? customerName;
  final String? amount;

  factory PaSearchResult.fromJson(Map<String, dynamic> json) => PaSearchResult(
        runNo: json['trrunno']?.toString(),
        extCode: json['extcode']?.toString(),
        customerName: json['customer_name']?.toString(),
        amount: json['amount']?.toString(),
      );
}
