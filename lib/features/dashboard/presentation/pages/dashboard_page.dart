import 'package:aqua_life/features/assistant/presentation/pages/assistant_screen.dart';
import 'package:aqua_life/features/cart/presentation/pages/cart_screen.dart';
import 'package:aqua_life/features/home/presentation/pages/home_page.dart';
import 'package:aqua_life/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onCartPressed: () => _selectTab(1), onAssistantPressed: () => _selectTab(2)),
          CartScreen(onBack: () => _selectTab(0)),
          const AssistantScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor:      const Color(0xFF0D1F35),
      selectedItemColor:    const Color(0xFF00B4D8),
      unselectedItemColor:  const Color(0xFF4A6B82),
      type:                 BottomNavigationBarType.fixed,
      currentIndex:         _currentIndex,
      onTap:                _selectTab,
      selectedFontSize:     11,
      unselectedFontSize:   11,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          activeIcon: Icon(Icons.home),          label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined),  activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined),      activeIcon: Icon(Icons.smart_toy),     label: 'Assistant'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person),        label: 'Profile'),
      ],
    );
  }
}
