import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../models/forensic_audit_report.dart';

class ForensicApiService {
  // Reuse base URL logic from existing service or define constant
  static const String baseUrl = 'http://localhost:8000'; 

  Future<ForensicAuditReport> auditDocuments(PlatformFile lcFile, PlatformFile invoiceFile) async {
    final uri = Uri.parse('$baseUrl/forensic-audit');
    final request = http.MultipartRequest('POST', uri);

    // Add files (Shared logic with main ApiService)
    if (kIsWeb) {
      if (lcFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('lc_file', lcFile.bytes!, filename: lcFile.name));
      }
      if (invoiceFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('invoice_file', invoiceFile.bytes!, filename: invoiceFile.name));
      }
    } else {
      if (lcFile.path != null) {
        request.files.add(await http.MultipartFile.fromPath('lc_file', lcFile.path!));
      }
      if (invoiceFile.path != null) {
        request.files.add(await http.MultipartFile.fromPath('invoice_file', invoiceFile.path!));
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return ForensicAuditReport.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to perform forensic audit: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to forensic server: $e');
    }
  }
}
