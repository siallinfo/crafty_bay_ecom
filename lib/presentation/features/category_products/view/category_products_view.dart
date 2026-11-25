import 'package:crafty_bay_ecom/presentation/core/product_grid_page.dart';
import 'package:flutter/material.dart';

class CategoryProductsView extends StatelessWidget {
  const CategoryProductsView({
    super.key,
    required this.categoryName,
    required this.itemCount,
    required this.itemBuilder,
    required this.onNavigationTap,
  });

  final String categoryName;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int> onNavigationTap;

  @override
  Widget build(BuildContext context) {
    return ProductGridPage(
      title: categoryName,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      selectedTabIndex: 1,
      onNavigationTap: onNavigationTap,
    );
  }
}
