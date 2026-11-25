import 'package:crafty_bay_ecom/core/app_assets.dart';
import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/data/service/cart_service.dart';
import 'package:crafty_bay_ecom/data/service/product_service.dart';
import 'package:crafty_bay_ecom/data/service/wishlist_service.dart';
import 'package:crafty_bay_ecom/domain/entities/product_details.dart';
import 'package:crafty_bay_ecom/domain/entities/product.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_action_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_bar_button.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_bar_price.dart';
import 'package:crafty_bay_ecom/presentation/core/image_source.dart';
import 'package:crafty_bay_ecom/presentation/core/page_indicator.dart';
import 'package:crafty_bay_ecom/presentation/core/quantity_stepper.dart';
import 'package:crafty_bay_ecom/presentation/features/cart/view/cart_view.dart';
import 'package:crafty_bay_ecom/presentation/features/reviews/view/reviews_view.dart';
import 'package:flutter/material.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key, this.product});

  final Product? product;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  static const _colors = [
    AppColors.swatchBlack,
    AppColors.swatchBlue,
    AppColors.swatchBrown,
    AppColors.swatchGrey,
    AppColors.swatchDarkGrey,
  ];
  static const _sizes = ['S', 'M', 'L', 'XL'];

  int _currentImage = 0;
  int _quantity = 1;
  int _selectedColor = 1;
  int _selectedSize = 3;
  bool _isWished = false;
  bool _isAddingToCart = false;
  bool _isUpdatingWish = false;
  ProductDetails? _details;
  final _cartService = CartService();
  final _wishlistService = WishlistService();

  List<String> get _images {
    final remotePhotos = _details?.photos ?? const <String>[];
    final photos = remotePhotos.isNotEmpty
        ? remotePhotos
        : widget.product?.photos ?? const <String>[];
    final validPhotos = photos.where((photo) => photo.trim().isNotEmpty);
    final result = validPhotos.toList();
    return result.isEmpty ? [AppAssets.shoe] : result;
  }

  List<String> get _availableSizes {
    final sizes = _details?.sizes ?? const <String>[];
    return sizes.isEmpty ? _sizes : sizes;
  }

  String get _title {
    final remoteTitle = _details?.title;
    if (remoteTitle?.isNotEmpty == true) return remoteTitle!;
    final title = widget.product?.title;
    return title?.isNotEmpty == true ? title! : AppStrings.sampleProductTitle;
  }

  String get _description {
    final remoteDescription = _details?.description;
    if (remoteDescription?.isNotEmpty == true) return remoteDescription!;
    final description = widget.product?.description;
    return description?.isNotEmpty == true
        ? description!
        : AppStrings.sampleProductDescription;
  }

  String get _price {
    final amount =
        _details?.currentPrice ?? widget.product?.currentPrice ?? 1000;
    return '${AppStrings.currencySymbol}${amount.toStringAsFixed(0)}';
  }

  @override
  void initState() {
    super.initState();
    final productId = widget.product?.id;
    if (productId != null && productId.isNotEmpty) {
      _loadProductDetails(productId);
      _loadWishlistState(productId);
    }
  }

  Future<void> _loadProductDetails(String productId) async {
    try {
      final details = await ProductService().getProductDetails(productId);
      if (!mounted) return;
      setState(() {
        _details = details;
        _currentImage = 0;
        _selectedColor = 0;
        _selectedSize = 0;
      });
    } catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  Future<void> _loadWishlistState(String productId) async {
    if (!CacheService.isLoggedIn) return;
    try {
      final items = await _wishlistService.getWishlist();
      if (!mounted) return;
      setState(() {
        _isWished = items.any((item) => item.product.id == productId);
      });
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  Future<void> _addToCart() async {
    final product = widget.product;
    if (!CacheService.isLoggedIn) {
      _showError(Exception(AppStrings.loginRequired));
      return;
    }
    if (product == null || product.id.isEmpty) {
      _showError(Exception(AppStrings.cartActionUnavailable));
      return;
    }
    setState(() => _isAddingToCart = true);
    try {
      await _cartService.addToCart(
        productId: product.id,
        quantity: _quantity,
        color: _details?.colors.isNotEmpty == true
            ? _details!.colors[_selectedColor.clamp(0, _details!.colors.length - 1).toInt()]
            : null,
        size: _details?.sizes.isNotEmpty == true
            ? _details!.sizes[_selectedSize.clamp(0, _details!.sizes.length - 1).toInt()]
            : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.addedToCart)),
      );
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  Future<void> _toggleWish() async {
    final product = widget.product;
    if (!CacheService.isLoggedIn) {
      _showError(Exception(AppStrings.loginRequired));
      return;
    }
    if (product == null || product.id.isEmpty) return;
    setState(() => _isUpdatingWish = true);
    try {
      final items = await _wishlistService.getWishlist();
      final existing = items.where((item) => item.product.id == product.id);
      if (existing.isEmpty) {
        await _wishlistService.add(product.id);
      } else {
        await _wishlistService.remove(existing.first.id);
      }
      if (!mounted) return;
      setState(() => _isWished = existing.isEmpty);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isUpdatingWish = false);
    }
  }

  void _openReviews() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => ReviewsView(productId: widget.product?.id),
          ),
        );
  }

  void _handleNavigationTap(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const CartView()));
    } else {
      _showError(Exception(AppStrings.sectionUnavailable));
    }
  }

  Widget _buildProductImage(String path) {
    return Image(
      image: imageProviderFor(path),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Image.asset(AppAssets.shoe, fit: BoxFit.contain),
    );
  }

  Widget _buildColorOptions() {
    final remoteColors = _details?.colors ?? const <String>[];
    final colors = remoteColors.isEmpty ? null : remoteColors;
    final count = colors?.length ?? _colors.length;
    return Wrap(
      spacing: 10,
      children: List.generate(count, (index) {
        final selected = index == _selectedColor;
        final color = colors == null
            ? _colors[index]
            : _parseColor(colors[index]);
        return Semantics(
          button: true,
          label: '${AppStrings.color} ${index + 1}',
          selected: selected,
          child: InkWell(
            onTap: () => setState(() => _selectedColor = index),
            customBorder: const CircleBorder(),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppColors.logoTeal, width: 2)
                    : null,
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSizeOptions() {
    final sizes = _availableSizes;
    return Wrap(
      spacing: 8,
      children: List.generate(sizes.length, (index) {
        final selected = index == _selectedSize;
        return ChoiceChip(
          label: Text(sizes[index]),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) => setState(() => _selectedSize = index),
          labelStyle: TextStyle(
            fontSize: 11,
            color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.background,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          shape: const CircleBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }),
    );
  }

  Color _parseColor(String value) {
    final normalized = value.trim().toLowerCase();
    final hex = normalized.replaceFirst('#', '').replaceFirst('0x', '');
    if (hex.length == 6 || hex.length == 8) {
      final parsed = int.tryParse(hex, radix: 16);
      if (parsed != null) {
        return Color(hex.length == 6 ? 0xFF000000 | parsed : parsed);
      }
    }
    return switch (normalized) {
      'black' => AppColors.swatchBlack,
      'blue' => AppColors.swatchBlue,
      'brown' => AppColors.swatchBrown,
      'grey' || 'gray' => AppColors.swatchGrey,
      _ => AppColors.logoTeal,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.productDetails),
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (index) =>
                        setState(() => _currentImage = index),
                    itemBuilder: (context, index) => Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.all(24),
                      child: _buildProductImage(_images[index]),
                    ),
                  ),
                  if (_images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PageIndicator(
                        count: _images.length,
                        currentIndex: _currentImage,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                            color: AppColors.icon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      QuantityStepper(
                        quantity: _quantity,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _openReviews,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.logoTeal,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(AppStrings.reviews),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isUpdatingWish ? null : _toggleWish,
                        tooltip: AppStrings.wishList,
                        constraints: const BoxConstraints.tightFor(
                          width: 32,
                          height: 32,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isWished ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: AppColors.textOnPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.logoTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.color,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.icon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildColorOptions(),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.size,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.icon,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSizeOptions(),
                  const SizedBox(height: 14),
                  const Text(
                    AppStrings.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.icon,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomActionBar(
            leading: BottomBarPrice(label: AppStrings.price, value: _price),
            action: BottomBarButton(
              label: AppStrings.addToCart,
              onPressed: _isAddingToCart ? null : _addToCart,
              width: 126,
            ),
          ),
          AppBottomNavBar(currentIndex: 2, onTap: _handleNavigationTap),
        ],
      ),
    );
  }
}
