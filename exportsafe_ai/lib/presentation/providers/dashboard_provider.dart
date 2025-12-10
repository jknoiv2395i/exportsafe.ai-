<<<<<<< HEAD
﻿import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  String userName = 'John Doe';
  int auditsCompleted = 12;
  int moneySaved = 50000;
  int creditsLeft = 5;

  List<AuditHistory> recentAudits = [
    AuditHistory(
      lcNumber: 'LC-9988',
      status: 'REJECTED',
      date: DateTime.now().subtract(Duration(days: 2)),
    ),
    AuditHistory(
      lcNumber: 'LC-9987',
      status: 'PASSED',
      date: DateTime.now().subtract(Duration(days: 5)),
    ),
    AuditHistory(
      lcNumber: 'LC-9986',
      status: 'REJECTED',
      date: DateTime.now().subtract(Duration(days: 8)),
    ),
  ];

  void updateUserData(String name, int audits, int saved, int credits) {
    userName = name;
    auditsCompleted = audits;
    moneySaved = saved;
    creditsLeft = credits;
    notifyListeners();
  }

  void addAuditToHistory(AuditHistory audit) {
    recentAudits.insert(0, audit);
    notifyListeners();
  }
}

class AuditHistory {
  final String lcNumber;
  final String status;
  final DateTime date;

  AuditHistory({
=======
import 'package:flutter/material.dart';

class AuditSummary {
  final String id;
  final String lcNumber;
  final String status;
  final String date;

  AuditSummary({
    required this.id,
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
    required this.lcNumber,
    required this.status,
    required this.date,
  });
}
<<<<<<< HEAD
=======

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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
