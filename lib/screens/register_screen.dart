import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/app_colors.dart';
import '../core/storage/hive_boxes.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  final List<String> _sports = ['Football', 'Cricket', 'Tennis', 'Badminton', 'Basketball'];
  final Set<String> _selectedSports = {'Football'};

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // 5. OTHER FIELDS: Terms and Conditions Checkbox Validation
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to continue'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _fullNameController.text.trim();
    final phone = _phoneController.text.trim();

    // 6. NEW ACCOUNT: Save account to allow login & prevent duplicate accounts
    try {
      Box usersBox;
      if (Hive.isBoxOpen(HiveBoxes.usersBox)) {
        usersBox = Hive.box(HiveBoxes.usersBox);
      } else {
        usersBox = await Hive.openBox(HiveBoxes.usersBox);
      }

      // Check if duplicate email already exists (case-insensitive)
      for (final key in usersBox.keys) {
        final raw = usersBox.get(key);
        if (raw != null) {
          final map = Map<String, dynamic>.from(jsonDecode(raw as String));
          final existingEmail = (map['email'] as String? ?? '').toLowerCase();
          if (existingEmail == email.toLowerCase()) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('An account with this email already exists. Please sign in.'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
        }
      }

      // Save new account
      final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final newUserMap = {
        'id': newId,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'password': password,
        'sports': _selectedSports.toList(),
      };
      await usersBox.put(newId, jsonEncode(newUserMap));
    } catch (e) {
      debugPrint('Registration storage note: $e');
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created for $name! You can now log in anytime.'),
        backgroundColor: AppColors.primaryDark,
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userEmail: email,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
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
                      const Text(
                        'Join Ground Reservation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Book grounds, join tournaments & play anytime',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. OTHER FIELDS: Full Name Validation
                      CustomTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hintText: 'e.g. John Doe',
                        prefixIcon: Icons.person_outline,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (val.trim().length < 3) {
                            return 'Full name must be at least 3 characters';
                          }
                          if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(val.trim())) {
                            return 'Full name must contain letters only';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. EMAIL FIELD: Must be valid format and contain at least one uppercase letter
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
                            return 'Please enter a valid email format (e.g. User@example.com)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. PHONE FIELD: Accepts digits only, keyboard restricted, length validated (10 or 11 digits)
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number (Digits only, 10-11 digits)',
                        hintText: '03001234567',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(val.trim())) {
                            return 'Phone number must accept digits only (no letters, symbols, or spaces)';
                          }
                          if (val.trim().length < 10 || val.trim().length > 11) {
                            return 'Phone number must be 10 or 11 digits (e.g. 03001234567)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. OTHER FIELDS: Preferred Sport Selection Validation
                      FormField<Set<String>>(
                        initialValue: _selectedSports,
                        validator: (_) {
                          if (_selectedSports.isEmpty) {
                            return 'Please select at least one preferred sport';
                          }
                          return null;
                        },
                        builder: (state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preferred Sport(s)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _sports.map((sport) {
                                  final isSelected = _selectedSports.contains(sport);
                                  return FilterChip(
                                    label: Text(sport),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedSports.add(sport);
                                        } else {
                                          if (_selectedSports.length > 1) {
                                            _selectedSports.remove(sport);
                                          }
                                        }
                                        state.didChange(_selectedSports);
                                      });
                                    },
                                    selectedColor: AppColors.primaryLight,
                                    checkmarkColor: AppColors.primaryDark,
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                                    ),
                                    backgroundColor: AppColors.inputBackground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected ? AppColors.primary : AppColors.border,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (state.hasError) ...[
                                const SizedBox(height: 6),
                                Text(
                                  state.errorText!,
                                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. PASSWORD FIELD: Must contain uppercase letter, min 6 chars, at least 1 number
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: 'Create a strong password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        helperText: 'Rules: Min 6 chars, at least 1 uppercase letter (A-Z), at least 1 number (0-9)',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter a password';
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
                      const SizedBox(height: 16),

                      // 5. OTHER FIELDS: Confirm Password Validation
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // 5. OTHER FIELDS: Terms and Conditions checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'I agree to the Terms of Service and Privacy Policy',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Sign Up Button
                      CustomButton(
                        text: 'Create Account',
                        isLoading: _isLoading,
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 16),

                      // Back to Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
