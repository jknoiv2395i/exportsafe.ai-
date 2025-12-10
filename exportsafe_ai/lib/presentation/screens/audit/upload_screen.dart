import 'package:flutter/material.dart';
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
      ),
    );
  }
}

class _UploadZone extends StatelessWidget {
  final String label;
  final dynamic file;
  final VoidCallback onTap;

  const _UploadZone({
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
    );
  }
}

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
}
