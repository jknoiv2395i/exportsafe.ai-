import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class WriteLCScreen extends StatelessWidget {
  const WriteLCScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // HTML Design Colors
    final Color primaryColor = const Color(0xFFFF3D3D);
    final Color bgLight = const Color(0xFFF8F5F5);
    final Color bgDark = const Color(0xFF230F0F);
    
    final Color backgroundColor = isDark ? bgDark : bgLight;
    final Color cardColor = isDark ? const Color(0xFF230F0F).withOpacity(0.5) : const Color(0xFFFFFFFF).withOpacity(0.8);
    final Color textColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF333333);
    final Color borderColor = isDark ? const Color(0xFF374151) : const Color(0xFFE7DADA);
    final Color inputBg = isDark ? const Color(0xFF230F0F) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Radial Gradient Background (Top Left)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Back Button
                      InkWell(
                        onTap: () {
                           if (context.canPop()) {
                             context.pop();
                           } else {
                             context.go('/dashboard');
                           }
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          "Write LC with AI",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.15,
                          ),
                        ),
                      ),
                      // Placeholder for balance (width 48)
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Beneficiary Name
                              _buildLabel("Beneficiary Name", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                hint: "Enter beneficiary name", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor
                              ),
                              
                              const SizedBox(height: 24),

                              // Amount
                              _buildLabel("Amount", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                hint: "Enter amount", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor
                              ),

                              const SizedBox(height: 24),

                              // Terms & Conditions
                              _buildLabel("Terms & Conditions", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                hint: "Enter terms and conditions", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor,
                                maxLines: 6,
                              ),
                              
                              const SizedBox(height: 32),

                              // Generate Button
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement Generation Logic
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Generating Draft...")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  fixedSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 4,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                ),
                                child: const Text(
                                  "Generate LC Draft",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInput({
    required String hint, 
    required Color borderColor, 
    required Color inputBg, 
    required Color textColor,
    required Color focusColor,
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputBg,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }
}
