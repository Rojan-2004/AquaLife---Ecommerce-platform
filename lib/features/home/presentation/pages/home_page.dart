import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(compact),
                SizedBox(height: compact ? 12 : 16),
                _buildBanner(compact),
                SizedBox(height: compact ? 12 : 16),
                _buildAICard(compact),
                SizedBox(height: compact ? 18 : 24),
                _buildCategoriesSection(compact),
                SizedBox(height: compact ? 18 : 24),
                _buildExpertsChoice(compact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool compact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(Icons.water_drop, color: kAccent, size: compact ? 18 : 20),
              SizedBox(width: compact ? 4 : 6),
              Expanded(
                child: Text(
                  'AquaLife',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppBarIcon(Icons.search, compact),
            _buildAppBarIcon(Icons.shopping_cart_outlined, compact),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarIcon(IconData icon, bool compact) {
    return SizedBox(
      width: compact ? 36 : 40,
      height: compact ? 36 : 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: compact ? 18 : 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildBanner(bool compact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;

        return Container(
          height: narrow ? 190 : 160,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
            ),
          ),
          child: narrow
              ? _buildCompactBannerContent()
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Nemo (Clownfish)\nStarter Kits',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Everything you need for your first reef friend.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: kSub, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text(
                                  'Rs. 14,999',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kAccent,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(72, 34),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'Shop Now',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRRect(
                      child: Image.asset(
                        'assets/images/clownfish.png',
                        width: constraints.maxWidth < 420 ? 92 : 120,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCompactBannerContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/clownfish.png',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A1628).withValues(alpha: 0.78),
                const Color(0xFF0D2137).withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nemo (Clownfish)\nStarter Kits',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Everything you need for your first reef friend.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Rs. 14,999',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(64, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Shop Now',
                      maxLines: 1,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAICard(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy_outlined, color: kAccent, size: 16),
              SizedBox(width: 6),
              Text(
                'AQUARIUM ASSISTANT',
                style: TextStyle(
                  color: kAccent,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AI Fish Identifier',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Snap a photo to instantly identify species and get care recommendations.',
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: kSub, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined, size: 16),
            label: const Text('Open Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kMid,
              foregroundColor: kAccent,
              minimumSize: Size(compact ? 118 : 140, compact ? 38 : 42),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool compact) {
    final categories = [
      {'icon': Icons.set_meal, 'name': 'Fish', 'sub': '2.4k Species'},
      {'icon': Icons.restaurant, 'name': 'Food', 'sub': '450 Products'},
      {'icon': Icons.grass, 'name': 'Plants', 'sub': '120 Variations'},
      {'icon': Icons.settings, 'name': 'Equipment', 'sub': 'High Precision'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Categories',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Everything for your aquatic world',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: kSub, fontSize: compact ? 11 : 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'View All >',
                style: TextStyle(color: kAccent, fontSize: compact ? 11 : 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: compact ? 8 : 12,
          mainAxisSpacing: compact ? 8 : 12,
          childAspectRatio: compact ? 1.55 : 2,
          children: categories.map((c) {
            return Container(
              padding: EdgeInsets.all(compact ? 9 : 12),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Icon(c['icon'] as IconData, color: kAccent, size: compact ? 20 : 24),
                  SizedBox(width: compact ? 7 : 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c['name'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          c['sub'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: kSub, fontSize: compact ? 10 : 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpertsChoice(bool compact) {
    final products = [
      {
        'name': 'Neon Tetra Bundle',
        'sub': 'Pack of 10 schoolers',
        'price': 'Rs. 1,299',
        'image': 'assets/images/neon_tetra.png',
      },
      {
        'name': 'Premium Coral',
        'sub': 'Handcrafted decor',
        'price': 'Rs. 4,499',
        'image': 'assets/images/coral.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Expert's Choice",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        SizedBox(
          height: compact ? 180 : 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Container(
                width: compact ? 140 : 160,
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              p['image']!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: kMid,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 12 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            p['sub']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: kSub, fontSize: compact ? 10 : 11),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p['price']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: kAccent,
                                    fontSize: compact ? 12 : 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: compact ? 34 : 40,
                                height: compact ? 34 : 40,
                                decoration: const BoxDecoration(
                                  color: kAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: compact ? 14 : 20),
      ],
    );
  }
}
