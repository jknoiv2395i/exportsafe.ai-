import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/audit/upload_screen.dart';
import '../presentation/screens/dashboard/audit_history_screen.dart';
import '../presentation/screens/audit/report_screen.dart';
import '../presentation/screens/audit/write_lc_screen.dart';
import '../presentation/screens/audit/audit_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/widgets/main_layout.dart';

import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/audit/processing_screen.dart';
import '../presentation/screens/audit/view_lc_screen.dart';

final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/view-lc',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ViewLCScreen(data: data);
      },
    ),
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/audit',
          builder: (context, state) => const UploadScreen(),
        ),
        GoRoute(
          path: '/write-lc',
          builder: (context, state) => const WriteLCScreen(),
        ),
        GoRoute(
          path: '/analyze-documents',
          builder: (context, state) => const AuditScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/report/:auditId',
      builder: (context, state) {
        final auditId = state.pathParameters['auditId']!;
        return ReportScreen(auditId: auditId);
      },
    ),
    GoRoute(
      path: '/processing',
      builder: (context, state) => const ProcessingScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const AuditHistoryScreen(),
    ),
  ],
);
