import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';
import '../mappers/pa_document_mapper.dart';
import '../models/access_flag.dart';
import '../models/account.dart';
import '../models/pa_document.dart';
import '../models/pa_search_result.dart';

/// Thrown when the backend cannot be reached or returns an unexpected reply.
class ApiException implements Exception {
  const ApiException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'ApiException($message, $cause)';
}

/// All calls to the marketing.php backend.
///
/// Every call throws [ApiException] on network / server failure, so the UI
/// can tell "no data" apart from "could not load".
class PaApiService {
  PaApiService({Dio? dio}) : _dio = dio ?? Dio(_defaultOptions);

  static final BaseOptions _defaultOptions = BaseOptions(
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
    sendTimeout: ApiConfig.sendTimeout,
  );

  final Dio _dio;

  // ---------------------------------------------------------------- reads

  /// Dates (`yyyy-MM-dd`) that have PA documents within the range.
  /// Rows with a missing or malformed date are skipped.
  Future<List<String>> fetchDocumentDates({required String start, required String end}) async {
    final rows = await _read('list_PA2', {'startdate': start, 'enddate': end});
    return rows
        .map((row) => row['docdate']?.toString() ?? '')
        .where((d) => DateTime.tryParse(d) != null)
        .toSet()
        .toList();
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

  Future<Response<dynamic>> _post(String param, Map<String, dynamic> fields) async {
    try {
      final response = await _dio.post(ApiConfig.endpoint, data: FormData.fromMap({'param': param, ...fields}));
      if (response.statusCode != 200) {
        throw ApiException('เซิร์ฟเวอร์ตอบกลับผิดปกติ (${response.statusCode})');
      }
      return response;
    } on DioException catch (e) {
      debugPrint('[PaApi] $param failed: ${e.type} ${e.message}');
      throw ApiException(_describe(e), e);
    }
  }

  Future<List<Map<String, dynamic>>> _read(String param, [Map<String, dynamic> fields = const {}]) async {
    var data = (await _post(param, fields)).data;
    // PHP may send JSON with a text/html content type → Dio gives a String.
    if (data is String && data.trim().isNotEmpty) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        debugPrint('[PaApi] $param non-JSON reply: ${data.length > 200 ? data.substring(0, 200) : data}');
        throw const ApiException('รูปแบบข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง');
      }
    }
    // The backend returns `null`, `""` or `false` when there are no rows.
    if (data == null || data == '' || data == false) return const [];
    if (data is! List) {
      debugPrint('[PaApi] $param unexpected payload: ${data.runtimeType}');
      throw const ApiException('รูปแบบข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง');
    }
    return data.whereType<Map>().map((row) => Map<String, dynamic>.from(row)).toList();
  }

  Future<void> _write(String param, Map<String, dynamic> fields) async {
    debugPrint('[PaApi] $param $fields');
    await _post(param, fields);
  }

  static String _describe(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'เซิร์ฟเวอร์ตอบสนองช้าเกินไป',
        DioExceptionType.connectionError => 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้',
        DioExceptionType.badResponse => 'เซิร์ฟเวอร์ตอบกลับผิดปกติ (${e.response?.statusCode})',
        _ => 'เกิดข้อผิดพลาดในการเชื่อมต่อ',
      };
}
