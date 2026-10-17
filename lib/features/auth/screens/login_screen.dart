import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/google_icon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'Customer@groundzero.pk');
  final _passwordController = TextEditingController(text: 'Pass1234');
  final _nameController = TextEditingController(text: 'Ali Raza');
  final _phoneController = TextEditingController(text: '03001234567');

  bool _isLoginTab = true;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleAuthAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isLoginTab) {
      // 5. OTHER FIELDS: Full Name validation
      if (name.isEmpty) {
        _showError('Please enter your full name');
        return;
      }
      if (name.length < 3) {
        _showError('Full name must be at least 3 characters');
        return;
      }
      if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(name)) {
        _showError('Full name must contain letters only');
        return;
      }

      // 2. PHONE FIELD: Digits only, keyboard restricted, length validated
      if (phone.isEmpty) {
        _showError('Please enter your phone number');
        return;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
        _showError('Phone number must accept digits only (no letters, symbols, or spaces)');
        return;
      }
      if (phone.length < 10 || phone.length > 11) {
        _showError('Phone number must be 10 or 11 digits (e.g. 03001234567)');
        return;
      }
    }

    // 3. EMAIL FIELD: Valid format and at least one uppercase letter
    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(email)) {
      _showError('Email must contain at least one uppercase letter (e.g. User@domain.com)');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showError('Please enter a valid email format (e.g. User@domain.com)');
      return;
    }

    // 4. PASSWORD FIELD: At least one uppercase letter, min 6 characters, at least 1 number
    if (password.isEmpty) {
      _showError('Please enter your password');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _showError('Password must contain at least one uppercase letter (A-Z)');
      return;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      _showError('Password must contain at least one number (0-9)');
      return;
    }

    try {
      if (_isLoginTab) {
        // 6. NEW ACCOUNT / LOGIN: Verify credentials from saved accounts
        await ref.read(authProvider.notifier).signIn(email, password);
      } else {
        // 6. NEW ACCOUNT: Save account so user can log in, prevent duplicates
        await ref.read(authProvider.notifier).signUp(
              name: name,
              email: email,
              phone: phone,
              password: password,
              role: _selectedRole,
            );
      }

      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isOwner) {
        context.go(AppRoutes.ownerRoot);
      } else {
        context.go(AppRoutes.customerRoot);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _quickLogin(UserRole role) async {
    await ref.read(authProvider.notifier).quickDemoLogin(role);
    if (!mounted) return;
    if (role == UserRole.owner) {
      context.go(AppRoutes.ownerRoot);
    } else {
      context.go(AppRoutes.customerRoot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Curved Dark Emerald Gradient Header Card
            Container(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60, bottom: 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF064E3B), // Deepest forest green
                    Color(0xFF047857), // Emerald
                    Color(0xFF059669),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: GroundZeroLogo(
                          size: 28,
                          isDark: true,
                          textColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PK Edition',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isLoginTab ? 'Welcome back' : 'Create Account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isLoginTab
                        ? 'Book stadium pitches & join competitive tournaments'
                        : 'Sign up to reserve venues across Islamabad & Rawalpindi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Pill Toggle (Log In / Sign Up)
                  Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLoginTab = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: _isLoginTab ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: _isLoginTab ? AppColors.navy : Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isLoginTab = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: !_isLoginTab ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: !_isLoginTab ? AppColors.navy : Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
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
            ),

            // Form inputs
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLoginTab) ...[
                    // Role Toggle for Sign Up
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Player')),
                              selected: _selectedRole == UserRole.customer,
                              selectedColor: AppColors.emeraldContainer,
                              onSelected: (_) => setState(() => _selectedRole = UserRole.customer),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Ground Owner')),
                              selected: _selectedRole == UserRole.owner,
                              selectedColor: AppColors.emeraldContainer,
                              onSelected: (_) => setState(() => _selectedRole = UserRole.owner),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildInputField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'e.g. Ali Raza',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number (Digits only, 10-11 digits)',
                      hintText: '03001234567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email Field
                  _buildInputField(
                    controller: _emailController,
                    label: 'Email (Must contain an uppercase letter)',
                    hintText: 'Customer@groundzero.pk',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              size: 20,
                              color: AppColors.textMutedLight,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceSecondaryLight,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Password rules: Min 6 characters, at least 1 uppercase letter (A-Z), and at least 1 number (0-9)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),

                  // Forgot Password Link
                  if (_isLoginTab) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset link sent to registered email')),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.emeraldDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: 16),

                  // Primary Log In Button
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleAuthAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: AppColors.emerald.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              _isLoginTab ? 'Log In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Or continue with Google
                  OutlinedButton(
                    onPressed: () => _quickLogin(UserRole.customer),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GoogleLogoWidget(size: 18),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Or continue with Google',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick One-Tap Demo Access Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: AppColors.warning, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Quick Demo Access',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _quickLogin(UserRole.customer),
                                icon: const Icon(Icons.person, size: 16),
                                label: const Text('Customer', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.navy,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _quickLogin(UserRole.owner),
                                icon: const Icon(Icons.stadium, size: 16),
                                label: const Text('Owner Mode', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.emeraldDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Select Role Link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.onboarding),
                      child: const Text(
                        'Change Onboarding Role Selection',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: AppColors.surfaceSecondaryLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
