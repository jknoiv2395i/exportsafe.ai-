import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _notificationsEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      // Get notification preference from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _user = user;
        _notificationsEnabled = userDoc.data()?['notificationsEnabled'] ?? true;
      });
    }
  }

  Future<void> _handleEditProfile() async {
    final TextEditingController nameController = TextEditingController(text: _user?.displayName);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                setState(() => _isLoading = true);
                Navigator.pop(context); // Close dialog
                
                try {
                  await _authService.updateProfile(displayName: nameController.text.trim());
                  await _user?.reload(); // Refresh user data
                  final updatedUser = _authService.getCurrentUser();
                  
                  if (mounted) {
                    setState(() {
                      _user = updatedUser;
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating profile: $e')),
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

  Future<void> _handleChangePassword() async {
    if (_user?.isAnonymous ?? false) {
      _showGuestAlert('change your password');
      return;
    }

    if (_user?.email == null || _user!.email!.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email found for this account.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Text('Send a password reset email to ${_user!.email}?'),
        actions: [
           TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.sendPasswordResetEmail(_user!.email!);
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset email sent! Check your inbox.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showGuestAlert(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guest Account'),
        content: Text('Please sign up to $action. You are currently using a guest account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          // Future: Add "Sign Up" button here
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    try {
      await _authService.updateNotificationPreference(value);
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() => _notificationsEnabled = !value); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors from design
    const primaryColor = AppTheme.primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF230F0F)
        : const Color(0xFFF8F5F5);
    final cardColor = isDark
        ? const Color(0xFF230F0F).withOpacity(0.5)
        : Colors.white.withOpacity(0.5);
    final textColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF1F2937);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[500]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background Gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      ),
                      Expanded(
                        child: Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                if (_isLoading) 
                  const LinearProgressIndicator(color: primaryColor),

                // Main Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Account Settings
                      _buildSectionHeader('Account Settings', subTextColor),
                      _buildSettingsGroup(
                        cardColor,
                        [
                          _buildSettingsTile(
                            icon: Icons.person,
                            title: 'Edit Profile',
                            subtitle: _user?.displayName ?? 'Set a display name',
                            onTap: _handleEditProfile,
                            primaryColor: primaryColor,
                            textColor: textColor,
                             isFirst: true,
                          ),
                          _buildSettingsTile(
                            icon: Icons.lock,
                            title: 'Change Password',
                            onTap: _handleChangePassword,
                            primaryColor: primaryColor,
                            textColor: textColor,
                          ),
                          _buildSettingsTile(
                            icon: Icons.credit_card,
                            title: 'Manage Subscription',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Payment integration coming soon!')),
                              );
                            },
                            primaryColor: primaryColor,
                            textColor: textColor,
                             isLast: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // App Preferences
                      _buildSectionHeader('App Preferences', subTextColor),
                      _buildSettingsGroup(
                        cardColor,
                        [
                          _buildSettingsTile(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                              activeColor: primaryColor,
                            ),
                            onTap: () {},
                            primaryColor: primaryColor,
                            textColor: textColor,
                            isFirst: true,
                          ),
                        _buildSettingsTile(
                          icon: Icons.language,
                          title: 'Language',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'English',
                                style: TextStyle(color: subTextColor),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: subTextColor),
                            ],
                          ),
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                        ),
                        _buildSettingsTile(
                          icon: Icons.contrast,
                          title: 'Theme',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Light',
                                style: TextStyle(color: subTextColor),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: subTextColor),
                            ],
                          ),
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                          isLast: true,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Legal & About
                      _buildSectionHeader('Legal & About', subTextColor),
                      _buildSettingsGroup(cardColor, [
                        _buildSettingsTile(
                          icon: Icons.shield,
                          title: 'Privacy Policy',
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                          isFirst: true,
                        ),
                        _buildSettingsTile(
                          icon: Icons.gavel,
                          title: 'Terms of Service',
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                        ),
                        _buildSettingsTile(
                          icon: Icons.info,
                          title: 'About ExportSafe AI',
                          trailing: Text(
                            'v1.0.0',
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                          isLast: true,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Logout
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final auth = AuthService();
                            await auth.signOut();
                            if (context.mounted) context.go('/login');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color textColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
              topRight: isFirst ? const Radius.circular(16) : Radius.zero,
              bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
              bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          title: Text(title, style: TextStyle(color: textColor, fontSize: 15)),
          trailing:
              trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
<<<<<<< HEAD
=======
          subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])) : null,
          trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
>>>>>>> c469d55 (feat(dashboard): Real-time Stats & Forensic UI Sync)
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 0,
            color: Colors.grey.withOpacity(0.1),
          ),
      ],
    );
  }
}
