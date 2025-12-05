import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/audit_report.dart';

class ApiService {
  // Use localhost for Android emulator (10.0.2.2) or local IP for real device
  // For Web/iOS simulator, localhost is fine.
  // Assuming Android Emulator for now as per guide suggestion
  static const String baseUrl = 'http://10.0.2.2:8000'; 
  // static const String baseUrl = 'http://localhost:8000'; 

  Future<AuditReport> auditDocuments(PlatformFile lcFile, PlatformFile invoiceFile) async {
    final uri = Uri.parse('$baseUrl/audit');
    final request = http.MultipartRequest('POST', uri);

    // Add files
    // For web, we might need to use bytes. For mobile, path.
    if (lcFile.path != null) {
      request.files.add(await http.MultipartFile.fromPath('lc_file', lcFile.path!));
    } else if (lcFile.bytes != null) {
       request.files.add(http.MultipartFile.fromBytes('lc_file', lcFile.bytes!, filename: lcFile.name));
    }

    if (invoiceFile.path != null) {
      request.files.add(await http.MultipartFile.fromPath('invoice_file', invoiceFile.path!));
    } else if (invoiceFile.bytes != null) {
       request.files.add(http.MultipartFile.fromBytes('invoice_file', invoiceFile.bytes!, filename: invoiceFile.name));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AuditReport.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to audit documents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
}
