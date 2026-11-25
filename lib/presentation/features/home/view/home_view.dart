import 'package:crafty_bay_ecom/core/app_assets.dart';
import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/data/service/category_service.dart';
import 'package:crafty_bay_ecom/data/service/product_service.dart';
import 'package:crafty_bay_ecom/data/service/slide_service.dart';
import 'package:crafty_bay_ecom/data/service/wishlist_service.dart';
import 'package:crafty_bay_ecom/domain/entities/category.dart';
import 'package:crafty_bay_ecom/domain/entities/cart_item.dart';
import 'package:crafty_bay_ecom/domain/entities/product.dart';
import 'package:crafty_bay_ecom/domain/entities/slide.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/category_card.dart';
import 'package:crafty_bay_ecom/presentation/core/page_indicator.dart';
import 'package:crafty_bay_ecom/presentation/core/product_card.dart';
import 'package:crafty_bay_ecom/presentation/core/image_source.dart';
import 'package:crafty_bay_ecom/presentation/core/product_section.dart';
import 'package:crafty_bay_ecom/presentation/core/section_header.dart';
import 'package:crafty_bay_ecom/presentation/features/category_products/view/category_products_view.dart';
import 'package:crafty_bay_ecom/presentation/features/cart/view/cart_view.dart';
import 'package:crafty_bay_ecom/presentation/features/categories/view/all_categories_view.dart';
import 'package:crafty_bay_ecom/presentation/features/product_details/view/product_details_view.dart';
import 'package:crafty_bay_ecom/presentation/features/profile/view/profile_view.dart';
import 'package:crafty_bay_ecom/presentation/features/wishlist/view/wishlist_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key, this.loadData, this.loadCart});

  final Future<HomeData> Function()? loadData;
  final Future<List<CartItem>> Function()? loadCart;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _wishedProducts = {};
  final WishlistService _wishlistService = WishlistService();
  late Future<HomeData> _dataFuture;
  HomeData? _loadedData;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _dataFuture = widget.loadData?.call() ?? _loadHomeData();
  }

  Future<HomeData> _loadHomeData() async {
    final results = await Future.wait<dynamic>([
      CategoryService().getCategories(),
      ProductService().getProducts(),
      SlideService().getSlides(),
    ]);
    return HomeData(
      categories: results[0] as List<Category>,
      products: results[1] as List<Product>,
      slides: results[2] as List<Slide>,
    );
  }

  List<Product> _visibleProducts(List<Product> products) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return products;
    return products
        .where((product) => product.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.sectionUnavailable)),
    );
  }

  void _openProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const ProfileView()));
  }

  void _openProductList(String title, List<Product> products) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryProductsView(
          categoryName: title,
          itemCount: products.length,
          itemBuilder: (context, index) => _buildProductCard(products[index]),
          onNavigationTap: (index) {
            if (index == 1) {
              Navigator.of(context).pop();
            } else {
              _handleNavigationTap(index);
            }
          },
        ),
      ),
    );
  }

  void _openAllCategories() {
    final data = _loadedData;
    if (data == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AllCategoriesView(
          categories: data.categories,
          onCategoryTap: (categoryName) => _openProductList(
            categoryName,
            _productsForCategory(data, categoryName),
          ),
          onNavigationTap: (index) {
            if (index == 1) return;
            Navigator.of(context).pop();
            _handleNavigationTap(index);
          },
        ),
      ),
    );
  }

  List<Product> _productsForCategory(HomeData data, String categoryName) {
    final matches = data.categories
        .where((item) => item.title == categoryName)
        .toList();
    final category = matches.isEmpty ? null : matches.first;
    if (category == null) return data.products;
    return data.products
        .where((product) => product.categoryIds.contains(category.id))
        .toList();
  }

  void _openProductDetails(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsView(product: product),
      ),
    );
  }

  void _handleNavigationTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
      case 1:
        _openAllCategories();
      case 2:
        _openCart();
      case 3:
        _openWishlist();
    }
  }

  Future<void> _openWishlist() async {
    if (!CacheService.isLoggedIn) {
      _showError(Exception(AppStrings.loginRequired));
      return;
    }
    try {
      final items = await _wishlistService.getWishlist();
      if (!mounted) return;
      setState(() {
        _wishedProducts
          ..clear()
          ..addAll(items.map((item) => item.product.id));
      });
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WishlistView(
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _buildProductCard(items[index].product),
            onNavigationTap: (index) {
              if (index == 3) {
                Navigator.of(context).pop();
              } else {
                _handleNavigationTap(index);
              }
            },
          ),
        ),
      );
    } catch (error) {
      _showError(error);
    }
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CartView(
          loadCart: widget.loadCart,
          onNavigationTap: (index) {
            if (index == 2) return;
            Navigator.of(context).pop();
            _handleNavigationTap(index);
          },
        ),
      ),
    );
  }

  Future<void> _toggleWish(Product product) async {
    if (!CacheService.isLoggedIn) {
      _showError(Exception(AppStrings.loginRequired));
      return;
    }
    try {
      final items = await _wishlistService.getWishlist();
      final existing = items.where((item) => item.product.id == product.id);
      if (existing.isEmpty) {
        await _wishlistService.add(product.id);
      } else {
        await _wishlistService.remove(existing.first.id);
      }
      if (!mounted) return;
      setState(() {
        if (existing.isEmpty) {
          _wishedProducts.add(product.id);
        } else {
          _wishedProducts.remove(product.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing.isEmpty
                ? AppStrings.addedToWishlist
                : AppStrings.removedFromWishlist,
          ),
        ),
      );
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Widget _buildProductCard(Product product) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 32 - 24) / 3;
    final photo = product.photos.isEmpty
        ? AppAssets.shoe
        : product.photos.first;
    return ProductCard(
      image: imageProviderFor(photo),
      title: product.title,
      price: '${AppStrings.currencySymbol}${product.currentPrice}',
      rating: null,
      width: cardWidth,
      isWished: _wishedProducts.contains(product.id),
      onTap: () => _openProductDetails(product),
      onWishTap: () => _toggleWish(product),
    );
  }

  Widget _buildCategoryRow(List<Category> categories) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final visibleCategories = categories.take(4).toList();
    if (visibleCategories.isEmpty) return const SizedBox.shrink();
    final cellWidth = (screenWidth - 24) / visibleCategories.length;
    final tileSize = CategoryCard.tileSize(context)
        .clamp(48.0, 60.0)
        .toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final category in visibleCategories)
            SizedBox(
              width: cellWidth,
              child: Center(
                child: CategoryCard(
                  name: category.title,
                  iconUrl: category.icon,
                  size: tileSize,
                  labelWidth: cellWidth,
                  onTap: () => _openProductList(
                    category.title,
                    _productsForCategory(_loadedData!, category.title),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductSection(String title, List<Product> allProducts) {
    final products = _visibleProducts(allProducts);
    return ProductSection(
      title: title,
      itemCount: products.length,
      onSeeAllTap: () => _openProductList(title, products),
      itemBuilder: (context, index) => _buildProductCard(products[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HomeData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retryLoad,
                      child: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        _loadedData = data;
        return _buildHome(data);
      },
    );
  }

  void _retryLoad() {
    setState(() {
      _loadedData = null;
      _dataFuture = widget.loadData?.call() ?? _loadHomeData();
    });
  }

  Widget _buildHome(HomeData data) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.logoTeal,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildSearchField()),
              SliverToBoxAdapter(child: _buildPromoBanner(data.slides)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: PageIndicator(
                    count: data.slides.isEmpty ? 1 : data.slides.length,
                    currentIndex: _currentSlide,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: SectionHeader(
                    title: AppStrings.allCategories,
                    onSeeAllTap: _openAllCategories,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildCategoryRow(data.categories)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _buildProductSection(
                    AppStrings.popularProducts,
                    data.products,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildProductSection(
                  AppStrings.specialProducts,
                  data.products,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildProductSection(
                  AppStrings.newProducts,
                  data.products,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 0,
          onTap: _handleNavigationTap,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final scale = (MediaQuery.sizeOf(context).width / 393)
        .clamp(0.9, 1.15)
        .toDouble();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12 * scale,
        4 * scale,
        12 * scale,
        10 * scale,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AppAssets.logoNav,
            width: 100 * scale,
            height: 27 * scale,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Profile',
            scale: scale,
            onPressed: _openProfile,
          ),
          SizedBox(width: 8 * scale),
          _buildActionButton(
            icon: Icons.call_outlined,
            label: 'Contact',
            scale: scale,
            onPressed: _showUnavailableMessage,
          ),
          SizedBox(width: 8 * scale),
          _buildActionButton(
            icon: Icons.notifications_none_outlined,
            label: 'Notifications',
            scale: scale,
            onPressed: _showUnavailableMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required double scale,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 36 * scale,
        height: 36 * scale,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          iconSize: 20 * scale,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.icon,
          ),
          icon: Icon(icon),
          tooltip: label,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 34,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppStrings.search,
            prefixIcon: const Icon(Icons.search, size: 18),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 34,
              minHeight: 34,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(List<Slide> slides) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          height: 108,
          child: slides.isEmpty
              ? _buildBannerPage(AppStrings.bannerTitle, null)
              : PageView.builder(
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentSlide = index);
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return _buildBannerPage(slide.description, slide.photoUrl);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildBannerPage(String title, String? imageUrl) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: imageUrl == null || imageUrl.isEmpty
                ? Image.asset(
                    AppAssets.shoe,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.shopping_bag_outlined,
                      size: 54,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.shopping_bag_outlined,
                      size: 54,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 78,
                  height: 22,
                  child: ElevatedButton(
                    onPressed: _showUnavailableMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.logoTeal,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      AppStrings.buyNow,
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeData {
  const HomeData({
    required this.categories,
    required this.products,
    required this.slides,
  });

  final List<Category> categories;
  final List<Product> products;
  final List<Slide> slides;
}
