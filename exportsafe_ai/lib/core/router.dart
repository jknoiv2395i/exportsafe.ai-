import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/audit/upload_screen.dart';
import '../presentation/screens/audit/report_screen.dart';
import '../presentation/screens/audit/write_lc_screen.dart';
import '../presentation/widgets/main_layout.dart';

import '../presentation/screens/splash/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
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
      ],
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
