import 'dart:convert';
import 'dart:io';

import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/core/services/storage/token_service.dart';
import 'package:aqua_life/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aqua_life/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:aqua_life/features/splash/presentation/pages/splash_page.dart';
import 'profile_update_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;
  bool _isUpdatingImage = false;
  bool _isLoadingProfile = true;
  String _fullName = 'AquaLife Member';
  String _email = 'hello@aqualife.com';
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileFromPrefs();
      _loadProfileFromBackend();
    });
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = ref.read(userSessionServiceProvider);
    if (!mounted) return;
    setState(() {
      _userId = prefs.getUserId();
      _email = prefs.getUserEmail() ?? _email;
      _fullName = prefs.getUserFullName() ?? prefs.getUsername() ?? _fullName;
      _profileImagePath = prefs.getUserProfileImage();
    });
  }

  Future<void> _loadProfileFromBackend() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(ApiEndpoints.authMe);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data is String ? jsonDecode(response.data) : response.data;
        final user = body['data'] ?? body;
        if (user is Map) {
          final name = user['fullName'] ?? user['name'];
          final email = user['email'];
          final profilePicture = user['profilePicture'];
          String? resolvedImagePath = _profileImagePath;
          if (profilePicture != null && profilePicture.toString().isNotEmpty) {
            resolvedImagePath = profilePicture.toString().startsWith('http')
                ? profilePicture.toString()
                : '${ApiEndpoints.baseUrl}${profilePicture.toString()}';
          }

          if (!mounted) return;
          setState(() {
            if (name != null) _fullName = name.toString();
            if (email != null) _email = email.toString();
            _userId = user['id'] ?? user['_id']?.toString();
            _profileImagePath = resolvedImagePath;
            _isLoadingProfile = false;
          });

          await ref.read(userSessionServiceProvider).saveUserSession(
            userId: _userId ?? '',
            email: _email,
            username: user['username']?.toString() ?? '',
            fullName: _fullName,
            phoneNumber: user['phoneNumber']?.toString(),
            profilePicture: resolvedImagePath,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile from backend: $e');
    }
    if (mounted) setState(() => _isLoadingProfile = false);
  }

  Future<void> _uploadProfileImageToBackend(File imageFile) async {
    setState(() => _isUpdatingImage = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await apiClient.uploadFile(
        ApiEndpoints.authUploadProfilePicture,
        formData: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data is String ? jsonDecode(response.data) : response.data;
        final user = body['data'] ?? body;
        if (user is Map && user['profilePicture'] != null) {
          final profileUrl = user['profilePicture'].toString().startsWith('http')
              ? user['profilePicture'].toString()
              : '${ApiEndpoints.baseUrl}${user['profilePicture'].toString()}';

          if (!mounted) return;
          setState(() => _profileImagePath = profileUrl);
          await ref.read(userSessionServiceProvider).updateUserProfileImage(profileUrl);
        }
      }
    } catch (e) {
      debugPrint('Profile picture upload failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile picture')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 12 : 16,
            ),
            child: Column(
              children: [
                _buildHeader(compact),
                SizedBox(height: compact ? 14 : 18),
                _buildStatsRow(compact),
                SizedBox(height: compact ? 16 : 20),
                _buildSettingsList(compact),
                SizedBox(height: compact ? 12 : 16),
                _buildLogoutRow(compact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showImageSourceSheet,
            child: _buildAvatar(compact),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoadingProfile ? 'Loading...' : _fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: compact ? 3 : 4),
                Text(
                  _isLoadingProfile ? '' : _email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kSub, fontSize: compact ? 11 : 13),
                ),
              ],
            ),
          ),
          if (!compact)
            TextButton(
              onPressed: _showImageSourceSheet,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Edit',
                maxLines: 1,
                style: TextStyle(
                  color: kAccent,
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool compact) {
    final avatarSize = compact ? 58.0 : 64.0;

    return Stack(
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: kMid,
            shape: BoxShape.circle,
            border: Border.all(color: kBorder, width: 1.5),
            image: _profileImagePath != null
                ? DecorationImage(
                    image: _profileImagePath!.startsWith('http')
                        ? NetworkImage(_profileImagePath!)
                        : FileImage(File(_profileImagePath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: _profileImagePath == null
              ? const Icon(Icons.person_outline, color: kAccent, size: 30)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: compact ? 26 : 30,
            height: compact ? 26 : 30,
            decoration: BoxDecoration(
              color: kAccent,
              shape: BoxShape.circle,
              border: Border.all(color: kCard, width: 2),
            ),
            child: Icon(
              _isUpdatingImage ? Icons.hourglass_empty : Icons.camera_alt,
              color: Colors.white,
              size: compact ? 13 : 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool compact) {
    const stats = [
      _Stat(icon: Icons.receipt_long_outlined, value: '12', label: 'Orders'),
      _Stat(icon: Icons.favorite_outline, value: '28', label: 'Wishlist'),
      _Stat(icon: Icons.star_border, value: '8', label: 'Reviews'),
    ];

    return Row(
      children: stats
          .map((stat) => Expanded(child: _buildStatCard(stat, compact)))
          .toList(),
    );
  }

  Widget _buildStatCard(_Stat stat, bool compact) {
    return Container(
      margin: EdgeInsets.only(right: compact ? 8 : 10),
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(stat.icon, color: kAccent, size: compact ? 18 : 22),
          SizedBox(height: compact ? 5 : 7),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: kSub, fontSize: compact ? 10 : 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(bool compact) {
    const rows = [
      _MenuRow(icon: Icons.history, label: 'Order History'),
      _MenuRow(icon: Icons.favorite_border, label: 'Wishlist'),
      _MenuRow(icon: Icons.person_outline, label: 'Edit Profile'),
      _MenuRow(icon: Icons.location_on_outlined, label: 'Saved Addresses'),
      _MenuRow(icon: Icons.credit_card, label: 'Payment Methods'),
      _MenuRow(icon: Icons.notifications_outlined, label: 'Notifications'),
      _MenuRow(icon: Icons.support_agent, label: 'Help & Support'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, _) => SizedBox(height: compact ? 8 : 10),
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row.label == 'Edit Profile') {
          return _buildEditProfileRow(compact);
        }
        return _buildMenuRow(row, compact);
      },
    );
  }

  Widget _buildEditProfileRow(bool compact) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfileUpdateScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 11 : 13,
        ),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: kAccent, size: compact ? 18 : 21),
            SizedBox(width: compact ? 9 : 12),
            const Expanded(
              child: Text(
                'Edit Profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: kSub, size: compact ? 18 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(_MenuRow row, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 11 : 13,
      ),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(row.icon, color: kAccent, size: compact ? 18 : 21),
          SizedBox(width: compact ? 9 : 12),
          Expanded(
            child: Text(
              row.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: kSub, size: compact ? 18 : 20),
        ],
      ),
    );
  }

  Widget _buildLogoutRow(bool compact) {
    return InkWell(
      onTap: _logout,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
          vertical: compact ? 11 : 13,
        ),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: kDanger, size: 21),
            SizedBox(width: compact ? 9 : 12),
            const Expanded(
              child: Text(
                'Log Out',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kDanger,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: kDanger, size: compact ? 18 : 20),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final userSession = ref.read(userSessionServiceProvider);
    final tokenService = ref.read(tokenServiceProvider);

    await authViewModel.logout();
    await userSession.clearUserSession();
    await tokenService.clearTokens();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (route) => false,
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImageSourceButton(
                  context: dialogContext,
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  source: ImageSource.camera,
                ),
                const SizedBox(height: 10),
                _buildImageSourceButton(
                  context: dialogContext,
                  icon: Icons.photo_library_outlined,
                  label: 'Choose From Gallery',
                  source: ImageSource.gallery,
                ),
                if (_profileImagePath != null) ...[
                  const SizedBox(height: 10),
                  _buildImageSourceButton(
                    context: dialogContext,
                    icon: Icons.delete_outline,
                    label: 'Remove Photo',
                    source: null,
                    destructive: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    ImageSource? source,
    bool destructive = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _updateProfileImage(source);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: destructive ? kDanger.withValues(alpha: 0.16) : kMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: destructive ? kDanger : kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: destructive ? kDanger : kAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: destructive ? kDanger : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfileImage(ImageSource? source) async {
    if (source == null) {
      setState(() {
        _profileImagePath = null;
      });
      await ref.read(userSessionServiceProvider).updateUserProfileImage(null);
      return;
    }

    if (!mounted) return;
    setState(() => _isUpdatingImage = true);

    try {
      final image = await _picker.pickImage(source: source);
      if (!mounted || image == null) return;

      setState(() => _profileImagePath = image.path);
      await _uploadProfileImageToBackend(File(image.path));

      await ref
          .read(userSessionServiceProvider)
          .updateUserProfileImage(image.path);
    } finally {
      if (mounted) setState(() => _isUpdatingImage = false);
    }
  }
}

class _Stat {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;
}

class _MenuRow {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
