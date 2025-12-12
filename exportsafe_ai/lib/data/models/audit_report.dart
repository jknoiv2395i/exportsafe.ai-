<<<<<<< HEAD
﻿class AuditReport {
=======
class AuditReport {
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
  final String status;
  final int riskScore;
  final List<Discrepancy> discrepancies;

  AuditReport({
    required this.status,
    required this.riskScore,
    required this.discrepancies,
  });

  factory AuditReport.fromJson(Map<String, dynamic> json) {
    return AuditReport(
      status: json['status'] ?? 'FAIL',
<<<<<<< HEAD
      riskScore: json['risk_score'] ?? 100,
      discrepancies: (json['discrepancies'] as List?)
              ?.map((d) => Discrepancy.fromJson(d))
=======
      riskScore: json['risk_score'] ?? 0,
      discrepancies: (json['discrepancies'] as List<dynamic>?)
              ?.map((e) => Discrepancy.fromJson(e))
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
              .toList() ??
          [],
    );
  }
<<<<<<< HEAD

  bool get isPassed => status == 'PASS';
=======
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
}

class Discrepancy {
  final String field;
  final String lcValue;
  final String invValue;
  final String reason;
<<<<<<< HEAD
  final String? severity;
=======
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325

  Discrepancy({
    required this.field,
    required this.lcValue,
    required this.invValue,
    required this.reason,
<<<<<<< HEAD
    this.severity = 'HIGH',
=======
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
  });

  factory Discrepancy.fromJson(Map<String, dynamic> json) {
    return Discrepancy(
      field: json['field'] ?? '',
<<<<<<< HEAD
      lcValue: json['lc_value'] ?? json['expected'] ?? '',
      invValue: json['inv_value'] ?? json['actual'] ?? '',
      reason: json['reason'] ?? '',
      severity: json['severity'] ?? 'HIGH',
=======
      lcValue: json['lc_value'] ?? '',
      invValue: json['inv_value'] ?? '',
      reason: json['reason'] ?? '',
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
    );
  }
}
