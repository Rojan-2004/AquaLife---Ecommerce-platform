import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          Container(
            width: compact ? 54 : 62,
            height: compact ? 54 : 62,
            decoration: const BoxDecoration(
              color: kMid,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: kAccent, size: 30),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AquaLife Member',
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
                  'hello@aqualife.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kSub, fontSize: compact ? 11 : 13),
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          TextButton(
            onPressed: () {},
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

  Widget _buildStatsRow(bool compact) {
    const stats = [
      _Stat(icon: Icons.receipt_long_outlined, value: '12', label: 'Orders'),
      _Stat(icon: Icons.favorite_outline, value: '28', label: 'Wishlist'),
      _Stat(icon: Icons.star_border, value: '8', label: 'Reviews'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: compact ? 8 : 10,
      mainAxisSpacing: compact ? 8 : 10,
      childAspectRatio: compact ? 1.1 : 1.25,
      children: stats.map((stat) {
        return Container(
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
      }).toList(),
    );
  }

  Widget _buildSettingsList(bool compact) {
    const rows = [
      _MenuRow(icon: Icons.history, label: 'Order History'),
      _MenuRow(icon: Icons.favorite_border, label: 'Wishlist'),
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
      itemBuilder: (context, index) => _buildMenuRow(rows[index], compact),
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
    );
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
