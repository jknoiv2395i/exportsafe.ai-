import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ui';
import '../../../data/datasources/remote/api_service.dart';

class WriteLCScreen extends StatefulWidget {
  const WriteLCScreen({super.key});

  @override
  State<WriteLCScreen> createState() => _WriteLCScreenState();
}

class _WriteLCScreenState extends State<WriteLCScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isGenerating = false;

  // File Lists for each category
  List<PlatformFile> _maritimeFiles = [];
  List<PlatformFile> _landFiles = [];
  List<PlatformFile> _airFiles = [];
  List<PlatformFile> _nationalFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles(List<PlatformFile> targetList) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          targetList.addAll(result.files);
        });
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
    }
  }

  void _removeFile(List<PlatformFile> list, PlatformFile file) {
    setState(() {
      list.remove(file);
    });
  }

  List<PlatformFile> _getCurrentFiles() {
    switch (_tabController.index) {
      case 0:
        return _maritimeFiles;
      case 1:
        return _landFiles;
      case 2:
        return _airFiles;
      case 3:
        return _nationalFiles;
      default:
        return [];
    }
  }

  String _getRouteType() {
    switch (_tabController.index) {
      case 0:
        return "Maritime";
      case 1:
        return "Land";
      case 2:
        return "Air";
      case 3:
        return "National";
      default:
        return "Maritime";
    }
  }

  Future<void> _generateLC() async {
    final files = _getCurrentFiles();
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload at least one document.")),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final lcData = await _apiService.generateLcDraft(
        files: files,
        routeType: _getRouteType(),
      );

      if (mounted) {
        _showSuccessDialog(lcData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> lcData) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    "LC Draft Generated!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your documents have been analyzed and a UCP 600 compliant LC has been drafted.",
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('/view-lc', extra: lcData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D3D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("View Letter of Credit"),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final primaryColor = const Color(0xFFFF3D3D);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          "Intelligent LC Generator",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.directions_boat), text: "Maritime"),
            Tab(icon: Icon(Icons.local_shipping), text: "Land"),
            Tab(icon: Icon(Icons.airplanemode_active), text: "Air"),
            Tab(icon: Icon(Icons.flag), text: "National"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadSection("Maritime Route", _maritimeFiles, isDark),
          _buildUploadSection("Land Route", _landFiles, isDark),
          _buildUploadSection("Air Route", _airFiles, isDark),
          _buildUploadSection("National Route", _nationalFiles, isDark),
        ],
      ),
      // Removed bottomNavigationBar to avoid conflicts with parent shell
    );
  }

  Widget _buildUploadSection(
    String title,
    List<PlatformFile> files,
    bool isDark,
  ) {
    final primaryColor = const Color(0xFFFF3D3D);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Upload all relevant docs (Invoice, Packing List, BL) for $title. Our AI will cross-reference them for discrepancies.",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.blue[900],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            "Required Documents",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Upload Area
          GestureDetector(
            onTap: () => _pickFiles(files),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.4),
                  style: BorderStyle.none,
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
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: isDark ? Colors.grey : const Color(0xFFFF3D3D),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tap to Upload Files",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PDF Support Only",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // File List
          if (files.isNotEmpty) ...[
            ...files.map(
              (file) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3D3D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Color(0xFFFF3D3D),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${(file.size / 1024).toStringAsFixed(1)} KB",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => _removeFile(files, file),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action Button (Moved inside ScrollView)
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateLC,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isGenerating ? "Analyzing Documents..." : "Generate Perfect LC",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),

          // Extra bottom padding
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
