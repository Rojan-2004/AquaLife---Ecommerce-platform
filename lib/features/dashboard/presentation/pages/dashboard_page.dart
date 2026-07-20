import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/features/assistant/presentation/pages/assistant_screen.dart';
import 'package:aqua_life/features/cart/presentation/pages/cart_screen.dart';
import 'package:aqua_life/features/home/presentation/pages/home_page.dart';
import 'package:aqua_life/features/order/presentation/pages/order_history_screen.dart';
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
      backgroundColor: kBg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onCartPressed: () => _selectTab(2), onAssistantPressed: () => _selectTab(3)),
          const OrderHistoryScreen(),
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
      backgroundColor: kInput,
      selectedItemColor: kAccent,
      unselectedItemColor: kSub,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: _selectTab,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'Assistant'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
