import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:exportsafe_ai/core/theme/app_theme.dart';
import 'package:exportsafe_ai/presentation/providers/dashboard_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                // Stats Row
                Row(
                  children: [
                    _StatCard(
                      label: 'Audits Done',
                      value: '24',
                      icon: Icons.document_scanner,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Money Saved',
                      value: '₹50,000',
                      icon: Icons.currency_rupee,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Credits Left',
                      value: '100',
                      icon: Icons.star,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Start New Audit Button
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Card(
                    color: AppTheme.primaryNavyBlue,
                    child: InkWell(
                      onTap: () => context.go('/audit'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start New Audit',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.recentAudits.length,
                  itemBuilder: (context, index) {
                    final audit = provider.recentAudits[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(audit.lcNumber),
                        subtitle: Text(
                          'Completed on \',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: audit.status == 'PASSED'
                                ? AppTheme.secondaryEmeraldGreen
                                : AppTheme.errorCrimsonRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            audit.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primaryNavyBlue),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
