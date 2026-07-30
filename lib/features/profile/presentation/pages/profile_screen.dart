import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/auth/presentation/pages/login_page.dart';
import 'package:aqua_life/features/wishlist/presentation/pages/wishlist_screen.dart';
import 'package:aqua_life/features/order/presentation/pages/order_history_screen.dart';
import 'package:aqua_life/features/profile/presentation/pages/profile_update_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _fullName = '';
  String _email = '';
  int _ordersCount = 0;
  int _wishlistCount = 0;
  int _reviewsCount = 0;
  List<dynamic> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Load user info from local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        setState(() {
          _fullName = userData['name'] ?? userData['fullName'] ?? 'AquaLife Member';
          _email = userData['email'] ?? '';
        });
      }

      // 2. Fetch stats & recent orders from backend
      final statsRes = await ApiService.get('/api/v1/user/dashboard');
      if (statsRes.statusCode == 200) {
        final data = jsonDecode(statsRes.body);
        final stats = data['data'] ?? data;
        setState(() {
          _ordersCount = stats['orders'] ?? 0;
          _wishlistCount = stats['wishlist'] ?? 0;
          _reviewsCount = stats['reviews'] ?? 0;
          _recentOrders = stats['recentOrders'] ?? [];
        });
      }
    } catch (_) {}

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    try {
      await ApiService.post('/api/auth/logout', {});
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    await prefs.remove('user_data');

    final secureStorage = const FlutterSecureStorage();
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'refresh_token');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'A';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFfbbf24);
      case 'shipped':
        return const Color(0xFF818cf8);
      case 'delivered':
        return const Color(0xFF4ade80);
      case 'cancelled':
        return const Color(0xFFf87171);
      default:
        return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
      );
    }

    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF112240),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E3A5C)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF1A3A5C),
                    child: Text(
                      _getInitials(_fullName),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_email, style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Orders', '$_ordersCount')),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('Wishlist Items', '$_wishlistCount')),
                const SizedBox(width: 10),
                Expanded(child: _buildStatCard('My Reviews', '$_reviewsCount')),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders list
            if (_recentOrders.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Orders', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              ..._recentOrders.take(5).map((order) {
                final orderId = order['id'] ?? order['_id'] ?? '';
                final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
                final status = order['status'] ?? 'pending';
                final total = order['total'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF112240),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E3A5C)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #$shortId', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF00B4D8))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _statusColor(status)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: _statusColor(status), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Menu Items
            _buildMenuItem(Icons.history, 'Order History', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
            }),
            const SizedBox(height: 10),
            _buildMenuItem(Icons.favorite_outline, 'Wishlist', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
            }),
            const SizedBox(height: 10),
            _buildMenuItem(Icons.edit, 'Edit Profile', () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileUpdateScreen()));
              _loadProfileData();
            }),
            const SizedBox(height: 10),
            _buildMenuItem(Icons.help_outline, 'Help & Support', () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Help section: Please check our web support or chat with AI Assistant.'),
                backgroundColor: const Color(0xFF112240),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            }),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C7A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF112240),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5C)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF112240),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E3A5C)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00B4D8)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF7AB8CC), size: 16),
          ],
        ),
      ),
    );
  }
}
