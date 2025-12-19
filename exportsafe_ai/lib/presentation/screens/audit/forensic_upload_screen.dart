import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/forensic_audit_provider.dart';

// Copy of UploadScreen but using ForensicAuditProvider
class ForensicUploadScreen extends StatelessWidget {
  const ForensicUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the scope locally so we don't need to touch main.dart
    return ChangeNotifierProvider(
      create: (_) => ForensicAuditProvider(),
      child: const _ForensicUploadView(),
    );
  }
}

class _ForensicUploadView extends StatelessWidget {
  const _ForensicUploadView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForensicAuditProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F7);
    const primaryColor = Color(
      0xFF34C759,
    ); // Green for Forensic/Compliance theme distinction
    final textColor = isDark ? Colors.white : const Color(0xFF1D1D1F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Forensic Audit Upload',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Upload documents for Deep Forensic Analysis.\nOur AI will check for UCP 600 compliance and logical consistency.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 32),

                  _UploadCard(
                    title: 'Letter of Credit',
                    subtitle: 'Upload PDF',
                    icon: Icons.assignment_outlined,
                    onTap: provider.pickLcFile,
                    file: provider.lcFile,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _UploadCard(
                    title: 'Commercial Invoice',
                    subtitle: 'Upload PDF',
                    icon: Icons.receipt_long_outlined,
                    onTap: provider.pickInvoiceFile,
                    file: provider.invoiceFile,
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: isDark ? Colors.black12 : Colors.white,
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Start Forensic Audit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
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
    final bool isFileSelected = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFileSelected ? primaryColor : Colors.grey.withOpacity(0.2),
            width: isFileSelected ? 2 : 1,
            style: isFileSelected ? BorderStyle.solid : BorderStyle.none,
          ),
          boxShadow: [
            if (!isFileSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFileSelected
                    ? primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFileSelected ? Icons.check : icon,
                color: isFileSelected ? primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFileSelected ? file!.name : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFileSelected
                        ? '${(file!.size / 1024).toStringAsFixed(1)} KB'
                        : subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
