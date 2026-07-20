import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/theme/app_colors.dart';
import 'package:aqua_life/features/auth/domain/entities/auth_entity.dart';
import 'package:aqua_life/features/auth/presentation/view_model/auth_view_model.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF0D2137)],
            stops: [0.0, 0.4],
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
                _buildSignupForm(compact, authState.isLoading),
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
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildLogo(bool compact) {
    return Column(
      children: [
        Container(
          width: compact ? 64 : 75,
          height: compact ? 64 : 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF112240),
            border: Border.all(color: const Color(0xFF1E3A5C), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                blurRadius: compact ? 14 : 20,
                spreadRadius: compact ? 2 : 4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/Aqua_life_logo.png',
            height: compact ? 64 : 75,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.water_drop, color: AppColors.primaryBlue, size: compact ? 34 : 40),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          'AQUALIFE',
          style: TextStyle(
            fontSize: compact ? 20 : 24,
            fontWeight: FontWeight.bold,
            letterSpacing: compact ? 2 : 3,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(bool compact, bool isLoading) {
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
          SizedBox(
            width: double.infinity,
            child: _buildSubmitButton('Sign Up', compact, isLoading, () async {
              if (isLoading) return;
              if (!_signupFormKey.currentState!.validate()) return;

              final email = _emailController.text.trim();
              final fullName = _nameController.text.trim();
              final password = _passwordController.text;
              final username = email.split('@').first.trim();

              final authViewModel = ref.read(authViewModelProvider.notifier);
              await authViewModel.register(
                AuthEntity(
                  fullName: fullName,
                  email: email,
                  username: username,
                  password: password,
                ),
              );

              if (!mounted) return;

              final authState = ref.read(authViewModelProvider);
              if (authState.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF112240),
                    content: Text(
                      'Registration successful! Please login.',
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                );
                ref.read(authViewModelProvider.notifier).resetState();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else if (authState.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF112240),
                    content: Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                );
              }
            }),
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5C)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        autocorrect: false,
        enableSuggestions: false,
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A6B82)),
          prefixIcon: SizedBox(
            width: compact ? 36 : 40,
            child: Icon(icon, color: const Color(0xFF7AB8CC)),
          ),
          suffixIcon: isPassword
              ? SizedBox(
                  width: compact ? 36 : 40,
                  child: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF7AB8CC),
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
    return SizedBox(
      width: double.infinity,
      height: compact ? 50 : 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3A5C),
          foregroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1E3A5C)),
          ),
          elevation: 0,
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
