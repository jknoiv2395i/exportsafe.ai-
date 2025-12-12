import 'package:flutter/material.dart'; // Needed for BuildContext
import 'package:go_router/go_router.dart'; // Needed for context.push
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
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
        withData: true, // Needed for Web to get bytes
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
        withData: true, // Needed for Web to get bytes
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

    // Navigate to processing screen instead of dialog
    if (context.mounted) {
      context.push('/processing');
    }

    try {
      // Run analysis (no artificial delay needed, UI handles it)
      currentReport = await _apiService.auditDocuments(lcFile!, invoiceFile!);
      
      // Save to Firestore (only if Firebase is initialized)
      try {
        if (Firebase.apps.isNotEmpty) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance.collection('audits').add({
              'userId': user.uid,
              'createdAt': FieldValue.serverTimestamp(),
              'status': currentReport!.status,
              'riskScore': currentReport!.riskScore,
              'lcFileName': lcFile!.name,
              'invoiceFileName': invoiceFile!.name,
            });
          }
        } else {
             if (kDebugMode) {
               print('Firebase not initialized - skipping Firestore save');
             }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error saving to Firestore: $e');
        }
      }
      
      // Note: We do NOT navigate here. The ProcessingScreen watches currentReport
      // and shows the "View Report" button when ready.

    } catch (e) {
      // Go back from processing screen if error
      if (context.mounted) {
        context.pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> mockSuccess(BuildContext context) async {
    isProcessing = true;
    notifyListeners();
    
    if (context.mounted) {
      context.push('/processing');
    }

    await Future.delayed(const Duration(seconds: 4));

    currentReport = AuditReport(
      status: 'FAIL',
      riskScore: 85,
      discrepancies: [
        Discrepancy(
          field: 'Beneficiary Name',
          lcValue: 'ExportSafe AI Ltd.',
          invValue: 'Export Safe AI Limited',
          reason: 'Name mismatch (Spelling)',
        ),
        Discrepancy(
          field: 'Amount',
          lcValue: 'USD 50,000.00',
          invValue: 'USD 50,500.00',
          reason: 'Over-shipment not allowed by LC',
        ),
      ],
    );
    notifyListeners();
    
    if (context.mounted) {
      context.pushReplacement('/report/new_audit');
    }
  }
}
