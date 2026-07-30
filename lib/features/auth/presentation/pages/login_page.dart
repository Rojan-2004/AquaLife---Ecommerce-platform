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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
    final cs = Theme.of(context).colorScheme;
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
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surface,
            border: Border.all(color: cs.outline, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/Aqua_life_logo.png',
            height: 75,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.water_drop, color: cs.primary, size: 40),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'AQUALIFE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
            color: cs.onSurface,
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
        obscureText: isPassword && !isPasswordVisible,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.48)),
          prefixIcon: Icon(icon, color: cs.onSurface.withValues(alpha: 0.72)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: cs.onSurface.withValues(alpha: 0.72),
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
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.48)),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outline)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'Continue with',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72), fontSize: 14),
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
            Text(
              "Don't have an account? ",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72), fontSize: 14),
            ),
             TextButton(
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const RegisterPage()),
                 );
               },
               child: Text(
                 'Sign Up',
                 style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold),
               ),
             ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72), fontSize: 12),
          ),
        ],
      ),
    );
  }
}