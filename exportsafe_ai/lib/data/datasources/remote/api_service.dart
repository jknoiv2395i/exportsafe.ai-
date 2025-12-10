<<<<<<< HEAD
﻿import 'package:http/http.dart' as http;
import 'package:exportsafe_ai/data/models/audit_report.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<AuditReport> auditDocuments({
    required dynamic lcFile,
    required dynamic invoiceFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/audit'));

      // Handle both File and XFile types
      String lcPath = lcFile.path ?? lcFile;
      String invPath = invoiceFile.path ?? invoiceFile;

      request.files.add(await http.MultipartFile.fromPath('lc_file', lcPath));

      request.files.add(
        await http.MultipartFile.fromPath('invoice_file', invPath),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonData = jsonDecode(responseData);
        return AuditReport.fromJson(jsonData);
      } else {
        throw Exception('Failed to audit documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading files: ${e.toString()}');
=======
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../models/audit_report.dart';

class ApiService {
  // Use localhost for Android emulator (10.0.2.2) or local IP for real device
  // For Web/iOS simulator, localhost is fine.
  // Using localhost by default for Web support as requested
  static const String baseUrl = 'http://localhost:8000'; 
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Use this for Android Emulator

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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
    }
  }
}
