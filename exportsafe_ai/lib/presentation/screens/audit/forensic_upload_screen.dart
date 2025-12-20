import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/forensic_audit_provider.dart';

class ForensicUploadScreen extends StatelessWidget {
  const ForensicUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForensicAuditProvider(),
      child: const _ForensicUploadView(),
    );
  }
}

class _ForensicUploadView extends StatefulWidget {
  const _ForensicUploadView();

  @override
  State<_ForensicUploadView> createState() => _ForensicUploadViewState();
}

class _ForensicUploadViewState extends State<_ForensicUploadView>
    with SingleTickerProviderStateMixin {
  // BRAND COLORS - RED PRIMARY, WHITE BACKGROUND
  static const Color primaryRed = Color(0xFFFF3B3B);
  static const Color lightRed = Color(0xFFFF6B6B);
  static const Color paleRed = Color(0xFFFFE5E5);
  static const Color faintPink = Color(0xFFFFF5F5);
  static const Color textDark = Color(0xFF1D1D1F);
  static const Color textMuted = Color(0xFF86868B);

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForensicAuditProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          // Subtle Red/Pink gradient on white background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              faintPink,
              Colors.white,
              faintPink,
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(context),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeaderSection(),
                        const SizedBox(height: 32),

                        // Compliance Info Card
                        _buildInfoCard(),
                        const SizedBox(height: 32),

                        // Upload Cards
                        _UploadCard(
                          title: 'Letter of Credit',
                          subtitle: 'PDF Document Required',
                          icon: Icons.description_outlined,
                          file: provider.lcFile,
                          onTap: provider.pickLcFile,
                        ),
                        const SizedBox(height: 16),
                        _UploadCard(
                          title: 'Commercial Invoice',
                          subtitle: 'PDF Document Required',
                          icon: Icons.receipt_long_outlined,
                          file: provider.invoiceFile,
                          onTap: provider.pickInvoiceFile,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Button
              _buildActionButton(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 18),
            ),
          ),
          const Expanded(
            child: Text(
              'Forensic Audit AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Icon with RED accent
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: paleRed,
            boxShadow: [
              BoxShadow(
                color: primaryRed.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: primaryRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 36,
              color: primaryRed,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Deep Document Analysis',
          style: TextStyle(
            color: textDark,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Upload your documents for AI-powered forensic\nanalysis and UCP 600 compliance verification',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textMuted,
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: paleRed,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryRed.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryRed.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: primaryRed,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compliance Standards',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'UCP 600 • ISBP 745 • Incoterms 2020',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ForensicAuditProvider provider) {
    final canRun = provider.canRunAnalysis;
    final isProcessing = provider.isProcessing;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: canRun && !isProcessing ? () => provider.runAnalysis(context) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: canRun
                ? const LinearGradient(colors: [primaryRed, lightRed])
                : null,
            color: canRun ? null : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: canRun
                ? [
                    BoxShadow(
                      color: primaryRed.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: canRun ? Colors.white : textMuted,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Start Forensic Audit',
                        style: TextStyle(
                          color: canRun ? Colors.white : textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final PlatformFile? file;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onTap,
  });

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
  static const Color primaryRed = Color(0xFFFF3B3B);
  static const Color paleRed = Color(0xFFFFE5E5);
  static const Color textDark = Color(0xFF1D1D1F);
  static const Color textMuted = Color(0xFF86868B);

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.file != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? paleRed : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryRed : const Color(0xFFE5E5E5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryRed.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryRed, Color(0xFFFF6B6B)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : widget.icon,
                color: isSelected ? Colors.white : textMuted,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSelected ? widget.file!.name : widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: primaryRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        isSelected
                            ? '${(widget.file!.size / 1024).toStringAsFixed(1)} KB • Ready'
                            : widget.subtitle,
                        style: TextStyle(
                          color: isSelected ? primaryRed : textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryRed.withOpacity(0.1)
                    : const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? Icons.verified : Icons.cloud_upload_outlined,
                color: isSelected ? primaryRed : textMuted,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
