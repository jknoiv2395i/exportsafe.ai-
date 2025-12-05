import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/audit_provider.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Audit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Documents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload the Letter of Credit and the Commercial Invoice to begin the audit.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // LC Upload Zone
            _buildUploadZone(
              context,
              label: 'Upload Letter of Credit',
              file: provider.lcFile,
              onTap: provider.pickLcFile,
            ),
            const SizedBox(height: 16),

            // Invoice Upload Zone
            _buildUploadZone(
              context,
              label: 'Upload Commercial Invoice',
              file: provider.invoiceFile,
              onTap: provider.pickInvoiceFile,
            ),
            const Spacer(),

            // Run Analysis Button
            ElevatedButton(
              onPressed: provider.canRunAnalysis && !provider.isProcessing
                  ? () async {
                      await provider.runAnalysis(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.canRunAnalysis ? AppTheme.primaryColor : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: provider.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'RUN ANALYSIS',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadZone(
    BuildContext context, {
    required String label,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppTheme.secondaryColor : Colors.grey.shade400,
            width: 2,
            style: BorderStyle.solid, // Dotted border is hard in standard Flutter without external package or CustomPainter, using solid for now or could use a package like dotted_border
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.picture_as_pdf : Icons.cloud_upload_outlined,
              size: 48,
              color: file != null ? AppTheme.secondaryColor : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              file != null ? file.name : label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: file != null ? AppTheme.primaryColor : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (file == null)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '(PDF, JPG, PNG)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
