import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/presentation/core/product_grid_page.dart';
import 'package:flutter/material.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onNavigationTap,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int> onNavigationTap;

  @override
  Widget build(BuildContext context) {
    return ProductGridPage(
      title: AppStrings.wishList,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      selectedTabIndex: 3,
      onNavigationTap: onNavigationTap,
    );
  }
}
