import 'package:flutter/material.dart';
import 'app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kMid,
              ),
              child: const Icon(Icons.water_drop, color: kAccent, size: 44),
            ),
            const SizedBox(height: 16),
            const Text(
              'AquaLife',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: kSub, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Description card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: const Text(
                'AquaLife is your one-stop platform for premium aquarium fish, '
                'food, plants, and equipment. We combine smart AI tools with expert '
                'curation to help you build and maintain stunning aquatic ecosystems.',
                style: TextStyle(color: kSub, fontSize: 14, height: 1.7),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Feature highlights
            _feature(
              Icons.smart_toy_outlined,
              'AI Fish Identifier',
              'Snap a photo — instant species ID',
            ),
            _feature(
              Icons.verified_outlined,
              'Expert Picks',
              'Curated by aquarium professionals',
            ),
            _feature(
              Icons.local_shipping_outlined,
              'Fast Delivery',
              'Fresh & live species, handled with care',
            ),
            const SizedBox(height: 32),

            const Text(
              'Made with 💙 for aquarium enthusiasts',
              style: TextStyle(color: kHint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String title, String sub) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kMid,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kAccent, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(sub, style: const TextStyle(color: kSub, fontSize: 12)),
            ],
          ),
        ],
      ),
    ),
  );
}
