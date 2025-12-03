class ListPA {
  String? docdate;
  List<Details>? details;

  ListPA({this.docdate, this.details});

  ListPA.fromJson(Map<String, dynamic> json) {
    docdate = json['docdate'];
    if (json['details'] != null) {
      details = <Details>[];
      json['details'].forEach((v) {
        details!.add(new Details.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['docdate'] = docdate;
    if (details != null) {
      data['details'] = details!.map((v) => v.toJson()).toList();
    }
    return data;
  }
  static List<ListPA>? fromJsonList(List list) =>list.map((item) => ListPA.fromJson(item)).toList();

}

class Details {
  String? trrunno;
  String? refno;
  String? amount;
  String? docdate;
  String? extcode;
  String? customerName;
  String? id;
  String? accode;
  String? accname;

  Details(
      {this.trrunno,
      this.refno,
      this.amount,
      this.docdate,
      this.extcode,
      this.customerName,
      this.id,
      this.accode,
      this.accname});

  Details.fromJson(Map<String, dynamic> json) {
    trrunno = json['trrunno'];
    refno = json['refno'];
    amount = json['amount'];
    docdate = json['docdate'];
    extcode = json['extcode'];
    customerName = json['customer_name'];
    id = json['id'];
    accode = json['accode'];
    accname = json['accname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trrunno'] = trrunno;
    data['refno'] = refno;
    data['amount'] = amount;
    data['docdate'] = docdate;
    data['extcode'] = extcode;
    data['customer_name'] = customerName;
    data['id'] = id;
    data['accode'] = accode;
    data['accname'] = accname;
    return data;
  }
}
