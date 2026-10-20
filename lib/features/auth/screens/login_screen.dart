import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/google_icon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;
  final bool initialIsLogin;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.customer,
    this.initialIsLogin = true,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late bool _isLoginTab;
  late UserRole _selectedRole;
  late bool _rememberMe;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(text: 'Ali Raza');
  final _phoneController = TextEditingController(text: '03001234567');

  @override
  void initState() {
    super.initState();
    _isLoginTab = widget.initialIsLogin;
    _selectedRole = widget.initialRole;
    _rememberMe = LocalStorageService.instance.isRememberMe;

    // Default to the customer sport demo credentials for convenience
    _emailController.text = 'customer@groundzero.sport';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppTheme.emeraldDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _fillDemoCredentials(UserRole role) {
    setState(() {
      if (role == UserRole.customer) {
        _emailController.text = 'customer@groundzero.sport';
        _passwordController.text = '123456';
      } else {
        _emailController.text = 'owner@groundzero.sport';
        _passwordController.text = '123456';
      }
    });

    _showFeedback(
      'Filled ${role == UserRole.customer ? 'Player' : 'Owner'} demo credentials (${_emailController.text})',
    );
  }

  Future<void> _handleAuthAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_isLoginTab) {
      if (name.isEmpty) {
        _showFeedback('Please enter your full name', isError: true);
        return;
      }
      if (phone.isEmpty) {
        _showFeedback('Please enter your phone number', isError: true);
        return;
      }
    }

    if (email.isEmpty) {
      _showFeedback('Please enter your email address', isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showFeedback(
        'Please enter a valid email address (e.g. user@groundzero.sport)',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      _showFeedback('Please enter your password', isError: true);
      return;
    }
    if (password.length < 6) {
      _showFeedback(
        'Password must be at least 6 characters long',
        isError: true,
      );
      return;
    }

    // Save remember me preference
    await LocalStorageService.instance.setRememberMe(_rememberMe);

    try {
      if (_isLoginTab) {
        // Authenticate with entered credentials
        await ref.read(authProvider.notifier).signIn(email, password);
      } else {
        // Create new account and save role in User model
        await ref
            .read(authProvider.notifier)
            .signUp(
              name: name,
              email: email,
              phone: phone,
              password: password,
              role: _selectedRole,
            );
      }

      if (!mounted) return;

      // CRITICAL REQUIREMENT: Route by the role stored in the account,
      // not by any transient button tapped.
      final auth = ref.read(authProvider);
      if (auth.isOwner) {
        context.go(AppRoutes.ownerRoot);
      } else {
        context.go(AppRoutes.customerRoot);
      }
    } catch (e) {
      if (!mounted) return;
      _showFeedback(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: bottomInset > 0 ? bottomInset + 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Curved Dark Emerald Gradient Header Card
              Container(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 54,
                  bottom: 32,
                ),
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppTheme.pillRadius,
                            ),
                          ),
                          child: const Text(
                            'Arena & Turf OS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isLoginTab ? 'Welcome back' : 'Create Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLoginTab
                          ? 'Book stadium pitches & manage arena operations'
                          : 'Sign up to reserve venues across Islamabad & Rawalpindi',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),

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
                                  color: _isLoginTab
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: _isLoginTab
                                          ? AppTheme.navy
                                          : Colors.white,
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
                                  color: !_isLoginTab
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: !_isLoginTab
                                          ? AppTheme.navy
                                          : Colors.white,
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

              // Form Inputs & Authentication Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // -----------------------------------------------------------
                    // SIGN UP FIELDS
                    // -----------------------------------------------------------
                    if (!_isLoginTab) ...[
                      // Role Selection Pills for Sign Up
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Role',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleChoicePill(
                                  role: UserRole.customer,
                                  label: 'Player (Customer)',
                                  icon: Icons.sports_soccer_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildRoleChoicePill(
                                  role: UserRole.owner,
                                  label: 'Arena Owner',
                                  icon: Icons.stadium_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'e.g. Ali Raza',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),

                      _buildInputField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hintText: '03001234567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // -----------------------------------------------------------
                    // SHARED EMAIL & PASSWORD FIELDS
                    // -----------------------------------------------------------
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'user@groundzero.sport',
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
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.textMutedLight,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceSecondaryLight,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.borderLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.borderLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.emerald,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Remember Me & Forgot Password Row (for Log In)
                    if (_isLoginTab) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Remember Me Checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() => _rememberMe = !_rememberMe);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    activeColor: AppTheme.emerald,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    side: const BorderSide(
                                      color: AppTheme.borderLight,
                                      width: 1.5,
                                    ),
                                    onChanged: (val) {
                                      setState(
                                        () => _rememberMe = val ?? false,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Forgot Password Link
                          TextButton(
                            onPressed: () {
                              _showFeedback(
                                'Password reset link sent to your registered email.',
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: AppTheme.emeraldDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 22),

                    // Primary Gradient Action Button
                    GradientButton(
                      text: _isLoginTab ? 'Log In' : 'Sign Up',
                      isLoading: authState.isLoading,
                      onPressed: _handleAuthAction,
                    ),

                    const SizedBox(height: 20),

                    // Divider with "Or continue with"
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppTheme.borderLight),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: AppTheme.borderLight),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // "Continue with Google" Button (UI Only -> Coming Soon Snackbar)
                    OutlinedButton(
                      onPressed: () {
                        _showFeedback(
                          'Google Sign-in coming soon in next release.',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(
                          color: AppTheme.borderLight,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.buttonRadius,
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GoogleLogoWidget(size: 20),
                          SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'Continue with Google',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.navy,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // "Fast Preview Demo" Box with Two Chips (Customer and Arena Owner)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(
                          AppTheme.cardRadius,
                        ),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1.2,
                        ),
                        boxShadow: AppTheme.softShadowLight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: AppTheme.emeraldDark,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Flexible(
                                child: Text(
                                  'Fast Preview Demo',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.navy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap a role to auto-fill verified test credentials:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Two chips: Customer and Arena Owner (Responsive Wrap)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildDemoChip(
                                label: 'Customer',
                                icon: Icons.person_rounded,
                                color: AppTheme.emerald,
                                onTap: () =>
                                    _fillDemoCredentials(UserRole.customer),
                              ),
                              _buildDemoChip(
                                label: 'Arena Owner',
                                icon: Icons.stadium_rounded,
                                color: AppTheme.navy,
                                onTap: () =>
                                    _fillDemoCredentials(UserRole.owner),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Return to Role Selection Link
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.roleSelection),
                        child: const Text(
                          'Change Onboarding Role Selection',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildRoleChoicePill({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.emeraldContainer
              : AppColors.surfaceSecondaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.emerald : AppTheme.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppTheme.emeraldDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.emeraldDark : AppTheme.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
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
            fontWeight: FontWeight.w700,
            color: AppTheme.navy,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.emerald, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
