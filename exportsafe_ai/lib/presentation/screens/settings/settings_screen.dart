import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

                // Main Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Account Settings
                      _buildSectionHeader('Account Settings', subTextColor),
                      _buildSettingsGroup(cardColor, [
                        _buildSettingsTile(
                          icon: Icons.person,
                          title: 'Edit Profile',
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                          isFirst: true,
                        ),
                        _buildSettingsTile(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                        ),
                        _buildSettingsTile(
                          icon: Icons.credit_card,
                          title: 'Manage Subscription',
                          onTap: () {},
                          primaryColor: primaryColor,
                          textColor: textColor,
                          isLast: true,
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // App Preferences
                      _buildSectionHeader('App Preferences', subTextColor),
                      _buildSettingsGroup(cardColor, [
                        _buildSettingsTile(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          trailing: Switch(
                            value: true,
                            onChanged: (v) {},
                            activeThumbColor: primaryColor,
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
                          onTap: () => context.go('/login'),
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
