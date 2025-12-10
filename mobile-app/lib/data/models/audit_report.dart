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
      riskScore: json['risk_score'] ?? 0,
      discrepancies: (json['discrepancies'] as List<dynamic>?)
              ?.map((e) => Discrepancy.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Discrepancy {
  final String field;
  final String lcValue;
  final String invValue;
  final String reason;

  Discrepancy({
    required this.field,
    required this.lcValue,
    required this.invValue,
    required this.reason,
  });

  factory Discrepancy.fromJson(Map<String, dynamic> json) {
    return Discrepancy(
      field: json['field'] ?? '',
      lcValue: json['lc_value'] ?? '',
      invValue: json['inv_value'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}
