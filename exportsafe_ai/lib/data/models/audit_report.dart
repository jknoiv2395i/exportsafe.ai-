class AuditReport {
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
      riskScore: json['risk_score'] ?? 100,
      discrepancies: (json['discrepancies'] as List?)
              ?.map((d) => Discrepancy.fromJson(d))
              .toList() ??
          [],
    );
  }

  bool get isPassed => status == 'PASS';
}

class Discrepancy {
  final String field;
  final String lcValue;
  final String invValue;
  final String reason;
  final String? severity;

  Discrepancy({
    required this.field,
    required this.lcValue,
    required this.invValue,
    required this.reason,
    this.severity = 'HIGH',
  });

  factory Discrepancy.fromJson(Map<String, dynamic> json) {
    return Discrepancy(
      field: json['field'] ?? '',
      lcValue: json['lc_value'] ?? json['expected'] ?? '',
      invValue: json['inv_value'] ?? json['actual'] ?? '',
      reason: json['reason'] ?? '',
      severity: json['severity'] ?? 'HIGH',
    );
  }
}
