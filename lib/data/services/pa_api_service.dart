import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';
import '../mappers/pa_document_mapper.dart';
import '../models/access_flag.dart';
import '../models/account.dart';
import '../models/pa_document.dart';
import '../models/pa_search_result.dart';

/// All calls to the marketing.php backend.
///
/// Read calls return an empty result on failure (and log it);
/// write calls throw so the caller can react.
class PaApiService {
  PaApiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  // ---------------------------------------------------------------- reads

  /// Dates (`yyyy-MM-dd`) that have PA documents within the range.
  Future<List<String>> fetchDocumentDates({required String start, required String end}) async {
    final rows = await _read('list_PA2', {'startdate': start, 'enddate': end});
    return rows.map((row) => row['docdate'].toString()).toList();
  }

  /// PA documents for one day.
  Future<List<PaDocument>> fetchDocumentsByDate(String docDate) async {
    final rows = await _read('list_PA_Detail', {'docdate': docDate});
    return groupRowsIntoDocuments(rows);
  }

  /// Every PA document — used for searching by PA number.
  Future<List<PaDocument>> fetchAllDocuments() async {
    final rows = await _read('search_PA');
    return groupRowsIntoDocuments(rows);
  }

  Future<List<PaSearchResult>> searchByRunNo(String runNo) async {
    final rows = await _read('checkdata', {'trrunno': runNo});
    return rows.map(PaSearchResult.fromJson).toList();
  }

  Future<List<Account>> fetchAccounts() async {
    final rows = await _read('listacc');
    return rows.map(Account.fromJson).toList();
  }

  /// The logged-in user (edit/delete permission).
  Future<AccessFlag?> fetchCurrentUser() async {
    final rows = await _read('checkprint');
    return rows.isEmpty ? null : AccessFlag.fromJson(rows.first);
  }

  /// The user's department (verify permission).
  Future<AccessFlag?> fetchDepartment() async {
    final rows = await _read('checkdept');
    return rows.isEmpty ? null : AccessFlag.fromJson(rows.first);
  }

  // --------------------------------------------------------------- writes

  Future<void> markVerified(String runNo) => _write('ins_datacheck2', {'trrunno': runNo});

  Future<void> updateAccount({required String runNo, required String accountCode}) =>
      _write('up_ref', {'trrunno': runNo, 'txt_edit': accountCode, 'type_edit': 'accode'});

  Future<void> updateRefNo({required String runNo, required String refNo}) =>
      _write('up_ref', {'trrunno': runNo, 'txt_edit': refNo, 'type_edit': 'ref'});

  /// Cancels a PA or CP document.
  Future<void> cancelDocument(String docNo) => _write('docpaycancel', {'trrunno': docNo});

  // -------------------------------------------------------------- helpers

  Future<Response<dynamic>> _post(String param, Map<String, dynamic> fields) {
    return _dio.post(ApiConfig.endpoint, data: FormData.fromMap({'param': param, ...fields}));
  }

  Future<List<Map<String, dynamic>>> _read(String param, [Map<String, dynamic> fields = const {}]) async {
    try {
      final response = await _post(param, fields);
      final data = response.data;
      if (response.statusCode == 200 && data is List) {
        return data.map((row) => Map<String, dynamic>.from(row as Map)).toList();
      }
    } catch (e) {
      debugPrint('[PaApi] $param failed: $e');
    }
    return const [];
  }

  Future<void> _write(String param, Map<String, dynamic> fields) async {
    debugPrint('[PaApi] $param $fields');
    await _post(param, fields);
  }
}
