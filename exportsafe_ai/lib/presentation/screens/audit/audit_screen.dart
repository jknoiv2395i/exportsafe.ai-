import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../data/datasources/remote/api_service.dart';
import 'package:provider/provider.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  PlatformFile? _lcFile;
  PlatformFile? _subjectFile;
  bool _isLoading = false;

  // Progress State
  double _progressValue = 0.0;
  String _progressStatus = "";

  Map<String, dynamic>? _result;
  late TabController _tabController;

  // Theme Colors
  final Color _navyBlue = const Color(0xFF0A2342);
  final Color _emeraldGreen = const Color(0xFF2CA58D);
  final Color _offWhite = const Color(0xFFF4F6F8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isLc) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          if (isLc) {
            _lcFile = result.files.first;
          } else {
            _subjectFile = result.files.first;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
    }
  }

  Future<void> _runAudit() async {
    if (_lcFile == null || _subjectFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both documents.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _progressValue = 0.1;
      _progressStatus = "Initializing Secure Connection...";
      _result = null;
    });

    // Simulated Progress Stream
    final progressTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      setState(() {
        if (_progressValue < 0.9) {
          _progressValue += 0.15;
          if (_progressValue > 0.3 && _progressValue < 0.5) {
            _progressStatus = "Extracting Text via OCR...";
          } else if (_progressValue > 0.5 && _progressValue < 0.7)
            _progressStatus = "Analyzing UCP 600 Compliance...";
          else if (_progressValue > 0.7)
            _progressStatus = "Cross-referencing Documents...";
        }
      });
    });

    try {
      final result = await _apiService.analyzeDocuments(
        _lcFile!,
        _subjectFile!,
      );
      progressTimer.cancel();

      setState(() {
        _progressValue = 1.0;
        _progressStatus = "Analysis Complete!";
      });

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Show 100% briefly

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      progressTimer.cancel();
      setState(() {
        _isLoading = false;
        _progressValue = 0.0;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    }
  }

  Future<void> _downloadReport() async {
    if (_result == null) return;

    final pdf = pw.Document();
    final discrepancies = (_result!['discrepancies'] as List)
        .cast<Map<String, dynamic>>();
    final bankReport = _result!['bank_ready_report'] as Map<String, dynamic>?;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                "Forensic Audit Report",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Risk Score: ${_result!['risk_score'] ?? 'N/A'}",
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              "Discrepancies Found:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
            ),
            pw.SizedBox(height: 5),
            ...discrepancies.map(
              (d) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Field: ${d['field']}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Original: ${d['original_text']}",
                      style: const pw.TextStyle(color: PdfColors.red),
                    ),
                    pw.Text(
                      "Corrected: ${d['corrected_value']}",
                      style: const pw.TextStyle(color: PdfColors.green),
                    ),
                    pw.Text("Note: ${d['explanation']}"),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            if (bankReport != null) ...[
              pw.Header(level: 1, child: pw.Text("Bank Letter Draft")),
              pw.Text("Subject: ${bankReport['subject']}"),
              pw.SizedBox(height: 10),
              pw.Text(bankReport['body_text']),
            ],
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'audit_report.pdf',
    );
  }

  void _reset() {
    setState(() {
      _lcFile = null;
      _subjectFile = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _offWhite,
      appBar: AppBar(
        title: const Text('Forensic Audit & Analysis'),
        backgroundColor: _navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_result != null) ...[
            IconButton(
              onPressed: _downloadReport,
              icon: const Icon(Icons.download),
            ),
            IconButton(onPressed: _reset, icon: const Icon(Icons.refresh)),
          ],
        ],
      ),
      body: _isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _progressValue,
                      color: _emeraldGreen,
                      backgroundColor: Colors.grey.shade200,
                      strokeWidth: 8,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "${(_progressValue * 100).toInt()}%",
                      style: TextStyle(
                        color: _navyBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _progressStatus,
                      style: TextStyle(
                        color: _navyBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : _result == null
          ? _buildInputForm()
          : _buildResultsView(),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        100,
      ), // Added bottom padding for visibility
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Upload Documents for Analysis",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _navyBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Our AI will cross-reference the Invoice/BL against the Letter of Credit to find discrepancies.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 30),

          // Upload LC
          _buildUploadCard(
            title: "Authority Document (LC)",
            file: _lcFile,
            onTap: () => _pickFile(true),
            icon: Icons.gavel,
          ),

          const SizedBox(height: 20),

          // Upload Subject
          _buildUploadCard(
            title: "Subject Document (Invoice/BL)",
            file: _subjectFile,
            onTap: () => _pickFile(false),
            icon: Icons.receipt_long,
          ),

          const SizedBox(height: 40),

          // Action Button
          ElevatedButton(
            onPressed: (_lcFile != null && _subjectFile != null)
                ? _runAudit
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search),
                SizedBox(width: 8),
                Text("Run Forensic Audit"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: file != null ? _emeraldGreen : Colors.grey.shade300,
            width: file != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              file != null ? Icons.check_circle : icon,
              size: 48,
              color: file != null ? _emeraldGreen : _navyBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              file != null ? file.name : title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: file != null ? _emeraldGreen : _navyBlue,
              ),
              textAlign: TextAlign.center,
            ),
            if (file == null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "Tap to Upload PDF/Image",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    final discrepancies = (_result!['discrepancies'] as List)
        .cast<Map<String, dynamic>>();
    final refinedLc = _result!['refined_lc_text'] as String?;
    final bankReport = _result!['bank_ready_report'] as Map<String, dynamic>?;

    return Column(
      children: [
        Container(
          color: _navyBlue,
          child: TabBar(
            controller: _tabController,
            indicatorColor: _emeraldGreen,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: "Discrepancies"),
              Tab(text: "Clean LC"),
              Tab(text: "Bank Letter"),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDiscrepanciesTab(discrepancies),
              _buildTextTab(refinedLc ?? "No text generated."),
              _buildTextTab(
                bankReport != null
                    ? "SUBJECT: ${bankReport['subject']}\n\n${bankReport['body_text']}"
                    : "No report generated.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscrepanciesTab(List<Map<String, dynamic>> discrepancies) {
    if (discrepancies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, size: 64, color: _emeraldGreen),
            const SizedBox(height: 16),
            Text(
              "No Discrepancies Found!",
              style: TextStyle(
                fontSize: 18,
                color: _navyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: discrepancies.length,
      itemBuilder: (context, index) {
        final disc = discrepancies[index];
        final severity = disc['severity'] as String? ?? "MINOR";
        Color borderColor = Colors.grey;
        if (severity == "CRITICAL") {
          borderColor = Colors.red;
        } else if (severity == "MAJOR")
          borderColor = Colors.orange;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      disc['field'] ?? 'Unknown Field',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _navyBlue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          color: borderColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                _buildDiffRow(
                  "Original:",
                  disc['original_text'],
                  Colors.red.shade700,
                ),
                const SizedBox(height: 4),
                _buildDiffRow(
                  "Corrected:",
                  disc['corrected_value'],
                  Colors.green.shade700,
                ),
                const SizedBox(height: 8),
                Text(
                  disc['explanation'] ?? '',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiffRow(String label, String? value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: TextStyle(color: color, fontFamily: 'Courier'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextTab(String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SelectableText(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Copied to clipboard")),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text("Copy to Clipboard"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
