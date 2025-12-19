import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Permission States
  bool _cameraPermission = true;
  bool _notificationPermission = true;
  bool _storagePermission = false;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Common colors based on design
    final primaryColor = const Color(0xFFFF3D3D);
    final bgLight = const Color(
      0xFFFFFFFF,
    ); // Page 1 uses white, Page 3 uses f8f5f5
    final bgDark = const Color(0xFF230F0F);

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: Stack(
        children: [
          // Background Gradients (Shared across pages with slight variations)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryColor.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryColor.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),

          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // PAGE 1: Intro
              _buildIntroPage(isDark, primaryColor),

              // PAGE 2: Features
              _buildFeaturesPage(isDark, primaryColor),

              // PAGE 3: Permissions
              _buildPermissionsPage(isDark, primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  // --- PAGE 1: Intro ---
  Widget _buildIntroPage(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Icon
          Container(
            width: 128,
            height: 128,
            alignment: Alignment.center,
            child: Icon(
              Icons.insights,
              size: 100,
              color: primaryColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(true, primaryColor),
              const SizedBox(width: 8),
              _buildDot(false, primaryColor, isDark),
              const SizedBox(width: 8),
              _buildDot(false, primaryColor, isDark),
            ],
          ),

          const SizedBox(height: 32),

          // Text
          Text(
            "Analyze Smarter, Act Faster",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181010),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Unlock critical insights and streamline your workflow with AI-powered analytics.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 48),

          // Feature Highlights (Small)
          _buildMiniFeature(
            Icons.speed,
            "Boost Productivity",
            "Automate routine tasks.",
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 16),
          _buildMiniFeature(
            Icons.verified,
            "Enhance Accuracy",
            "Reduce errors with intelligent validation.",
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 16),
          _buildMiniFeature(
            Icons.leaderboard,
            "Drive Better Decisions",
            "Gain deeper understanding instantly.",
            isDark,
            primaryColor,
          ),

          const Spacer(),

          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.25),
              ),
              child: Text(
                "Get Started",
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Text(
                  "Log In",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF181010),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMiniFeature(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF181010),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PAGE 2: Features ---
  Widget _buildFeaturesPage(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Unlock Powerful Features",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181010),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Streamline your B2B financial operations with our cutting-edge tools.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 32),

          // Features List
          _buildLargeFeature(
            Icons.verified_user,
            "Automated Compliance",
            "Stay regulation-ready with instant checks against global trade databases.",
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 24),
          _buildLargeFeature(
            Icons.psychology,
            "AI-Powered Drafting",
            "Generate complex export documents in seconds using advanced AI models.",
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 24),
          _buildLargeFeature(
            Icons.notifications_active,
            "Real-time Alerts",
            "Get instant notifications on shipment status updates and payment milestones.",
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 32),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(false, primaryColor, isDark),
              const SizedBox(width: 8),
              _buildDot(true, primaryColor),
              const SizedBox(width: 8),
              _buildDot(false, primaryColor, isDark),
            ],
          ),
          const SizedBox(height: 32),

          // Buttons
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.25),
              ),
              child: Text(
                "Next",
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                "Skip",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLargeFeature(
    IconData icon,
    String title,
    String subtitle,
    bool isDark,
    Color primaryColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF181010),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PAGE 3: Permissions ---
  Widget _buildPermissionsPage(bool isDark, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Grant Essential Permissions",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 30, // Slightly smaller to fit
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF181010),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "To provide the best experience, ExportSafe AI needs access to a few features on your device.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : const Color(0xFF4A4A4A),
            ),
          ),

          const SizedBox(height: 32),

          // Permission Toggles
          _buildPermissionItem(
            Icons.photo_camera,
            "Camera Access",
            "Scan invoices and shipping documents instantly.",
            _cameraPermission,
            (val) => setState(() => _cameraPermission = val),
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            Icons.notifications,
            "Notifications",
            "Get real-time alerts on compliance risks.",
            _notificationPermission,
            (val) => setState(() => _notificationPermission = val),
            isDark,
            primaryColor,
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            Icons.folder,
            "Storage Access",
            "Save and organize your export documentation.",
            _storagePermission,
            (val) => setState(() => _storagePermission = val),
            isDark,
            primaryColor,
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                "Your data is encrypted. Permissions can be changed later.",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(false, primaryColor, isDark),
              const SizedBox(width: 8),
              _buildDot(false, primaryColor, isDark),
              const SizedBox(width: 8),
              _buildDot(true, primaryColor),
            ],
          ),
          const SizedBox(height: 32),

          // Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ), // Rounded full
                elevation: 4,
                shadowColor: primaryColor.withOpacity(0.25),
              ),
              child: Text(
                "Allow & Continue",
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                "Not Now",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A1515) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? primaryColor.withOpacity(0.2)
                  : const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF181010),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13, // Slightly smaller
                    color: isDark ? Colors.grey[400] : const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive, Color primaryColor, [bool isDark = false]) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? primaryColor
            : (isDark ? Colors.grey[700] : Colors.grey[300]),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
