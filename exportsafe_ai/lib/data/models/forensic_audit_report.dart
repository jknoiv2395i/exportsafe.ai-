class ForensicAuditReport {
  final String status;
  final int riskScore;
  final String summary;
  final CorrectedLcData correctedLcData;
  final List<ForensicDiscrepancy> discrepancies;
  final String refinedLcText;

  ForensicAuditReport({
    required this.status,
    required this.riskScore,
    required this.summary,
    required this.correctedLcData,
    required this.discrepancies,
    required this.refinedLcText,
  });

  factory ForensicAuditReport.fromJson(Map<String, dynamic> json) {
    return ForensicAuditReport(
      status: json['status'] ?? 'WARNING',
      riskScore: json['risk_score'] ?? 0,
      summary: json['summary'] ?? '',
      correctedLcData: CorrectedLcData.fromJson(json['corrected_lc_data'] ?? {}),
      discrepancies: (json['discrepancies'] as List?)
              ?.map((d) => ForensicDiscrepancy.fromJson(d))
              .toList() ??
          [],
      refinedLcText: json['refined_lc_text'] ?? '',
    );
  }
}

class CorrectedLcData {
  final String lcNumber;
  final String amount;
  final String currency;
  final String expiryDate;
  final String latestShipmentDate;

  CorrectedLcData({
    required this.lcNumber,
    required this.amount,
    required this.currency,
    required this.expiryDate,
    required this.latestShipmentDate,
  });

  factory CorrectedLcData.fromJson(Map<String, dynamic> json) {
    return CorrectedLcData(
      lcNumber: json['lc_number'] ?? '',
      amount: json['amount'] ?? '',
      currency: json['currency'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      latestShipmentDate: json['latest_shipment_date'] ?? '',
    );
  }
}

class ForensicDiscrepancy {
  final String field;
  final String originalText;
  final String correctedValue;
  final String issueType;
  final String severity;
  final String explanation;

  ForensicDiscrepancy({
    required this.field,
    required this.originalText,
    required this.correctedValue,
    required this.issueType,
    required this.severity,
    required this.explanation,
  });

  factory ForensicDiscrepancy.fromJson(Map<String, dynamic> json) {
    return ForensicDiscrepancy(
      field: json['field'] ?? '',
      originalText: json['original_text'] ?? '',
      correctedValue: json['corrected_value'] ?? '',
      issueType: json['issue_type'] ?? '',
      severity: json['severity'] ?? 'LOW',
      explanation: json['explanation'] ?? '',
    );
  }
}
