import 'package:http/http.dart' as http;
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
    }
  }
}
