import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Navigate to login or dashboard based on auth state
      // For now, we'll go to the initial route defined in router
      context.go('/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFFF3B3B);
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
    final textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B); // Slate 200 / Slate 800

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Glows (Soft Radial Gradients)
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  radius: 0.5,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  radius: 0.5,
                ),
              ),
            ),
          ),
          
          // Blur Effect (Approximation in Flutter)
          // In web CSS blur-3xl is strong. We can use BackdropFilter if we want, 
          // but simple opacity circles often look similar enough. 
          // For better blur, we'd wrap the circles in ImageFiltered.
          
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Logo
                Container(
                  width: 96, // 24 * 4
                  height: 96,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(24), // rounded-3xl
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 60, // text-6xl approx
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'ExportSafe AI',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 30, // text-3xl
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                
                const Spacer(),
                
                // Loader
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 2,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Version
                Text(
                  'v1.0',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14, // text-sm
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
