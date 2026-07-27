import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/product_detail/presentation/pages/product_detail_screen.dart';
import 'package:aqua_life/features/catalogue/presentation/view/catalogue_screen.dart';
import 'package:aqua_life/features/home/presentation/view_model/home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onCartPressed, this.onAssistantPressed});

  final VoidCallback? onCartPressed;
  final VoidCallback? onAssistantPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 16,
                vertical: compact ? 12 : 16,
              ),
              child: state.isLoading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(compact),
                        SizedBox(height: compact ? 12 : 16),
                        _buildBanner(compact, null),
                        SizedBox(height: compact ? 12 : 16),
                        _buildAICard(compact),
                        SizedBox(height: compact ? 18 : 24),
                        _buildCategoriesSection(context, compact, const []),
                        SizedBox(height: compact ? 18 : 24),
                        _buildExpertsChoice(context, compact, const []),
                      ],
                    )
                  : state.error != null
                      ? Center(child: Text('Failed to load: ${state.error}', style: const TextStyle(color: Colors.white54)))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAppBar(compact),
                            SizedBox(height: compact ? 12 : 16),
                            _buildBanner(compact, state.bannerProduct),
                            SizedBox(height: compact ? 12 : 16),
                            _buildAICard(compact),
                            SizedBox(height: compact ? 18 : 24),
                            _buildCategoriesSection(context, compact, state.categories),
                            SizedBox(height: compact ? 18 : 24),
                            _buildExpertsChoice(context, compact, state.spotlightProducts),
                          ],
                        ),
            );
          },
        ),
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
              Image.asset(
                'assets/Aqua_life_logo.png',
                height: compact ? 20 : 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.water_drop, color: kAccent, size: 20),
              ),
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
            _buildAppBarIcon(
              Icons.shopping_cart_outlined,
              compact,
              onCartPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarIcon(
    IconData icon,
    bool compact, [
    VoidCallback? onPressed,
  ]) {
    return SizedBox(
      width: compact ? 36 : 40,
      height: compact ? 36 : 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: compact ? 18 : 20),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildBanner(bool compact, Map<String, dynamic>? product) {
    final name = product?['name'] as String? ?? 'Featured Product';
    final price = product?['price'] as num? ?? 0;
    final images = product?['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
    final fullImageUrl = ApiConstants.getFullImageUrl(imageUrl);

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
                  ? _buildCompactBannerContent(name, price, fullImageUrl, compact, product != null && product['id'] != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(productId: product['id'] as String),
                            ),
                          );
                        }
                      : null)
                  : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product?['description'] as String? ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: kSub, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Rs. ${price.toStringAsFixed(0)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: product != null && product['id'] != null
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ProductDetailScreen(productId: product['id'] as String),
                                            ),
                                          );
                                        }
                                      : null,
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
                    if (fullImageUrl != null)
                      ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: fullImageUrl,
                          width: constraints.maxWidth < 420 ? 92 : 120,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(width: constraints.maxWidth < 420 ? 92 : 120, color: kCard),
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCompactBannerContent(String name, num price, String? imageUrl, bool compact, VoidCallback? onTap) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: kCard),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
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
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Rs. ${price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onTap,
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
            onPressed: onAssistantPressed,
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

  Widget _buildCategoriesSection(BuildContext context, bool compact, List<Map<String, dynamic>> categories) {
    const dashboardCategories = [
      {'name': 'Fish'},
      {'name': 'Food'},
      {'name': 'Plants'},
      {'name': 'Decoration'},
      {'name': 'Equipment'},
    ];
    final cats = dashboardCategories;
    IconData iconFor(String name) {
      switch (name.toLowerCase()) {
        case 'fish':
          return Icons.set_meal;
        case 'food':
          return Icons.restaurant;
        case 'plants':
          return Icons.grass;
        case 'equipment':
          return Icons.settings;
        case 'decoration':
          return Icons.auto_awesome;
        default:
          return Icons.category;
      }
    }

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
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogueScreen()));
              },
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
          children: cats.map((cat) {
            final name = cat['name'] as String? ?? '';
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CatalogueScreen(initialCategory: name)));
              },
              child: Container(
                padding: EdgeInsets.all(compact ? 9 : 12),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Row(
                  children: [
                    Icon(iconFor(name), color: kAccent, size: compact ? 20 : 24),
                    SizedBox(width: compact ? 7 : 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpertsChoice(BuildContext context, bool compact, List<Map<String, dynamic>> products) {
    if (products.isEmpty) return const SizedBox();

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
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              final name = p['name'] as String? ?? '';
              final price = p['price'] as num? ?? 0;
              final images = p['images'] as List<dynamic>?;
              final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
              final fullImgUrl = ApiConstants.getFullImageUrl(imgUrl);

              return GestureDetector(
                onTap: () {
                  final pid = p['id'] as String?;
                  if (pid != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: pid)));
                  }
                },
                child: Container(
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
                              child: fullImgUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: fullImgUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: kCard, child: const Center(child: Icon(Icons.set_meal, color: Colors.white24, size: 40))),
                                      errorWidget: (_, __, ___) => Container(color: kCard, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white24, size: 40))),
                                    )
                                  : Container(color: kCard, child: const Center(child: Icon(Icons.set_meal, color: Colors.white24, size: 40))),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A3A5C),
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
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rs. ${price.toStringAsFixed(0)}',
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
                                  width: compact ? 24 : 28,
                                  height: compact ? 24 : 28,
                                  decoration: const BoxDecoration(
                                    color: kAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.add, color: Colors.white, size: 14),
                                    onPressed: () {
                                      final pid = p['id'] as String?;
                                      if (pid != null && context.mounted) {
                                        ProviderScope.containerOf(context).read(cartViewModelProvider.notifier).addToCart(pid);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF112240),
                                            content: Text('Added to cart', style: TextStyle(color: Colors.greenAccent)),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
