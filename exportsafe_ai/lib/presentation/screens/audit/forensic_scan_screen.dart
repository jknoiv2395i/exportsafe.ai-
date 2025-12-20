import 'package:flutter/material.dart';
import 'dart:async';
import '../../../data/models/forensic_audit_report.dart';
import 'forensic_audit_screen.dart';

class ForensicScanScreen extends StatefulWidget {
  final Future<ForensicAuditReport> Function() runAnalysis;

  const ForensicScanScreen({super.key, required this.runAnalysis});

  @override
  State<ForensicScanScreen> createState() => _ForensicScanScreenState();
}

class _ForensicScanScreenState extends State<ForensicScanScreen>
    with TickerProviderStateMixin {
  // Brand Colors
  static const Color primaryRed = Color(0xFFFF3B3B);
  static const Color textDark = Color(0xFF333333);

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  final List<ScanStep> _steps = [
    ScanStep(label: 'Reading MT700 Structure...', duration: 1500),
    ScanStep(label: 'Extracting Invoice Table...', duration: 1800),
    ScanStep(label: 'Parsing Document Fields...', duration: 1200),
    ScanStep(label: 'Cross-Referencing Data...', duration: 2000),
    ScanStep(label: 'Checking UCP 600 Compliance...', duration: 1600),
    ScanStep(label: 'Analyzing Discrepancies...', duration: 1400),
    ScanStep(label: 'Generating Report...', duration: 1000),
  ];

  int _currentStepIndex = 0;
  final Map<int, double> _stepProgress = {};
  bool _isAnalysisComplete = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _startScanning();
  }

  Future<void> _startScanning() async {
    _animateSteps();

    try {
      final report = await widget.runAnalysis();

      if (!mounted) return;
      
      _isAnalysisComplete = true; // Stop step animation logic
      _scanLineController.stop(); // Stop laser animation

      setState(() {
        for (int i = 0; i < _steps.length; i++) {
          _stepProgress[i] = 100.0;
        }
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ForensicAuditScreen(report: report),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _isAnalysisComplete = true;
        _scanLineController.stop();
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _animateSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted || _isAnalysisComplete) return;

      setState(() {
        _currentStepIndex = i;
      });

      final step = _steps[i];
      final increments = 20;
      final incrementDelay = step.duration ~/ increments;

      for (int j = 0; j <= increments; j++) {
        if (!mounted || _isAnalysisComplete) return;
        await Future.delayed(Duration(milliseconds: incrementDelay));
        setState(() {
          _stepProgress[i] = (j / increments) * 100;
        });
      }
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _error != null ? _buildErrorView() : _buildScanningView(),
      ),
    );
  }

  Widget _buildScanningView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Document Icon with Scan Line Matches the Image Provided
            _buildDocumentIcon(),
            const SizedBox(height: 60),

            // Progress Steps
            _buildStepsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentIcon() {
    return SizedBox(
      width: 140,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document shape with folded corner
          CustomPaint(
            size: const Size(140, 190),
            painter: DocumentPainter(),
          ),
          
          // Document lines (text representation) - Centered exactly like image
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 14,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8C8C8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 14,
                width: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8C8C8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 14,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8C8C8),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),

          // Animated Scan Line
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: 20 + (_scanLineAnimation.value * 150),
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 160,
                    height: 4,
                    decoration: BoxDecoration(
                      color: primaryRed,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    final visibleSteps = <Widget>[];

    for (int i = 0; i <= _currentStepIndex && i < _steps.length; i++) {
      final progress = _stepProgress[i] ?? 0.0;

      visibleSteps.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Red ">" prefix
              const Text(
                '> ',
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              // Step label
              Expanded(
                child: Text(
                  _steps[i].label,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              // Percentage
              SizedBox(
                width: 50,
                child: Text(
                  '${progress.toInt()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: primaryRed,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: visibleSteps,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE5E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, color: primaryRed, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                color: textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for document shape with folded corner
class DocumentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Main Paper Color (Light Gray)
    final mainPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.fill;

    final foldSize = 40.0;

    // Main document shape path (minus the corner)
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - foldSize, 0);
    path.lineTo(size.width, foldSize);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, mainPaint);

    // 2. Folded Corner (Slightly Lighter/Darker to distinguish)
    final foldPaint = Paint()
      ..color = const Color(0xFFF2F2F2)
      ..style = PaintingStyle.fill;

    final foldPath = Path();
    foldPath.moveTo(size.width - foldSize, 0);
    foldPath.lineTo(size.width - foldSize, foldSize);
    foldPath.lineTo(size.width, foldSize);
    foldPath.close();

    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanStep {
  final String label;
  final int duration;

  ScanStep({required this.label, required this.duration});
}
