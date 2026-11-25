import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:flutter/material.dart';

import 'app_bottom_nav_bar.dart';
import 'product_card.dart';

/// Reusable page that shows products in a 3-column grid under a titled
/// app bar with a back button.
///
/// Used for Wish List, product list by category, search results, etc.
/// The caller supplies the [title] and builds each cell (normally a
/// `ProductCard`) through [itemBuilder], so the page holds no data logic.
class ProductGridPage extends StatelessWidget {
  const ProductGridPage({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.selectedTabIndex,
    required this.onNavigationTap,
    this.crossAxisCount = 3,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int selectedTabIndex;
  final ValueChanged<int> onNavigationTap;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 12.0;
          const spacing = 12.0;
          final itemWidth =
              (constraints.maxWidth -
                  padding * 2 -
                  spacing * (crossAxisCount - 1)) /
              crossAxisCount;
          final scale = ProductCard.compactScaleForWidth(itemWidth);
          final itemHeight = itemWidth / 1.15 + 40 + (48.8 * scale) + 4;

          return GridView.builder(
            padding: const EdgeInsets.all(padding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: itemHeight,
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: selectedTabIndex,
        onTap: onNavigationTap,
      ),
    );
  }
}
