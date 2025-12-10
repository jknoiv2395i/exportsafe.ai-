import 'package:flutter/material.dart';

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
    required this.lcNumber,
    required this.status,
    required this.date,
  });
}
