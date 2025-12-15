import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:async';
import '../audit/forensic_upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _gridSlideAnimation;
  late Animation<double> _gridFadeAnimation;
  late Animation<Offset> _listSlideAnimation;
  late Animation<double> _listFadeAnimation;
  late Animation<double> _gridScaleAnimation;
  late Animation<double> _listScaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slightly faster for punchiness
    );

    // Header: Slide Down + Fade
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack), // Bouncier
    ));
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Grid: Slide Up + Scale + Fade (Delayed)
    _gridSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Subtle slide 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
    _gridScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack), // Pop effect
    ));
    _gridFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    ));

    // List: Slide Up + Scale + Fade (More Delayed)
    _listSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));
    _listScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
    ));
    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _entranceController.forward();
  }
  
  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFF3B3B);
    const backgroundColor = Color(0xFFF5F5F7); // Off-white background
    const textDark = Color(0xFF1D1D1F);
    const textMuted = Color(0xFF86868B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ... Header Background ...
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF3B3B), Color(0xFFFF6B6B)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
          ),
          // ... Circles ...
           Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Header Row (Animated) - No scaling, just slide/fade
                  FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: SlideTransition(
                      position: _headerSlideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           // ... Header Content (Greeting, Bell) ...
                            Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AnimatedGreeting(),
                              const Text(
                                'Alex Doe',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => context.push('/settings'),
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.settings_outlined, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Notification Bell
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.amber, 
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.red, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Forensic Audit Banner (NEW FEATURE)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ForensicUploadScreen()),
                      );
                    },
                    child: FadeTransition(
                      opacity: _gridFadeAnimation,
                       child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_user_outlined, color: Color(0xFF34C759), size: 28),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Forensic Audit AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Deep analysis for UCP 600 compliance',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bento Grid (Row 1) - Animated with Scale
                  FadeTransition(
                    opacity: _gridFadeAnimation,
                    child: SlideTransition(
                      position: _gridSlideAnimation,
                      child: ScaleTransition(
                        scale: _gridScaleAnimation,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Large Risk Card
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // ... Icon and High Risk ...
                                       Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.security, color: primaryColor),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'High Risk',
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: TweenAnimationBuilder<double>(
                                                tween: Tween<double>(begin: 0, end: 0.75),
                                                duration: const Duration(seconds: 2),
                                                curve: Curves.easeOutExpo,
                                                builder: (context, value, _) => CircularProgressIndicator(
                                                  value: value,
                                                  strokeWidth: 12,
                                                  backgroundColor: Colors.grey[100],
                                                  color: primaryColor,
                                                  strokeCap: StrokeCap.round,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(begin: 0, end: 75),
                                                  duration: const Duration(seconds: 2),
                                                  curve: Curves.easeOutExpo,
                                                  builder: (context, value, _) => Text(
                                                    '${value.toInt()}%',
                                                    style: const TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.bold,
                                                      color: textDark,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // ... Labels ...
                                      const Text(
                                      'Risk Analysis',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                      ),
                                    ),
                                     Text(
                                      'Action required.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textMuted,
                                      ),
                                    ),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(width: 16),
                            // Stats Column
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  // Money Saved Tile
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(32),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Icon(Icons.savings_outlined, color: textDark, size: 28),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF34C759),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Saved',
                                            style: TextStyle(
                                              color: textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0, end: 50),
                                            duration: const Duration(seconds: 2),
                                            curve: Curves.easeOutExpo,
                                            builder: (context, value, _) => Text(
                                              '₹${value.toInt()}k',
                                              style: const TextStyle(
                                                color: textDark,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Pending Audits Tile
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(32),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Icon(Icons.pending_actions_outlined, color: textDark, size: 28),
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Pending',
                                            style: TextStyle(
                                              color: textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0, end: 3),
                                            duration: const Duration(milliseconds: 1500),
                                            curve: Curves.easeOutExpo,
                                            builder: (context, value, _) => Text(
                                              '${value.toInt()} Audits',
                                              style: const TextStyle(
                                                color: textDark,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                  const SizedBox(height: 16),

                  // 3. Upcoming Shipments - Animated
                  FadeTransition(
                    opacity: _listFadeAnimation,
                    child: SlideTransition(
                      position: _listSlideAnimation,
                      child: ScaleTransition(
                        scale: _listScaleAnimation,
                        child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                             BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upcoming Shipments',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Text(
                                  'Manage',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildMinimalShipmentItem(
                              icon: Icons.local_shipping_outlined,
                              title: 'Container #SHP789',
                              subtitle: 'Arriving Jan 15, 2024',
                              status: 'In Transit',
                              statusColor: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            _buildMinimalShipmentItem(
                              icon: Icons.inventory_2_outlined,
                              title: 'Pallet #PLT123',
                              subtitle: 'Scheduled Jan 20, 2024',
                              status: 'Scheduled',
                              statusColor: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                  
                  const SizedBox(height: 100), // FAB space
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalShipmentItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required MaterialColor statusColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7), // Clean background
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.black54),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF86868B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor[50],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: statusColor[800],
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedGreeting extends StatefulWidget {
  const AnimatedGreeting({super.key});

  @override
  State<AnimatedGreeting> createState() => _AnimatedGreetingState();
}

class _AnimatedGreetingState extends State<AnimatedGreeting> {
  final List<String> _greetings = ["Good Morning,", "Hello,", "Welcome Back,"];
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _index = (_index + 1) % _greetings.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30, // Fixed height to prevent layout shifts
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutExpo,
        switchOutCurve: Curves.easeInExpo,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final inAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation);
          final outAnimation = Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero).animate(animation);

          return ClipRect(
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: child.key == ValueKey(_greetings[_index]) ? inAnimation : outAnimation,
                child: child,
              ),
            ),
          );
        },
        child: Text(
          _greetings[_index],
          key: ValueKey<String>(_greetings[_index]),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
