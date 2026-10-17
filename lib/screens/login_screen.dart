import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';
import '../core/storage/hive_boxes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_login_button.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'Demo.player@groundres.com';
      _passwordController.text = 'Demo1234';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo credentials loaded! Click "Sign In" to proceed.'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 6. NEW ACCOUNT / LOGIN: Verify against saved accounts
    bool isAuthenticated = false;
    String? authError;

    try {
      Box usersBox;
      if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
        usersBox = Hive.box(HiveBoxes.usersBox);
      } else {
        usersBox = await Hive.openBox(HiveBoxes.usersBox);
      }

      // Allow demo accounts as well as any created accounts in Hive
      if (email.toLowerCase() == 'demo.player@groundres.com' || email.toLowerCase() == 'customer@groundzero.pk') {
        isAuthenticated = true;
      } else {
        for (final key in usersBox.keys) {
          final raw = usersBox.get(key);
          if (raw != null) {
            final map = Map<String, dynamic>.from(jsonDecode(raw as String));
            final storedEmail = (map['email'] as String? ?? '').toLowerCase();
            if (storedEmail == email.toLowerCase()) {
              final storedPassword = map['password'] as String?;
              if (storedPassword != null && storedPassword != password) {
                authError = 'Incorrect password. Please verify your credentials.';
              } else {
                isAuthenticated = true;
              }
              break;
            }
          }
        }
        if (!isAuthenticated && authError == null) {
          authError = 'No account found with this email. Please click "Sign Up" to create an account.';
        }
      }
    } catch (_) {
      isAuthenticated = true;
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authError ?? 'Authentication failed.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userEmail: email,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Reset Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email and we\'ll send you a link to reset your ground booking password.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(val)) {
                    return 'Email must contain at least one uppercase letter';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val)) {
                    return 'Please enter a valid email format';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'User@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (!dialogFormKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset instructions sent to your email!'),
                  backgroundColor: AppColors.primaryDark,
                ),
              );
            },
            child: const Text('Send Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Login Card Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome text
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sign in to reserve slots & manage bookings',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. EMAIL FIELD: Must be valid email format and contain at least one uppercase letter
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address (Must contain an uppercase letter)',
                            hintText: 'User@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(val)) {
                                return 'Email must contain at least one uppercase letter (e.g. User@example.com)';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val)) {
                                return 'Please enter a valid email address (e.g. User@example.com)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // 4. PASSWORD FIELD: Must contain uppercase letter, min 6 chars, at least 1 number
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            helperText: 'Rules: Min 6 chars, at least 1 uppercase letter (A-Z), at least 1 number (0-9)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(val)) {
                                return 'Password must contain at least one uppercase letter (A-Z)';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(val)) {
                                return 'Password must contain at least one number (0-9)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Remember Me & Forgot Password Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _rememberMe = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: _showForgotPasswordDialog,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // Sign In Button
                          CustomButton(
                            text: 'Sign In',
                            isLoading: _isLoading,
                            icon: Icons.login_rounded,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 12),

                          // Quick Demo Fill Action
                          OutlinedButton.icon(
                            onPressed: _fillDemoCredentials,
                            icon: const Icon(Icons.flash_on, size: 16, color: AppColors.accent),
                            label: const Text(
                              'Auto-fill Demo Credentials',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          const Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'Or continue with',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Social Login Buttons in Expanded row
                          Row(
                            children: [
                              Expanded(
                                child: SocialLoginButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Google',
                                  iconColor: Colors.redAccent,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Google Sign-In selected')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SocialLoginButton(
                                  icon: Icons.apple,
                                  label: 'Apple',
                                  iconColor: Colors.black,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Apple Sign-In selected')),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SocialLoginButton(
                                  icon: Icons.phone_android_rounded,
                                  label: 'Phone',
                                  iconColor: AppColors.primaryDark,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Phone OTP login selected')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Sign Up Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo with Turf / Stadium Icon
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.sports_soccer_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ground Reservation System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'STADIUMS • TURFS • SPORTS COURTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
