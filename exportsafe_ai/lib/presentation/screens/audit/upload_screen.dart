import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';
import '../../providers/audit_provider.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);
    // Use simple light/dark check or default to false for web stability if needed
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design Colors
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    const primaryColor = Color(0xFFFF3B3B);
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Text(
          'Upload Documents',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 1. Letter of Credit Card
                  _UploadCard(
                    title: 'Letter of Credit',
                    subtitle: 'Tap to upload your document',
                    icon: Icons.account_balance_outlined,
                    onTap: provider.pickLcFile,
                    file: provider.lcFile,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // 2. Commercial Invoice Card
                  _UploadCard(
                    title: 'Commercial Invoice',
                    subtitle: 'Tap to upload your document',
                    icon: Icons.description_outlined,
                    onTap: provider.pickInvoiceFile,
                    file: provider.invoiceFile,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          // Analyze Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: provider.canRunAnalysis
                    ? () => provider.runAnalysis(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Analyze Documents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
          
          // Spacer for Bottom Nav Dock
          const SizedBox(height: 80), 
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final PlatformFile? file;
  final Color primaryColor;
  final bool isDark;

  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.file,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Styling constants
    final bool isFileSelected = file != null;
    final dashColor = primaryColor;
    final cardBg = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3748);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF718096);

    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: dashColor,
          strokeWidth: 1.5,
          gap: 6,
          radius: 20,
        ),
        child: Container(
          width: double.infinity,
          height: 220, // Fixed height for consistency
          decoration: BoxDecoration(
            color: isFileSelected ? primaryColor.withOpacity(0.05) : cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isFileSelected ? Colors.white : (isDark ? Colors.black26 : Colors.white),
                  borderRadius: BorderRadius.circular(12), // Slightly soft square
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isFileSelected ? Icons.check_circle : icon,
                  size: 40,
                  color: isFileSelected ? Colors.green : const Color(0xFF2D3748), // Dark grey icon
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                isFileSelected ? file!.name : title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Subtitle
              if (!isFileSelected)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                  ),
                )
              else
                 Text(
                  "${(file!.size / 1024).toStringAsFixed(1)} KB",
                  style: TextStyle(
                    fontSize: 14,
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    Path dashedPath = Path();
    double dashWidth = 10.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
