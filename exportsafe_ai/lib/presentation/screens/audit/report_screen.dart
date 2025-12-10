import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:exportsafe_ai/core/theme/app_theme.dart';
import 'package:exportsafe_ai/presentation/providers/audit_provider.dart';

class ReportScreen extends StatelessWidget {
  final String auditId;

  const ReportScreen({super.key, required this.auditId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Consumer<AuditProvider>(
        builder: (context, auditProvider, _) {
          final report = auditProvider.auditResult;

          if (report == null) {
            return const Center(child: Text('No audit result available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: report.isPassed
                      ? AppTheme.secondaryEmeraldGreen
                      : AppTheme.errorCrimsonRed,
                  child: Column(
                    children: [
                      Icon(
                        report.isPassed ? Icons.check_circle : Icons.warning,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        report.isPassed
                            ? 'Documents Compliant ✓'
                            : 'Discrepancies Found ⚠',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Risk Score
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk Score',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: report.riskScore / 100,
                                        strokeWidth: 8,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              report.riskScore < 40
                                                  ? AppTheme
                                                        .secondaryEmeraldGreen
                                                  : report.riskScore < 70
                                                  ? Colors.orange
                                                  : AppTheme.errorCrimsonRed,
                                            ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${report.riskScore}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.displaySmall,
                                          ),
                                          Text(
                                            '/100',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Discrepancies
                      if (report.discrepancies.isNotEmpty) ...[
                        Text(
                          'Discrepancies Found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: report.discrepancies.length,
                          itemBuilder: (context, index) {
                            final disc = report.discrepancies[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          disc.field,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: disc.severity == 'HIGH'
                                                ? AppTheme.errorCrimsonRed
                                                : Colors.orange,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            disc.severity ?? 'HIGH',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _DiscrepancyRow(
                                      label: 'LC Says:',
                                      value: disc.lcValue,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    _DiscrepancyRow(
                                      label: 'Invoice Says:',
                                      value: disc.invValue,
                                      color: AppTheme.errorCrimsonRed,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Reason: ${disc.reason}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        Card(
                          color: AppTheme.secondaryEmeraldGreen.withOpacity(
                            0.1,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.secondaryEmeraldGreen,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No discrepancies found. Documents are compliant!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.secondaryEmeraldGreen,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'PDF download feature coming soon',
                                ),
                              ),
                            );
                          },
                          child: const Text('Download PDF Report'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('WhatsApp sharing coming soon'),
                              ),
                            );
                          },
                          child: const Text('Share on WhatsApp'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<AuditProvider>().reset();
                            context.go('/dashboard');
                          },
                          child: const Text('Start New Audit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiscrepancyRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DiscrepancyRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}
