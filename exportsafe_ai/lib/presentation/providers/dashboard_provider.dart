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
}
