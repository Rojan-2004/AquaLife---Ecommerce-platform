import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/theme/app_colors.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _signupFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final name = _nameController.text.trim();
      final password = _passwordController.text;

      var res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        // Fallback to Express backend register endpoint
        res = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fullName': name,
            'email': email,
            'password': password,
          }),
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: const Text('Registration successful! Please log in.'),
             backgroundColor: Theme.of(context).colorScheme.surface,
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        final body = jsonDecode(res.body);
        throw Exception(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (mounted) {
        final errMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errMsg),
          backgroundColor: const Color(0xFF7f1d1d),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface,
              cs.surface.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 24,
              vertical: compact ? 18 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(compact),
                SizedBox(height: compact ? 12 : 24),
                _buildBackButton(),
                SizedBox(height: compact ? 12 : 24),
                _buildSignupForm(compact),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildLogo(bool compact) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: compact ? 64 : 75,
          height: compact ? 64 : 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surface,
            border: Border.all(color: cs.outline, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: compact ? 14 : 20,
                spreadRadius: compact ? 2 : 4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/Aqua_life_logo.png',
            height: compact ? 64 : 75,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.water_drop, color: cs.primary, size: compact ? 34 : 40),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          'AQUALIFE',
          style: TextStyle(
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.bold,
            letterSpacing: compact ? 2 : 3,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(bool compact) {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _nameController,
            hint: 'Enter your full name',
            icon: Icons.person_outlined,
            compact: compact,
          ),
          SizedBox(height: compact ? 12 : 16),
          _buildTextField(
            controller: _emailController,
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            compact: compact,
            textCapitalization: TextCapitalization.none,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'This field is required';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Please enter a valid email';
              }
              final username = email.split('@').first.trim();
              if (username.length < 3) {
                return 'Use an email with at least 3 characters before @';
              }
              return null;
            },
          ),
          SizedBox(height: compact ? 12 : 16),
          _buildTextField(
            controller: _passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_outlined,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            compact: compact,
            textInputAction: TextInputAction.next,
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'This field is required';
              if (password.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onTogglePassword: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          SizedBox(height: compact ? 12 : 16),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm your password',
            icon: Icons.lock_outlined,
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            compact: compact,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if ((value ?? '').isEmpty) return 'This field is required';
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onTogglePassword: () {
              setState(
                () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
              );
            },
          ),
          SizedBox(height: compact ? 18 : 24),
          _buildSubmitButton('Sign Up', compact, _isLoading, _handleSignup),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool isPassword = false,
    bool isPasswordVisible = false,
    bool compact = false,
    String? Function(String?)? validator,
    VoidCallback? onTogglePassword,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: cs.onSurface, fontSize: compact ? 14 : 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.48)),
          prefixIcon: SizedBox(
            width: compact ? 36 : 40,
            child: Icon(icon, color: cs.onSurface.withValues(alpha: 0.72)),
          ),
          suffixIcon: isPassword
              ? SizedBox(
                  width: compact ? 36 : 40,
                  child: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: cs.onSurface.withValues(alpha: 0.72),
                    ),
                    onPressed: onTogglePassword,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 11 : 14,
          ),
        ),
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildSubmitButton(
    String text,
    bool compact,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: compact ? 50 : 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
