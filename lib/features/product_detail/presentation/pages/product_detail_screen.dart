import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/review/presentation/state/review_state.dart';
import 'package:aqua_life/features/review/presentation/view_model/review_view_model.dart';
import 'package:aqua_life/features/review/domain/entities/review_model.dart';
import 'package:aqua_life/features/home/presentation/view_model/home_view_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewViewModelProvider.notifier).loadReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewViewModelProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final product = _productData;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Product Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(product, compact),
            SizedBox(height: compact ? 12 : 16),
            _buildProductInfo(product, compact),
            SizedBox(height: compact ? 14 : 18),
            _buildReviewsHeader(state, compact),
            SizedBox(height: compact ? 8 : 10),
            if (state.isLoading && state.summary.reviews.isEmpty)
              const Center(child: CircularProgressIndicator(color: kAccent))
            else if (state.error != null)
              Center(child: Text('Failed to load reviews', style: TextStyle(color: Colors.white54)))
            else if (state.summary.reviews.isEmpty)
              _buildNoReviews(compact)
            else
              _buildReviewsList(state.summary.reviews, compact),
            SizedBox(height: compact ? 14 : 18),
            _buildReviewForm(state, compact),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> get _productData {
    final homeState = ref.read(homeViewModelProvider);
    final allProducts = [
      ...homeState.bannerProduct != null ? [homeState.bannerProduct!] : [],
      ...homeState.spotlightProducts,
    ];
    final match = allProducts.firstWhere(
      (p) => p['id'] == widget.productId,
      orElse: () => {},
    );
    return match;
  }

  Widget _buildProductImage(Map<String, dynamic> product, bool compact) {
    final images = product['images'] as List<dynamic>?;
    final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
    final fullImgUrl = imgUrl != null ? '${ApiEndpoints.baseUrl}$imgUrl' : null;

    return Container(
      width: double.infinity,
      height: compact ? 200 : 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: fullImgUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: fullImgUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: kCard, child: Center(child: Icon(Icons.image, color: kAccent, size: compact ? 40 : 48))),
                errorWidget: (_, __, ___) => Container(color: kCard, child: Center(child: Icon(Icons.image_not_supported, color: kSub, size: compact ? 40 : 48))),
              ),
            )
          : Container(
              color: kCard,
              child: Center(child: Icon(Icons.image, color: kAccent, size: compact ? 40 : 48)),
            ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> product, bool compact) {
    final name = product['name'] as String? ?? 'Product';
    final price = product['price'] as num? ?? 0;
    final description = product['description'] as String? ?? '';
    final category = product['category'] as String? ?? '';
    final stock = product['stock'] as int? ?? 0;
    final isSoldOut = product['isSoldOut'] as bool? ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: compact ? 18 : 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: compact ? 6 : 8),
        Row(
          children: [
            Text(
              'Rs. ${price.toStringAsFixed(0)}',
              style: TextStyle(color: kAccent, fontSize: compact ? 16 : 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            if (isSoldOut)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text('Sold Out', style: TextStyle(color: Colors.white, fontSize: compact ? 10 : 11, fontWeight: FontWeight.bold)),
              )
            else if (stock <= 5)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                child: Text('Only $stock left', style: TextStyle(color: Colors.white, fontSize: compact ? 10 : 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        SizedBox(height: compact ? 6 : 8),
        if (category.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: kMid, borderRadius: BorderRadius.circular(20)),
            child: Text(category, style: TextStyle(color: kAccent, fontSize: compact ? 11 : 12, fontWeight: FontWeight.w600)),
          ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          description,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: kSub, fontSize: compact ? 12 : 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildReviewsHeader(ReviewState state, bool compact) {
    return Row(
      children: [
        _buildStarRating(state.summary.averageRating),
        SizedBox(width: compact ? 6 : 8),
        Text(
          '${state.summary.averageRating.toStringAsFixed(1)}',
          style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '(${state.summary.total} review${state.summary.total != 1 ? 's' : ''})',
          style: TextStyle(color: kSub, fontSize: compact ? 11 : 12),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
          color: filled ? Colors.amber : kSub,
          size: 16,
        );
      }),
    );
  }

  Widget _buildNoReviews(bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 16 : 20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, color: kAccent, size: compact ? 32 : 40),
          SizedBox(height: compact ? 6 : 8),
          Text('No reviews yet', style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 15, fontWeight: FontWeight.w600)),
          SizedBox(height: compact ? 2 : 4),
          Text('Be the first to review this product!', style: TextStyle(color: kSub, fontSize: compact ? 11 : 12)),
        ],
      ),
    );
  }

  Widget _buildReviewsList(List<ReviewModel> reviews, bool compact) {
    return Column(
      children: reviews.map((review) {
        return Container(
          margin: EdgeInsets.only(bottom: compact ? 8 : 10),
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: compact ? 12 : 14,
                        backgroundColor: kMid,
                        child: Text(
                          review.firstName.isNotEmpty ? review.firstName[0] : '?',
                          style: TextStyle(color: Colors.white, fontSize: compact ? 10 : 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: compact ? 6 : 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.fullName, style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 13, fontWeight: FontWeight.w600)),
                          Text(
                            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                            style: TextStyle(color: kSub, fontSize: compact ? 10 : 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStarRating(review.rating.toDouble()),
                ],
              ),
              if (review.comment != null && review.comment!.isNotEmpty) ...[
                SizedBox(height: compact ? 6 : 8),
                Text(
                  review.comment!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kSub, fontSize: compact ? 11 : 13, height: 1.4),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewForm(ReviewState state, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: TextStyle(color: Colors.white, fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: compact ? 8 : 10),
            _buildStarSelector(compact),
            SizedBox(height: compact ? 8 : 10),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 14),
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                hintStyle: TextStyle(color: kSub, fontSize: compact ? 12 : 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: kInput,
                contentPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: compact ? 10 : 12),
              ),
              validator: (value) {
                if (_selectedRating == 0) return 'Please select a rating';
                return null;
              },
            ),
            SizedBox(height: compact ? 10 : 12),
            if (state.submitError != null)
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 6 : 8),
                child: Text(state.submitError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            SizedBox(
              width: double.infinity,
              height: compact ? 42 : 48,
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _submitReview();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Submit Review', style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarSelector(bool compact) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            i < _selectedRating ? Icons.star : Icons.star_border,
            color: i < _selectedRating ? Colors.amber : kSub,
            size: compact ? 24 : 28,
          ),
          onPressed: () {
            setState(() => _selectedRating = i + 1);
          },
        );
      }),
    );
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    final success = await ref.read(reviewViewModelProvider.notifier).submitReview(widget.productId, _selectedRating, comment);
    if (success && mounted) {
      _commentController.clear();
      setState(() => _selectedRating = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF112240),
          content: Text('Review submitted!', style: TextStyle(color: Colors.greenAccent)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
