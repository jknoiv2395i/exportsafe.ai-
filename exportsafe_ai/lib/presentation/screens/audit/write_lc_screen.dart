import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../data/datasources/remote/api_service.dart';

class WriteLCScreen extends StatefulWidget {
  const WriteLCScreen({super.key});

  @override
  State<WriteLCScreen> createState() => _WriteLCScreenState();
}

class _WriteLCScreenState extends State<WriteLCScreen> {
  final _aiPromptController = TextEditingController();
  final _beneficiaryController = TextEditingController();
  final _amountController = TextEditingController();
  final _termsController = TextEditingController();
  
  bool _isGenerating = false;
  final ApiService _apiService = ApiService();

  Future<void> _generateDraft() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe the deal first.")),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final data = await _apiService.generateLcDraft(prompt: prompt);
      
      setState(() {
        if (data.containsKey('beneficiary') && data['beneficiary'] is Map) {
             _beneficiaryController.text = data['beneficiary']['name'] ?? '';
        } else {
             _beneficiaryController.text = data['beneficiary']?.toString() ?? '';
        }
        _amountController.text = data['amount']?.toString() ?? '';
        
        // Prefer description of goods for the terms box, or fallback to terms
        if (data.containsKey('description_of_goods')) {
             _termsController.text = data['description_of_goods']?.toString() ?? '';
        } else if (data.containsKey('terms')) {
           _termsController.text = data['terms']?.toString() ?? '';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Draft Generated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  void dispose() {
    _aiPromptController.dispose();
    _beneficiaryController.dispose();
    _amountController.dispose();
    _termsController.dispose();
    super.dispose();
  }

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
          // Radial Gradient Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryColor.withOpacity(0.15), Colors.transparent],
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
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
                        ),
                      ),
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
                              // AI Input Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryColor.withOpacity(0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome, color: primaryColor, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Describe your deal",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _aiPromptController,
                                      maxLines: 3,
                                      style: TextStyle(color: textColor),
                                      decoration: InputDecoration(
                                        hintText: "E.g., LC for 50k USD to Acme Corp for steel pipes...",
                                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: _isGenerating ? null : _generateDraft,
                                        icon: _isGenerating 
                                          ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.bolt, size: 16),
                                        label: Text(_isGenerating ? "Thinking..." : "Auto-Fill"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              Divider(color: borderColor),
                              const SizedBox(height: 24),

                              _buildLabel("Beneficiary Name", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _beneficiaryController,
                                hint: "Enter beneficiary name", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor
                              ),
                              
                              const SizedBox(height: 24),

                              _buildLabel("Amount", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _amountController,
                                hint: "Enter amount", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor
                              ),

                              const SizedBox(height: 24),

                              _buildLabel("Terms & Conditions", textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _termsController,
                                hint: "Enter terms and conditions", 
                                borderColor: borderColor, 
                                inputBg: inputBg, 
                                textColor: textColor,
                                focusColor: primaryColor,
                                maxLines: 6,
                              ),
                              
                              const SizedBox(height: 32),

                              /* Generate LC Action - Real Backend Call */
                              ElevatedButton(
                                onPressed: () async {
                                  // Call Backend to get Full UCP 600 Structure based on current inputs
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Drafting Formal Letter of Credit (UCP 600)...")),
                                  );
                                  
                                  try {
                                    final lcData = await _apiService.generateLcDraft(
                                      beneficiary: _beneficiaryController.text,
                                      amount: _amountController.text,
                                      terms: _termsController.text
                                    );

                                    if (context.mounted) {
                                      showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierLabel: "Dismiss",
                                        transitionDuration: const Duration(milliseconds: 400),
                                        pageBuilder: (ctx, anim1, anim2) {
                                          return ScaleTransition(
                                            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                                            child: Dialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              backgroundColor: Theme.of(context).cardColor,
                                              child: Padding(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    "LC Generated Successfully",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "Your Letter of Credit is ready for review.",
                                                    style: TextStyle(color: textColor.withOpacity(0.7)),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  
                                                  // Open Button
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        context.push('/view-lc', extra: lcData);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: primaryColor,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                      child: const Text("Open Document", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  
                                                  // Download Button
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: TextButton.icon(
                                                      onPressed: () {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Downloading PDF...")),
                                                        );
                                                      },
                                                      icon: Icon(Icons.download, color: textColor),
                                                      label: Text("Download PDF", style: TextStyle(color: textColor)),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Error: $e")),
                                    );
                                  }
                                }
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
                                "Generate LC",
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
    required TextEditingController controller,
    required String hint, 
    required Color borderColor, 
    required Color inputBg, 
    required Color textColor,
    required Color focusColor,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
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
