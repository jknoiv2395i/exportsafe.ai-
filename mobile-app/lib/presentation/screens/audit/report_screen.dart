import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/audit_provider.dart';

class ReportScreen extends StatelessWidget {
  final String auditId; // Not used yet, but good for future
  const ReportScreen({super.key, required this.auditId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);
    final report = provider.currentReport;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit Report')),
        body: const Center(child: Text('No report data found.')),
      );
    }

    final isPass = report.status == 'PASS';
    final bannerColor = isPass ? AppTheme.secondaryColor : AppTheme.errorColor;
    final bannerIcon = isPass ? Icons.check_circle : Icons.error;
    final bannerText = isPass ? 'Documents Compliant' : 'Discrepancies Found';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Report'),
        backgroundColor: bannerColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: bannerColor,
              child: Column(
                children: [
                  Icon(bannerIcon, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    bannerText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Risk Score
            Column(
              children: [
                const Text(
                  'Risk Score',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: report.riskScore / 100,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: _getRiskColor(report.riskScore),
                      ),
                    ),
                    Text(
                      '${report.riskScore}/100',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Discrepancy List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Discrepancies (${report.discrepancies.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (report.discrepancies.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No discrepancies found. Good job!'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: report.discrepancies.length,
                      itemBuilder: (context, index) {
                        final discrepancy = report.discrepancies[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  discrepancy.field,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildComparisonRow(
                                  'LC Says:',
                                  discrepancy.lcValue,
                                  Colors.grey.shade700,
                                ),
                                const SizedBox(height: 4),
                                _buildComparisonRow(
                                  'Invoice Says:',
                                  discrepancy.invValue,
                                  AppTheme.errorColor,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          discrepancy.reason,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Download PDF
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Share WhatsApp
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF25D366,
                        ), // WhatsApp Green
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(int score) {
    if (score <= 40) return AppTheme.secondaryColor;
    if (score <= 70) return Colors.orange;
    return AppTheme.errorColor;
  }
}
