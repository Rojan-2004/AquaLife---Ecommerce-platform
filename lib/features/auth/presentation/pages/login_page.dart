import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua_life/app/theme/app_colors.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/features/auth/presentation/pages/register_page.dart';
import 'package:aqua_life/features/dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? sessionCookie;
      Map<String, dynamic>? userData;

      try {
        // Try NextAuth flow first
        final csrfRes = await http.get(Uri.parse('${ApiConstants.baseUrl}/api/auth/csrf'));
        if (csrfRes.statusCode == 200) {
          final csrfData = jsonDecode(csrfRes.body);
          final csrfToken = csrfData['csrfToken'];
          if (csrfToken != null) {
            final loginRes = await http.post(
              Uri.parse('${ApiConstants.baseUrl}/api/auth/callback/credentials'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'csrfToken': csrfToken,
                'email': _emailController.text,
                'password': _passwordController.text,
                'json': 'true',
              }),
            );

            final setCookie = loginRes.headers['set-cookie'];
            if (setCookie != null) {
              final cookies = setCookie.split(RegExp(r',(?=[^;]+(?:;|$))'));
              for (var cookie in cookies) {
                if (cookie.contains('next-auth.session-token') || cookie.contains('sessionToken')) {
                  sessionCookie = cookie.split(';').first;
                  break;
                }
              }
              sessionCookie ??= setCookie.split(';').first;
            }
          }
        }
      } catch (_) {
        // NextAuth endpoints not active/supported
      }

      // Fallback to Express backend login if NextAuth yielded no cookie
      if (sessionCookie == null) {
        final loginRes = await http.post(
          Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (loginRes.statusCode == 200) {
          final data = jsonDecode(loginRes.body);
          final token = data['token'] ?? data['data']?['token'];
          userData = data['data'] ?? data['user'];
          if (token != null) {
            sessionCookie = 'token=$token';
          }
        } else {
          final data = jsonDecode(loginRes.body);
          throw Exception(data['message'] ?? 'Invalid email or password');
        }
      }

      if (sessionCookie == null) {
        throw Exception('Invalid email or password');
      }

      // Save session cookie
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', sessionCookie);

      // Also persist token for ApiClient auth interceptor
      final secureStorage = const FlutterSecureStorage();
      final tokenValue = sessionCookie.contains('=')
          ? sessionCookie.split('=').sublist(1).join('=').split(';').first.trim()
          : sessionCookie;
      await secureStorage.write(key: 'auth_token', value: tokenValue);

      // Validate session & check role
      if (userData == null) {
        final sessionRes = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/api/auth/session'),
          headers: {'Cookie': sessionCookie},
        );

        if (sessionRes.statusCode == 200) {
          final sessionData = jsonDecode(sessionRes.body);
          userData = sessionData['user'];
        } else {
          // Fallback to /api/v1/auth/me
          final meRes = await http.get(
            Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/me'),
            headers: {
              'Cookie': sessionCookie,
              'Authorization': 'Bearer ${sessionCookie.replaceAll('token=', '')}'
            },
          );
          if (meRes.statusCode == 200) {
            final meData = jsonDecode(meRes.body);
            userData = meData['data'] ?? meData;
          }
        }
      }

      if (userData != null) {
        final role = userData['role'];
        if (role == 'admin') {
          await prefs.remove('session_cookie');
          throw Exception('Admin access is web-only');
        }

        await prefs.setString('user_data', jsonEncode(userData));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Login successful!'),
            backgroundColor: const Color(0xFF112240),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
        return;
      }
      throw Exception('Failed to retrieve user session');
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D2137),
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildLoginForm(),
                const SizedBox(height: 20),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildSocialLogin(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF112240),
            border: Border.all(color: const Color(0xFF1E3A5C), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/Aqua_life_logo.png',
            height: 75,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.water_drop, color: AppColors.primaryBlue, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'AQUALIFE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _emailController,
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_outlined,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onTogglePassword: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSubmitButton('Log In', _handleLogin, isLoading: _isLoading),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
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
        obscureText: isPassword && !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A6B82)),
          prefixIcon: Icon(icon, color: const Color(0xFF7AB8CC)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF7AB8CC),
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (hint.contains('email') && !value.contains('@')) {
            return 'Please enter a valid email';
          }
          if (hint.contains('password') && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed, {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withOpacity(0.3),
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
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF1E3A5C))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: Color(0xFF4A6B82)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF1E3A5C))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        const Text(
          'Continue with',
          style: TextStyle(color: Color(0xFF7AB8CC), fontSize: 14),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata, 'Google', Colors.redAccent),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.apple, 'Apple', Colors.white),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.facebook, 'Facebook', Colors.blueAccent),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Color(0xFF7AB8CC), fontSize: 14),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5C)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 12),
          ),
        ],
      ),
    );
  }
}