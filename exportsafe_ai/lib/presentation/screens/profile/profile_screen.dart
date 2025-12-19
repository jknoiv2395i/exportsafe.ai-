import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _user = user;
          _userData = userDoc.data() ?? {};
          _isLoading = false;
        });
      }
    } else {
      // Handle case where user is null (shouldn't happen in normal flow but safe to handle)
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateField(String label, String key, String currentValue, {bool isAuthProfile = false}) async {
    final TextEditingController controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context); // Close dialog
                setState(() => _isLoading = true);

                try {
                  // Ensure we have a user
                  if (_user == null) {
                    _user = _authService.getCurrentUser();
                    if (_user == null) {
                       throw Exception('No active user found. Please restart the app.');
                    }
                  }

                  if (isAuthProfile) {
                    await _authService.updateProfile(displayName: controller.text.trim());
                    await _user?.reload();
                    _user = _authService.getCurrentUser();
                  }

                  // Always update Firestore for consistency
                  if (_user != null) {
                    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
                      key: controller.text.trim(),
                    }, SetOptions(merge: true));
                  }

                  if (mounted) {
                     await _loadProfileData(); // Refresh all data
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$label updated successfully!')),
                    );
                  }
                } catch (e) {
                   if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating $label: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Colors from the design adapted to Flutter
    final bgColor = isDark ? const Color(0xFF230f0f) : const Color(0xFFF8F5F5); 
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    const primaryColor = Color(0xFFFF3B3B); // Brand Red
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    // Resolve data
    final displayName = _user?.displayName ?? _userData['displayName'] ?? 'Guest User';
    final email = _user?.email ?? _userData['email'] ?? 'No Email';
    final phone = _userData['phoneNumber'] ?? '+1 (555) 000-0000';
    final companyName = _userData['companyName'] ?? 'Global Trade Corp.';
    final industry = _userData['industry'] ?? 'International Trade';
    final photoURL = _user?.photoURL;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        leading: Builder(
          builder: (context) {
            if (context.canPop()) {
              return IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 24),
                onPressed: () => context.pop(),
              );
            }
            return const SizedBox.shrink();
          }
        ),
        centerTitle: true,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                   Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: photoURL != null 
                        ? DecorationImage(image: NetworkImage(photoURL), fit: BoxFit.cover)
                        : null,
                      color: Colors.grey[300],
                    ),
                    child: photoURL == null ? Icon(Icons.person, size: 64, color: Colors.grey[600]) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companyName,
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Personal Information
            _buildSectionHeader('Personal Information', textColor),
            _buildInfoCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: displayName,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: false,
                  borderColor: borderColor,
                  onTap: () => _updateField('Full Name', 'displayName', displayName, isAuthProfile: true),
                ),
                 _buildInfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: email,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: false, // Email editing usually requires re-auth, keeping readonly for now
                  isLast: false,
                  borderColor: borderColor,
                ),
                 _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: phone,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: true,
                  borderColor: borderColor,
                  onTap: () => _updateField('Phone Number', 'phoneNumber', phone),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Company Information
            _buildSectionHeader('Company Information', textColor),
            _buildInfoCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildInfoRow(
                  icon: Icons.apartment_outlined,
                  label: 'Company Name',
                  value: companyName,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: false,
                  borderColor: borderColor,
                  onTap: () => _updateField('Company Name', 'companyName', companyName),
                ),
                 _buildInfoRow(
                  icon: Icons.business_center_outlined,
                  label: 'Industry',
                  value: industry,
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: true,
                  borderColor: borderColor,
                  onTap: () => _updateField('Industry', 'industry', industry),
                ),
              ],
            ),

             const SizedBox(height: 16),

            // Preferences
            _buildSectionHeader('Preferences', textColor),
            _buildInfoCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildNavRow(
                  icon: Icons.notifications_none_outlined,
                  label: 'Notification Settings',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isLast: false,
                  borderColor: borderColor,
                  onTap: () => context.push('/settings'), // Redirect to Settings for toggles
                ),
                 _buildNavRow(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  value: 'English',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isLast: true,
                  borderColor: borderColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required Color cardColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryColor,
    required Color textColor,
    required Color subTextColor,
    required bool showEdit,
    required bool isLast,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: showEdit ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
             ),
             if (showEdit)
               Icon(Icons.edit_outlined, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

   Widget _buildNavRow({
    required IconData icon,
    required String label,
    String? value,
    required Color primaryColor,
    required Color textColor,
    required Color subTextColor,
    required bool isLast,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (value != null)
                     Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                      ),
                    ),
                ],
              ),
             ),
             Icon(Icons.chevron_right, color: subTextColor, size: 24),
          ],
        ),
      ),
    );
  }
}
