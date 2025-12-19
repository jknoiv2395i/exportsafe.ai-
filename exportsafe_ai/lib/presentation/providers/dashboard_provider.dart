import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuditSummary {
  final String id;
  final String lcNumber;
  final String status;
  final String date;

  AuditSummary({
    required this.id,
    required this.lcNumber,
    required this.status,
    required this.date,
  });
}

class DashboardProvider with ChangeNotifier {
  // Real Data Streams
  Stream<List<Map<String, dynamic>>> get recentAuditsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('audits')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              // Add ID to data for navigation
              data['id'] = doc.id;
              return data;
            }).toList());
  }
  // Aggregated Stats Stream
  Stream<Map<String, dynamic>> get dashboardStatsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value({
        'riskScore': 0,
        'moneySaved': 0,
        'pendingCount': 0,
      });
    }

    return FirebaseFirestore.instance
        .collection('audits')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      int totalAudits = snapshot.docs.length;
      int failedAudits = 0;
      int pendingAudits = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] as String?)?.toUpperCase() ?? 'UNKNOWN';

        if (status == 'FAIL' || status == 'RISK') {
          failedAudits++;
        } else if (status == 'PENDING' || status == 'PROCESSING') {
          pendingAudits++;
        }
      }

      // Calculate Risk Score (Percentage of non-passing audits)
      // If 0 audits, risk is 0. If all failed, risk is 100.
      double riskScore = totalAudits > 0 ? (failedAudits / totalAudits) * 100 : 0;

      // Calculate Money Saved (Dummy Logic: ₹5k saved per audit processed)
      // Only count processed audits (Pass/Fail)
      int processedAudits = totalAudits - pendingAudits;
      int moneySaved = processedAudits * 5; // 5k per audit

      return {
        'riskScore': riskScore.round(),
        'moneySaved': moneySaved,
        'pendingCount': pendingAudits,
      };
    });
  }
}
