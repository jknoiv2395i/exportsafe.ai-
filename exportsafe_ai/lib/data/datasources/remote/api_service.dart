import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../models/audit_report.dart';

class ApiService {
  // Use localhost for Android emulator (10.0.2.2) or local IP for real device
  // For Web/iOS simulator, localhost is fine.
  // Using localhost by default for Web support as requested
  // Cloud Backend (Render)
  static const String baseUrl = 'https://exportsafe-ai-1.onrender.com';
  // static const String baseUrl = 'http://127.0.0.1:8000'; // Localhost fallback

  Future<AuditReport> auditDocuments(PlatformFile lcFile, PlatformFile invoiceFile) async {
    final uri = Uri.parse('$baseUrl/audit');
    final request = http.MultipartRequest('POST', uri);

    // Add files
    if (kIsWeb) {
      // Web: Use bytes
      if (lcFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('lc_file', lcFile.bytes!, filename: lcFile.name));
      }
      if (invoiceFile.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('invoice_file', invoiceFile.bytes!, filename: invoiceFile.name));
      }
    } else {
      // Mobile/Desktop: Use path
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
        return AuditReport.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to audit documents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<Map<String, dynamic>> generateLcDraft({
    required List<PlatformFile> files,
    String routeType = "Maritime",
  }) async {
    final uri = Uri.parse('$baseUrl/generate-lc');
    final request = http.MultipartRequest('POST', uri);
    
    // Add Route Type
    request.fields['route_type'] = routeType;

    // Add files
    for (var file in files) {
      if (kIsWeb) {
        if (file.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes('files', file.bytes!, filename: file.name));
        }
      } else {
        if (file.path != null) {
          request.files.add(await http.MultipartFile.fromPath('files', file.path!));
        }
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to generate draft: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to AI service: $e');
    }
  }
}
