import 'package:flutter/material.dart';
import 'package:aqua_life/features/dashboard/presentation/pages/dashboard_page.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final shortOrderId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐠', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              const Text(
                'Order Placed!',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: #$shortOrderId',
                style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to DashboardPage but switch to Profile tab (tab 3)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardPage()), // Dashboard will load Home tab by default, but we can pop or navigate to DashboardPage and handle it, or navigate to a dedicated OrderHistoryScreen.
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E3A5C)),
                    foregroundColor: const Color(0xFF00B4D8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
