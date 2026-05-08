import 'package:aqua_life/views/dashboard_user_view.dart';
import 'package:aqua_life/views/sign_up_user_view.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF4A6B82)),
    prefixIcon: Icon(icon, color: const Color(0xFF4A6B82), size: 18),
    filled: true,
    fillColor: const Color(0xFF0D1F35),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1E3A5C)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF1E3A5C)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF00B4D8)),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF7AB8CC),
        letterSpacing: 1,
      ),
    ),
  );

  Widget _socialBtn(String label, IconData icon) => Expanded(
    child: OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFF1E3A5C)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF0D2137), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A3A5C),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B4D8).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Color(0xFF00B4D8),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AquaLife',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    'Sustainable Aquatic Ecosystems',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7AB8CC)),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF112240).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF1E3A5C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Please enter your details to log in.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7AB8CC),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _label('EMAIL ADDRESS'),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDeco(
                            'name@example.com',
                            Icons.mail_outline,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter your email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _label('PASSWORD'),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00B4D8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          decoration: _inputDeco('••••••••', Icons.lock_outline)
                              .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF4A6B82),
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Please enter your password'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _remember,
                              onChanged: (v) => setState(() => _remember = v!),
                              checkColor: Colors.white,
                              activeColor: const Color(0xFF00B4D8),
                              side: const BorderSide(color: Color(0xFF4A6B82)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const Text(
                              'Remember for 30 days',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7AB8CC),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A5C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFF1E3A5C))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR CONTINUE WITH',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF4A6B82),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFF1E3A5C))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _socialBtn('Google', Icons.g_mobiledata),
                            const SizedBox(width: 12),
                            _socialBtn('Apple', Icons.apple),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Color(0xFF7AB8CC),
                          fontSize: 13,
                        ),
 
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
