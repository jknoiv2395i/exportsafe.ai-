import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/audit_provider.dart';
import '../../../data/models/audit_report.dart';

class ReportScreen extends StatelessWidget {
  final String? auditId;

  const ReportScreen({super.key, this.auditId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);
    final report = provider.currentReport;
    final primaryRed = const Color(0xFFFF3B3B);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isSuccess = report.status == 'PASS';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryRed.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryRed.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Back Button (Custom)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => context.go('/dashboard'),
                    ),
                  ),
                ),

                const Spacer(), // Push content to center vertically

                // Central Icon & Text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Stack
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.description,
                              size: 100,
                              color: isDark ? Colors.grey[700] : const Color(0xFF334155),
                            ),
                          ),
                          // Badge
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSuccess ? primaryRed : const Color(0xFFB00020),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isSuccess ? primaryRed : const Color(0xFFB00020)).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              ),
                              child: Icon(
                                isSuccess ? Icons.check : Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      isSuccess ? "File Validated!" : "Validation Failed",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        isSuccess 
                          ? "All legal and compliance checks passed successfully."
                          : "Critical discrepancies were found during the audit process.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(), // Push Bottom Card down

                // Bottom Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.15),
                        blurRadius: 40,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isSuccess ? "No Discrepancies Found" : "${report.discrepancies.length} Discrepancies Found",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF333333),
                              ),
                            ),
                          ),
                          Icon(
                            isSuccess ? Icons.check_circle : Icons.error,
                            color: isSuccess ? primaryRed : const Color(0xFFB00020),
                            size: 28,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                             // Handle export or view details
                             provider.clearFiles();
                             context.go('/dashboard');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            isSuccess ? 'Export Certificate' : 'Back to Dashboard',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
