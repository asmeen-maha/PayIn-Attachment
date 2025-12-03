import 'package:dio/dio.dart';
import 'package:payin_attachment/model/mdListPA.dart';

class Dbconnect {
  String domain = 'http://172.2.100.14/clientele_cm/marketing.php';

  Future<List<ListPA>?> getPA() async {
    List<dynamic> groupByDocDate(List<dynamic> data) {
      Map<String, List<dynamic>> grouped = {};

      for (var item in data) {
        String docdate = item['docdate'];

        if (!grouped.containsKey(docdate)) {
          grouped[docdate] = [];
        }

        var detail = Map<String, dynamic>.from(item);
        // detail.remove('docdate');

        grouped[docdate]!.add(detail);
      }

      return grouped.entries.map((entry) {
        return {
          "docdate": entry.key,
          "details": entry.value,
        };
      }).toList();
    }
    FormData formData = FormData.fromMap({
      "param": "list_PA",
    });
    try {
      Response response = await Dio().post(domain, data: formData);
      if (response.statusCode == 200) {
        var rewData = groupByDocDate(response.data);
        var paData = ListPA.fromJsonList(rewData);
        paData!.sort((a, b) => b.docdate!.compareTo(a.docdate!));
        // print(response.data);
        // print('paData oK! >>$rewData');
        return paData;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}