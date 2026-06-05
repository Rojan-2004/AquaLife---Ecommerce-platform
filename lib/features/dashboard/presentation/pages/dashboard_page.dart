import 'package:flutter/material.dart';
import 'package:aqua_life/views/bottoms_screen/app_theme.dart';
import 'package:aqua_life/views/bottoms_screen/home_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    _PlaceholderPage(label: 'Shop', icon: Icons.store_outlined),
    _PlaceholderPage(label: 'Assistant', icon: Icons.smart_toy_outlined),
    _PlaceholderPage(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: kInput,
      selectedItemColor: kAccent,
      unselectedItemColor: kHint,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Shop'),
        BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined), label: 'Assistant'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PlaceholderPage({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Coming soon',
              style: TextStyle(color: kSub, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
