import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind the navbar
      body: child,

      bottomNavigationBar: _buildCustomNavigationBar(context),
    );
  }

  Widget _buildCustomNavigationBar(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70, // Slightly taller for modern look
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                ),
                _buildNavItem(
                   context,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.document_scanner_rounded,
                  label: 'Scan LC',
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                   context,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.edit_note_rounded,
                  label: 'Write LC',
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                   context,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    // Animation/Transition can be added here if needed, but keeping it reactive first
    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[500],
              size: 26,
            ),
            // Only show label if selected (pill shape effect) or always show below?
            // User asked for aesthetic. "Pill shape" usually hides text of unselected items.
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) {
      return 0;
    }
    if (location.startsWith('/audit')) {
      return 1;
    }
    if (location.startsWith('/write-lc')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/audit');
        break;
      case 2:
        context.go('/write-lc');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
