import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/domain/entities/category.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AllCategoriesView extends StatelessWidget {
  const AllCategoriesView({
    super.key,
    this.categories,
    required this.onCategoryTap,
    required this.onNavigationTap,
  });

  final List<Category>? categories;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<int> onNavigationTap;

  static const _categories = [
    _CategoryItem(AppStrings.electronics, Icons.desktop_windows_outlined),
    _CategoryItem(AppStrings.food, Icons.ramen_dining_outlined),
    _CategoryItem(AppStrings.fashion, Icons.diamond_outlined),
    _CategoryItem(AppStrings.furniture, Icons.chair_alt_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.logoTeal,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          AppStrings.categories,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPadding = 12.0;
          const itemSpacing = 4.0;
          final itemWidth =
              (constraints.maxWidth - horizontalPadding * 2 - itemSpacing * 3) /
              4;
          final tileSize = itemWidth.clamp(48.0, 60.0).toDouble();
          final apiCategories = categories;
          final itemCount = apiCategories?.length ?? _categories.length * 4;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: itemSpacing,
              mainAxisSpacing: 11,
              mainAxisExtent: 85,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (apiCategories != null) {
                final category = apiCategories[index];
                return Center(
                  child: CategoryCard(
                    name: category.title,
                    iconUrl: category.icon,
                    size: tileSize,
                    labelWidth: itemWidth,
                    onTap: () => onCategoryTap(category.title),
                  ),
                );
              }
              final category = _categories[index % _categories.length];
              return Center(
                child: CategoryCard(
                  name: category.name,
                  icon: Icon(
                    category.icon,
                    size: tileSize * 0.54,
                    color: AppColors.logoTeal,
                  ),
                  size: tileSize,
                  labelWidth: itemWidth,
                  onTap: () => onCategoryTap(category.name),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: onNavigationTap,
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem(this.name, this.icon);

  final String name;
  final IconData icon;
}
