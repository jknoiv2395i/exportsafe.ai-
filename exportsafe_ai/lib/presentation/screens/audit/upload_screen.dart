<<<<<<< HEAD
﻿import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:exportsafe_ai/core/theme/app_theme.dart';
import 'package:exportsafe_ai/presentation/providers/audit_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Future<void> _pickFile(BuildContext context, bool isLC) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;
      final auditProvider = context.read<AuditProvider>();

      if (isLC) {
        auditProvider.setLcFile(file.xFile);
      } else {
        auditProvider.setInvoiceFile(file.xFile);
      }
    }
  }

  void _runAnalysis(BuildContext context) async {
    final auditProvider = context.read<AuditProvider>();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _ProcessingDialog(),
    );

    final result = await auditProvider.runAudit();

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (result != null) {
        context.go('/report/${DateTime.now().millisecondsSinceEpoch}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auditProvider.errorMessage ?? 'Audit failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Documents')),
      body: Consumer<AuditProvider>(
        builder: (context, auditProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Your Documents',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload Letter of Credit and Commercial Invoice for audit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                // LC Upload Zone
                _UploadZone(
                  label: 'Upload Letter of Credit (PDF/Image)',
                  file: auditProvider.lcFile,
                  onTap: () => _pickFile(context, true),
                ),
                const SizedBox(height: 24),
                // Invoice Upload Zone
                _UploadZone(
                  label: 'Upload Commercial Invoice (PDF/Image)',
                  file: auditProvider.invoiceFile,
                  onTap: () => _pickFile(context, false),
                ),
                const SizedBox(height: 48),
                // Run Analysis Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auditProvider.canRunAnalysis
                        ? () => _runAnalysis(context)
                        : null,
                    child: const Text('RUN ANALYSIS'),
                  ),
                ),
              ],
            ),
          );
        },
=======
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Design Colors
    final bgColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final primaryColor = const Color(0xFFFF3B3B);
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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
      ),
    );
  }
}

<<<<<<< HEAD
class _UploadZone extends StatelessWidget {
  final String label;
  final dynamic file;
  final VoidCallback onTap;

  const _UploadZone({
    required this.label,
    required this.file,
    required this.onTap,
=======
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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryNavyBlue,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.backgroundOffWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.description : Icons.cloud_upload,
              size: 48,
              color: AppTheme.primaryNavyBlue,
            ),
            const SizedBox(height: 16),
            Text(
              file != null ? 'File Selected' : label,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (file != null) ...[
              const SizedBox(height: 8),
              Text(
                file.name ?? 'document.pdf',
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
=======
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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
        ),
      ),
    );
  }
}

<<<<<<< HEAD
class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Processing Your Documents',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we audit your documents...',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
=======
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
>>>>>>> a8c3d2ef8c6c477dae116be93ab5c7faa818f325
}
