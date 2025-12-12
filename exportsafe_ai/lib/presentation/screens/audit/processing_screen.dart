import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/audit_provider.dart';
import 'dart:async';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

enum ProcessingPhase { scanning, validating }

class _ProcessingScreenState extends State<ProcessingScreen> with TickerProviderStateMixin {
  final Color primaryRed = const Color(0xFFFF3B3B);
  ProcessingPhase _phase = ProcessingPhase.scanning;
  
  // SCANNER STATE
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  final List<ScannerLog> _scannerLogs = [
    ScannerLog("Reading MT700 Structure..."),
    ScannerLog("Extracting Invoice Table..."),
    ScannerLog("Applying UCP 600 Logic..."),
  ];

  // TIMELINE STATE
  final List<TimelineStepData> _steps = [
    TimelineStepData(title: "Legal Review", subtitle: "Checking compliance with UCP 600..."),
    TimelineStepData(title: "Regulatory Check", subtitle: "Verifying trade regulations..."),
    TimelineStepData(title: "Data Integrity", subtitle: "Cross-referencing LC and Invoice..."),
    TimelineStepData(title: "Security Audit", subtitle: "Scanning for anomalies..."),
  ];
  int _currentStepIndex = -1; // -1 means before starting timeline
  bool _isTimelineComplete = false;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    
    // 1. Setup Scanner Animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // 2. Start Flow
    _startScanningPhase();
  }

  void _startScanningPhase() async {
    // Animate Scanner Logs
    for (int i = 0; i < _scannerLogs.length; i++) {
        // Increment progress 0 -> 100
        for (int p = 0; p <= 100; p += 10) {
           await Future.delayed(const Duration(milliseconds: 50));
           if (mounted) {
               setState(() {
                   _scannerLogs[i].progress = p;
               });
           }
        }
    }
    
    // Short pause after logs done
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _phase = ProcessingPhase.validating;
      });
      _startValidationPhase();
    }
  }

  void _startValidationPhase() {
    setState(() {
        _currentStepIndex = 0;
    });

    // Simulate each step taking ~1.2 seconds
    const stepDuration = Duration(milliseconds: 1000);
    
    _simulationTimer = Timer.periodic(stepDuration, (timer) {
      if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
        });
      } else {
        timer.cancel();
        setState(() {
          _isTimelineComplete = true; // Mark all complete
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
            // Background Glows (Persistent)
            Positioned(
              top: -100, left: -100,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed.withOpacity(0.15),
                ),
                child: BackdropFilter(
                     filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                     child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Main Content Switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _phase == ProcessingPhase.scanning
                  ? _buildScannerView(isDark)
                  : _buildTimelineView(isDark),
            ),
        ],
      ),
    );
  }

  // --- SCANNER VIEW ---
  Widget _buildScannerView(bool isDark) {
    return Center( // Key for AnimatedSwitcher
      key: const ValueKey('scanner'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Stack(
              alignment: Alignment.center,
              children: [
                  Icon(
                      Icons.description_outlined,
                      size: 160,
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                  ),
                  // Scanning Line
                  AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                          return Positioned(
                              top: 160 * _scanAnimation.value,
                              child: Container(
                                  width: 120, 
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: primaryRed,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                          BoxShadow(
                                              color: primaryRed.withOpacity(0.5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                          )
                                      ]
                                  ),
                              ),
                          );
                      },
                  ),
              ],
          ),
          const SizedBox(height: 40),
          
          // Technical Logs
          SizedBox(
            width: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _scannerLogs.map((log) {
                // Determine color
                final isProcessing = log.progress > 0 && log.progress < 100;
                final isDone = log.progress == 100;
                final color = isProcessing || isDone ? primaryRed : (isDark ? Colors.grey[600] : Colors.grey[500]);
                final textStyle = GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                );

                if (log.progress == 0) {
                     return Padding(
                       padding: const EdgeInsets.symmetric(vertical: 4.0),
                       child: Text("", style: textStyle), // Placeholder for height stability if needed, or just hide
                     ); 
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text("> ", style: GoogleFonts.robotoMono(color: Colors.grey[500])),
                      Text(log.text, style: textStyle),
                      const Spacer(),
                      Text(
                        "${log.progress}%",
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // --- TIMELINE VIEW ---
  Widget _buildTimelineView(bool isDark) {
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);

    return SafeArea(
      key: const ValueKey('timeline'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Header (Animated)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isTimelineComplete ? 1.0 : 0.0,
              child: Column(
                children: [
                  Text(
                    "File Validated!",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "All legal and compliance checks passed successfully.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Timeline List
            Expanded(
              child: ListView.builder(
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                   StepState state;
                   if (index < _currentStepIndex) {
                     state = StepState.completed;
                   } else if (index == _currentStepIndex && !_isTimelineComplete) {
                     state = StepState.processing;
                   } else if (_isTimelineComplete) {
                     state = StepState.completed;
                   } else {
                     state = StepState.waiting;
                   }

                   return _buildTimelineItem(
                     step: _steps[index],
                     state: state,
                     isLast: index == _steps.length - 1,
                     isDark: isDark,
                   );
                },
              ),
            ),

            // Export/View Button
            Consumer<AuditProvider>(
              builder: (context, provider, child) {
                final isApiReady = provider.currentReport != null;
                final showButton = _isTimelineComplete && isApiReady;
                final showLoading = _isTimelineComplete && !isApiReady;

                return Column(
                  children: [
                     AnimatedSlide(
                      offset: showButton ? Offset.zero : const Offset(0, 2),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: showButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !showButton,
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                  context.pushReplacement('/report/new_audit');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryRed,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: primaryRed.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'View Detailed Report',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    if (showLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryRed, strokeWidth: 2)),
                              const SizedBox(width: 12),
                              Text(
                                "Finalizing Analysis...",
                                style: GoogleFonts.inter(color: subTextColor),
                              )
                            ],
                          ),
                        )
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required TimelineStepData step,
    required StepState state,
    required bool isLast,
    required bool isDark,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Icon
          Column(
            children: [
              // Icon Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: state == StepState.completed ? primaryRed : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  shape: BoxShape.circle,
                  boxShadow: state == StepState.completed
                    ? [BoxShadow(color: primaryRed.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
                ),
                child: Center(
                  child: state == StepState.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : state == StepState.processing
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryRed, strokeWidth: 2))
                      : Icon(Icons.circle_outlined, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 20),
                ),
              ),
              
              // Vertical Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: state == StepState.completed ? primaryRed.withOpacity(0.5) : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: state == StepState.waiting ? 0.3 : 1.0, 
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state == StepState.processing ? primaryRed.withOpacity(0.5) : Colors.transparent
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state == StepState.completed ? "Status: Passed" : step.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: state == StepState.completed ? Colors.green : subTextColor,
                          fontWeight: state == StepState.completed ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
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

enum StepState { waiting, processing, completed }

class TimelineStepData {
  final String title;
  final String subtitle;

  TimelineStepData({required this.title, required this.subtitle});
}

class ScannerLog {
  final String text;
  int progress;
  
  ScannerLog(this.text, {this.progress = 0});
}
