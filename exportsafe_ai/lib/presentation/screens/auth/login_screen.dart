import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exportsafe_ai/core/theme/app_theme.dart';
import 'package:exportsafe_ai/data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await _authService.signInWithGoogle();
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  }

  void _handleEmailSignIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = await _authService.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (user != null && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-In failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundOffWhite,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavyBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.verified_user,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'ExportSafe AI',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryNavyBlue,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bank-Grade Document Auditing',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.login),
                  label: Text(_isLoading ? 'Signing in...' : 'Sign in with Google'),
                ),
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Container(height: 1, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              // Email Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password Field
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              // Sign In Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  child: Text(_isLoading ? 'Signing in...' : 'Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
