import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/datasources/remote/forensic_api_service.dart';
import '../../data/models/forensic_audit_report.dart';
import '../screens/audit/forensic_audit_screen.dart';

class ForensicAuditProvider extends ChangeNotifier {
  final ForensicApiService _apiService = ForensicApiService();

  PlatformFile? _lcFile;
  PlatformFile? _invoiceFile;
  bool _isProcessing = false;
  ForensicAuditReport? _report;
  String? _error;

  PlatformFile? get lcFile => _lcFile;
  PlatformFile? get invoiceFile => _invoiceFile;
  bool get isProcessing => _isProcessing;
  ForensicAuditReport? get report => _report;
  String? get error => _error;

  bool get canRunAnalysis => _lcFile != null && _invoiceFile != null && !_isProcessing;

  Future<void> pickLcFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        _lcFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking LC file: $e');
    }
  }

  Future<void> pickInvoiceFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        _invoiceFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking Invoice file: $e');
    }
  }

  Future<void> runAnalysis(BuildContext context) async {
    if (!canRunAnalysis) return;

    _isProcessing = true;
    _error = null;
    notifyListeners();

    try {
      final report = await _apiService.auditDocuments(_lcFile!, _invoiceFile!);
      _report = report;
      _isProcessing = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ForensicAuditScreen(report: report),
          ),
        );
      }
    } catch (e) {
      _isProcessing = false;
      _error = e.toString();
      notifyListeners();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
