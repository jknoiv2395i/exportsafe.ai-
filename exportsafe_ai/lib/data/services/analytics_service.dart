import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logAuditStarted(String lcFilename, String invoiceFilename) async {
    await _analytics.logEvent(
      name: 'audit_started',
      parameters: {
        'lc_file': lcFilename,
        'invoice_file': invoiceFilename,
      },
    );
  }

  Future<void> logAuditCompleted({
    required String status,
    required int riskScore,
    required int discrepancyCount,
  }) async {
    await _analytics.logEvent(
      name: 'audit_completed',
      parameters: {
        'status': status,
        'risk_score': riskScore,
        'discrepancy_count': discrepancyCount,
      },
    );
  }

  Future<void> logError(String error, String context) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_message': error,
        'context': context,
      },
    );
  }
}
