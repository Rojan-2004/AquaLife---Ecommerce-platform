import 'dart:convert';

import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileUpdateScreen extends ConsumerStatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  ConsumerState<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends ConsumerState<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _isChangingPassword = false;
  final bool _obscureNew = true;
  final bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingProfile());
  }

  void _loadExistingProfile() {
    final prefs = ref.read(userSessionServiceProvider);
    if (!mounted) return;
    setState(() {
      _fullNameController.text = prefs.getUserFullName() ?? '';
      _emailController.text = prefs.getUserEmail() ?? '';
      _usernameController.text = prefs.getUsername() ?? '';
      _phoneController.text = prefs.getUserPhoneNumber() ?? '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isSaving = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final fullName = _fullNameController.text.trim();
      final parts = fullName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      final body = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'username': _usernameController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      };

      final response = await apiClient.put(
        ApiEndpoints.authUpdateProfile,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final raw = response.data is String ? jsonDecode(response.data) : response.data;
        final user = raw['data'] ?? raw;
        if (user is Map) {
          await ref.read(userSessionServiceProvider).saveUserSession(
            userId: user['id']?.toString() ?? user['_id']?.toString() ?? '',
            email: user['email']?.toString() ?? _emailController.text.trim(),
            username: user['username']?.toString() ?? _usernameController.text.trim(),
            fullName: user['fullName']?.toString() ?? _fullNameController.text.trim(),
            phoneNumber: user['phoneNumber']?.toString(),
            profilePicture: user['profilePicture']?.toString(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      final message = _messageFromResponseData(response.data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? 'Update failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile update failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (newPass != confirm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
      }
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.put(
        ApiEndpoints.authChangePassword,
        data: {
          'currentPassword': current,
          'newPassword': newPass,
        },
      );

      if (response.statusCode == 200) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      } else {
        final message = response.data is Map
            ? (response.data['message'] as String?)
            : null;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message ?? 'Password update failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password update failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  String? _messageFromResponseData(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 20,
            vertical: compact ? 12 : 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  compact: compact,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Required';
                    if (v.split(' ').length < 2) return 'Enter first and last name';
                    return null;
                  },
                ),
                SizedBox(height: compact ? 10 : 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  compact: compact,
                  enabled: false,
                ),
                SizedBox(height: compact ? 10 : 12),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email,
                  compact: compact,
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return 'Required';
                    if (v.length < 3) return 'Min 3 characters';
                    return null;
                  },
                ),
                SizedBox(height: compact ? 10 : 12),
                 _buildTextField(
                   controller: _phoneController,
                   label: 'Phone Number',
                   icon: Icons.phone_outlined,
                   compact: compact,
                   keyboardType: TextInputType.phone,
                   validator: (value) {
                     final v = value?.trim() ?? '';
                     if (v.isEmpty) return null;
                     if (v.length < 10) return 'Invalid phone number';
                     return null;
                   },
                 ),
                 SizedBox(height: compact ? 16 : 20),
                 const Align(
                   alignment: Alignment.centerLeft,
                   child: Text(
                     'Change Password',
                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                   ),
                 ),
                 SizedBox(height: compact ? 10 : 12),
                 _buildTextField(
                   controller: _currentPasswordController,
                   label: 'Current Password',
                   icon: Icons.lock_outline,
                   compact: compact,
                   obscureText: true,
                   validator: (value) {
                     final v = value?.trim() ?? '';
                     if (v.isEmpty) return 'Required';
                     return null;
                   },
                 ),
                 SizedBox(height: compact ? 10 : 12),
                 _buildTextField(
                   controller: _newPasswordController,
                   label: 'New Password',
                   icon: Icons.lock_outline,
                   compact: compact,
                   obscureText: _obscureNew,
                   validator: (value) {
                     final v = value?.trim() ?? '';
                     if (v.isEmpty) return 'Required';
                     if (v.length < 6) return 'Min 6 characters';
                     return null;
                   },
                 ),
                 SizedBox(height: compact ? 10 : 12),
                 _buildTextField(
                   controller: _confirmPasswordController,
                   label: 'Confirm New Password',
                   icon: Icons.lock_outline,
                   compact: compact,
                   obscureText: _obscureConfirm,
                   validator: (value) {
                     final v = value?.trim() ?? '';
                     if (v.isEmpty) return 'Required';
                     if (v != _newPasswordController.text.trim()) return 'Passwords do not match';
                     return null;
                   },
                 ),
                 SizedBox(height: compact ? 16 : 20),
                 SizedBox(
                   width: double.infinity,
                   height: compact ? 50 : 54,
                   child: ElevatedButton(
                     onPressed: _isChangingPassword ? null : _changePassword,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF1A3A5C),
                       foregroundColor: const Color(0xFF00B4D8),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       elevation: 0,
                     ),
                     child: _isChangingPassword
                         ? const SizedBox(
                             height: 20,
                             width: 20,
                             child: CircularProgressIndicator(
                               strokeWidth: 2,
                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B4D8)),
                             ),
                           )
                         : const Text(
                             'Change Password',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                   ),
                 ),
                 SizedBox(height: compact ? 12 : 16),
                SizedBox(
                  width: double.infinity,
                  height: compact ? 50 : 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool compact = false,
    bool enabled = true,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? kInput : kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: kSub, fontSize: compact ? 12 : 13),
          prefixIcon: SizedBox(
            width: compact ? 36 : 40,
            child: Icon(icon, color: kAccent, size: compact ? 18 : 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 11 : 14,
          ),
        ),
        validator: validator,
      ),
    );
  }
}
