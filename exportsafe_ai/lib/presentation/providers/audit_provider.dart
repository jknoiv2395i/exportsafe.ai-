import 'package:flutter/material.dart';
import 'package:exportsafe_ai/data/datasources/remote/api_service.dart';
import 'package:exportsafe_ai/data/models/audit_report.dart';
import 'package:file_picker/file_picker.dart';

class AuditProvider extends ChangeNotifier {
  PlatformFile? lcFile;
  PlatformFile? invoiceFile;
  bool isLoading = false;
  AuditReport? auditResult;
  String? errorMessage;

  void setLcFile(dynamic file) {
    if (file is PlatformFile) {
      lcFile = file;
    } else if (file.runtimeType.toString().contains('XFile')) {
      // Handle XFile from file_picker
      lcFile = PlatformFile(
        name: file.name ?? 'document',
        size: 0,
        path: file.path,
      );
    }
    notifyListeners();
  }

  void setInvoiceFile(dynamic file) {
    if (file is PlatformFile) {
      invoiceFile = file;
    } else if (file.runtimeType.toString().contains('XFile')) {
      // Handle XFile from file_picker
      invoiceFile = PlatformFile(
        name: file.name ?? 'document',
        size: 0,
        path: file.path,
      );
    }
    notifyListeners();
  }

  bool get canRunAnalysis => lcFile != null && invoiceFile != null;

  Future<AuditReport?> runAudit() async {
    if (!canRunAnalysis) return null;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiService = ApiService();
      final result = await apiService.auditDocuments(
        lcFile: lcFile!,
        invoiceFile: invoiceFile!,
      );

      auditResult = result;
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    lcFile = null;
    invoiceFile = null;
    auditResult = null;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }
}
