import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/audit_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  int _selectedIndex = -1; // -1: None, 0: Upload, 1: Camera

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuditProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Colors from design
    const primaryColor = Color(0xFFFF3D3D);
    final backgroundColor = isDark ? const Color(0xFF230F0F) : const Color(0xFFF8F5F5);
    final cardColor = isDark ? const Color(0xFF230F0F).withOpacity(0.5) : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[200]!;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  radius: 0.5,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/dashboard');
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      ),
                      Text(
                        'Scan Letter of Credit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selection Grid
                        _buildSelectionCard(
                          index: 0,
                          icon: Icons.upload_file,
                          title: 'Upload Document',
                          subtitle: 'Select a file from your device',
                          isSelected: _selectedIndex == 0,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        const SizedBox(height: 16),
                        _buildSelectionCard(
                          index: 1,
                          icon: Icons.photo_camera,
                          title: 'Scan with Camera',
                          subtitle: "Use your phone's camera to scan",
                          isSelected: _selectedIndex == 1,
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),

                        const SizedBox(height: 24),
                        
                        // Meta Text
                        Text(
                          'Supported formats: PDF, JPG, PNG. Max file size: 10MB.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedIndex != -1
                          ? () {
                              if (_selectedIndex == 0) {
                                provider.pickLcFile();
                              } else {
                                // For now, handle camera same as file picker or show message
                                provider.pickLcFile(); 
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: primaryColor.withOpacity(0.5),
                      ),
                      child: const Text(
                        'Proceed to Scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Space for Bottom Navigation Bar (handled by ShellRoute, but adding padding just in case)
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required Color primaryColor,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 48,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
