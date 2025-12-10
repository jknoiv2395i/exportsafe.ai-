import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/audit/upload_screen.dart';
import '../presentation/screens/audit/report_screen.dart';

// Placeholder screens until they are implemented
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Dashboard')), body: const Center(child: Text('Dashboard Placeholder')));
  }
}

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Upload Audit')), body: const Center(child: Text('Upload Placeholder')));
  }
}

class ReportScreen extends StatelessWidget {
  final String auditId;
  const ReportScreen({super.key, required this.auditId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Audit Report')), body: Center(child: Text('Report for $auditId')));
  }
}

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/audit',
      builder: (context, state) => const UploadScreen(),
    ),
    GoRoute(
      path: '/report/:auditId',
      builder: (context, state) {
        final auditId = state.pathParameters['auditId']!;
        return ReportScreen(auditId: auditId);
      },
    ),
  ],
);
