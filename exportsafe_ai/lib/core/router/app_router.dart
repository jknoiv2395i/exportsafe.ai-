import 'package:go_router/go_router.dart';
import 'package:exportsafe_ai/presentation/screens/auth/login_screen.dart';
import 'package:exportsafe_ai/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:exportsafe_ai/presentation/screens/audit/upload_screen.dart';
import 'package:exportsafe_ai/presentation/screens/audit/report_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
          final auditId = state.pathParameters['auditId'] ?? '';
          return ReportScreen(auditId: auditId);
        },
      ),
    ],
  );
}
