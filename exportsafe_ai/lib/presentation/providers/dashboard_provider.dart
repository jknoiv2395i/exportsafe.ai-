import 'package:flutter/material.dart';

class AuditSummary {
  final String id;
  final String lcNumber;
  final String status;
  final String date;

  AuditSummary({
    required this.id,
    required this.lcNumber,
    required this.status,
    required this.date,
  });
}

class DashboardProvider with ChangeNotifier {
  // Dummy User Stats
  int auditsDone = 12;
  double moneySaved = 50000;
  int creditsLeft = 5;
  String userName = "Exporter";

  // Dummy Recent Activity
  List<AuditSummary> recentAudits = [
    AuditSummary(id: '1', lcNumber: 'LC-9988', status: 'Rejected', date: '2023-10-25'),
    AuditSummary(id: '2', lcNumber: 'LC-9989', status: 'Approved', date: '2023-10-24'),
    AuditSummary(id: '3', lcNumber: 'LC-9990', status: 'Processing', date: '2023-10-24'),
  ];

  void refreshData() {
    // TODO: Fetch real data from Firestore
    notifyListeners();
  }
}
