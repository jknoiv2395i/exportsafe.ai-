import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is active (for theme-aware colors)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Colors from the design adapted to Flutter
    final bgColor = isDark ? const Color(0xFF230f0f) : const Color(0xFFF8F5F5); // background-light/dark
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final primaryColor = const Color(0xFFFF3B3B); // Brand Red
    final textColor = isDark ? Colors.white : Colors.grey[900]!;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: bgColor.withOpacity(0.8), // sticky header effect
        elevation: 0,
        leading: Builder(
          builder: (context) {
             // Only show back button if we can pop, otherwise it's a main tab
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
        padding: const EdgeInsets.only(bottom: 120), // Padding for nav bar avoidance
        child: Column(
          children: [
            // Profile Header (Avatar + Name)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                   Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAxB4VVtHMPYketmT03FmUpnREoixZ5xhN72dF16RSirTxuD6ESSiOUeqHt-ZUtJ8h0tSHICHdGLsmS0fjPIR6zUFdNWbXwyqBQrrEEQBkcyF7aN_PsGBvWB2o_Q5zVYBkmELmiJFaL5lvIldqCmcKgwResyMUHeeXhqnlU4kf0CN3iX6pJfbnzMtQ391EZIjred9EWvldCBB2t-U86v0wXoHfgwBgdAbx05Z_yyglzp9rQizBIUoGYlT-p4A5PTjF7Ota7_Li0Lek"),
                        fit: BoxFit.cover,
                      ),
                      // Fallback color if image fails
                      color: Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alexandra Chen',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Global Trade Corp.',
                    style: TextStyle(
                      fontSize: 16,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Personal Information Section
            _buildSectionHeader('Personal Information', textColor),
            _buildInfoCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: 'Alexandra Chen',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: false,
                  borderColor: borderColor,
                ),
                 _buildInfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: 'a.chen@globaltradecorp.com',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: false,
                  borderColor: borderColor,
                ),
                 _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: '+1 (555) 123-4567',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: true,
                  isLast: true,
                  borderColor: borderColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Company Information Section
            _buildSectionHeader('Company Information', textColor),
            _buildInfoCard(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildInfoRow(
                  icon: Icons.apartment_outlined,
                  label: 'Company Name',
                  value: 'Global Trade Corp.',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: false,
                  isLast: false,
                  borderColor: borderColor,
                ),
                 _buildInfoRow(
                  icon: Icons.business_center_outlined,
                  label: 'Industry',
                  value: 'International Trade & Finance',
                  primaryColor: primaryColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  showEdit: false,
                  isLast: true,
                  borderColor: borderColor,
                ),
              ],
            ),

             const SizedBox(height: 16),

            // Preferences Section
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Icon Box
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
           // Text Info
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
  }) {
    return InkWell(
      onTap: () {}, // Add navigation logic if needed
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            // Icon Box
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
             // Text Info
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
