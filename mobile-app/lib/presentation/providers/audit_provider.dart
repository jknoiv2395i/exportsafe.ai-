import 'package:flutter/material.dart'; // Needed for BuildContext
import 'package:go_router/go_router.dart'; // Needed for context.push
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/models/audit_report.dart';

class AuditProvider with ChangeNotifier {
  PlatformFile? lcFile;
  PlatformFile? invoiceFile;
  bool isProcessing = false;
  AuditReport? currentReport;
  final ApiService _apiService = ApiService();

  bool get canRunAnalysis => lcFile != null && invoiceFile != null;

  Future<void> pickLcFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        lcFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking LC file: $e');
      }
    }
  }

  Future<void> pickInvoiceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        invoiceFile = result.files.first;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking Invoice file: $e');
      }
    }
  }

  void clearFiles() {
    lcFile = null;
    invoiceFile = null;
    currentReport = null;
    notifyListeners();
  }

  Future<void> runAnalysis(BuildContext context) async {
    if (!canRunAnalysis) return;

    isProcessing = true;
    notifyListeners();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      currentReport = await _apiService.auditDocuments(lcFile!, invoiceFile!);
      
      // Save to Firestore
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('audits').add({
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'status': currentReport!.status,
            'riskScore': currentReport!.riskScore,
            'lcFileName': lcFile!.name,
            'invoiceFileName': invoiceFile!.name,
            // Add other fields as needed
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving to Firestore: $e');
        }
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop(); 
        // Navigate to report
        context.push('/report/new_audit');
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}
