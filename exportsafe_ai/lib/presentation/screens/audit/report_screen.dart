import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audit_provider.dart';

class ReportScreen extends StatelessWidget {
  final String auditId;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBUG REPORT'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("DEBUG MODE ACTIVE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("Risk Score: ${report.riskScore}"),
            Text("Status: ${report.status}"),
            Text("Discrepancies: ${report.discrepancies.length}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Go Back"),
            )
          ],
        ),
      ),
    );
  }
}
