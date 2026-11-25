import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/service/review_service.dart';
import 'package:crafty_bay_ecom/domain/entities/product_review.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_action_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_bar_circle_button.dart';
import 'package:crafty_bay_ecom/presentation/features/create_review/view/create_review_view.dart';
import 'package:flutter/material.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({
    super.key,
    this.productId,
    this.loadReviews,
  });

  final String? productId;
  final Future<List<ProductReview>> Function(String productId)? loadReviews;

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  static const _sampleReviews = [
    AppStrings.sampleReview,
    AppStrings.sampleReview,
    AppStrings.sampleReview,
    AppStrings.sampleReview,
  ];

  List<ProductReview>? _reviews;
  Object? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadReviews();
  }

  Future<void> _loadReviews() async {
    final productId = widget.productId;
    if (productId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reviews = await (widget.loadReviews?.call(productId) ??
          ReviewService().getReviews(productId));
      if (!mounted) return;
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  Future<void> _openCreateReview(BuildContext context) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateReviewView(productId: widget.productId),
      ),
    );
    if (submitted == true) _loadReviews();
  }

  void _handleNavigationTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.sectionUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewCount = widget.productId == null
        ? AppStrings.reviewCount
        : (_reviews?.length.toString() ?? '0');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reviews),
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: _loadReviews,
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              itemCount: _reviews?.length ?? _sampleReviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final review = _reviews?[index];
                return _ReviewCard(
                  author: review?.author.isNotEmpty == true
                      ? review!.author
                      : AppStrings.sampleReviewerName,
                  review: review?.comment ?? _sampleReviews[index],
                  rating: review?.rating,
                );
              },
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomActionBar(
            leading: Text(
              '${AppStrings.reviews} ($reviewCount)',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            action: BottomBarCircleButton(
              onPressed: () => _openCreateReview(context),
            ),
          ),
          AppBottomNavBar(
            currentIndex: 2,
            onTap: (index) => _handleNavigationTap(context, index),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.review,
    this.rating,
  });

  final String author;
  final String review;
  final num? rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.iconInactive,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                author,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.icon,
                ),
              ),
              if (rating != null) ...[
                const Spacer(),
                const Icon(Icons.star, size: 14, color: AppColors.accent),
                Text(
                  rating.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: const TextStyle(
              fontSize: 11,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
