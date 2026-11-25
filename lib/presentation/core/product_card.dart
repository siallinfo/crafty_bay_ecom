import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:flutter/material.dart';

/// Reusable product tile: image, title, price, rating and wishlist button.
///
/// Used by Home, Product list, Wishlist, etc. Receives all data and
/// callbacks via parameters — no provider access or hardcoded text.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.title,
    required this.price,
    this.rating,
    this.width,
    this.isWished = false,
    this.onTap,
    this.onWishTap,
  });

  final ImageProvider image;
  final String title;
  final String price;

  /// Hidden when null (the products API has no rating yet).
  final double? rating;

  /// Fixed width (e.g. in a horizontal list). Leave null inside a grid.
  final double? width;
  final bool isWished;
  final VoidCallback? onTap;
  final VoidCallback? onWishTap;

  static double compactScaleForWidth(double width) {
    if (width < 140) return 0.68;
    if (width < 160) return 0.75;
    if (width < 210) return 0.86;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = width ?? constraints.maxWidth;
        final scale = compactScaleForWidth(availableWidth);

        return Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: AppColors.border,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.15,
                    child: Container(
                      color: AppColors.primaryLight,
                      padding: EdgeInsets.all(14 * scale),
                      child: Image(image: image, fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      14 * scale,
                      12 * scale,
                      14 * scale,
                      12 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                            color: AppColors.icon,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      price,
                                      style: TextStyle(
                                        fontSize: 17 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.logoTeal,
                                      ),
                                    ),
                                    if (rating != null) ...[
                                      SizedBox(width: 10 * scale),
                                      Icon(
                                        Icons.star,
                                        size: 18 * scale,
                                        color: AppColors.accent,
                                      ),
                                      SizedBox(width: 3 * scale),
                                      Text(
                                        rating.toString(),
                                        style: TextStyle(
                                          fontSize: 14 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: InkWell(
                                  onTap: onWishTap,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    width: 28 * scale,
                                    height: 28 * scale,
                                    decoration: BoxDecoration(
                                      color: AppColors.logoTeal,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      isWished
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 19 * scale,
                                      color: AppColors.textOnPrimary,
                                    ),
                                  ),
                                ),
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
          ),
        );
      },
    );
  }
}
