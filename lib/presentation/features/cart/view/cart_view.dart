import 'package:crafty_bay_ecom/core/app_assets.dart';
import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/data/service/cart_service.dart';
import 'package:crafty_bay_ecom/domain/entities/cart_item.dart';
import 'package:crafty_bay_ecom/presentation/core/app_bottom_nav_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_action_bar.dart';
import 'package:crafty_bay_ecom/presentation/core/bottom_bar_button.dart';
import 'package:crafty_bay_ecom/presentation/core/quantity_stepper.dart';
import 'package:crafty_bay_ecom/presentation/core/image_source.dart';
import 'package:crafty_bay_ecom/presentation/features/auth/login/view/login_view.dart';
import 'package:crafty_bay_ecom/presentation/features/payment/view/payment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartView extends StatefulWidget {
  const CartView({super.key, this.onNavigationTap, this.loadCart});

  final ValueChanged<int>? onNavigationTap;
  final Future<List<CartItem>> Function()? loadCart;

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final CartService _cartService = CartService();
  List<CartItem> _items = [];
  bool _isLoading = true;
  String? _error;

  num get _totalPrice =>
      _items.fold<num>(0, (total, item) => total + item.price * item.quantity);

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.loadCart == null && !CacheService.isLoggedIn) {
        throw Exception(AppStrings.loginRequired);
      }
      final items = await (widget.loadCart?.call() ?? _cartService.getCart());
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _formatPrice(num amount) =>
      '${AppStrings.currencySymbol}${amount.toStringAsFixed(2)}';

  void _openPayment() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentView(totalAmount: _totalPrice),
      ),
    );
  }

  Future<void> _changeQuantity(CartItem item, int quantity) async {
    try {
      if (widget.loadCart == null) {
        await _cartService.updateQuantity(item.id, quantity);
      }
      if (!mounted) return;
      setState(() {
        _items = [
          for (final current in _items)
            if (current.id == item.id)
              CartItem(
                id: current.id,
                productId: current.productId,
                title: current.title,
                photo: current.photo,
                price: current.price,
                quantity: quantity,
                color: current.color,
                size: current.size,
              )
            else
              current,
        ];
      });
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      if (widget.loadCart == null) {
        await _cartService.deleteItem(item.id);
      }
      if (!mounted) return;
      setState(() => _items.removeWhere((current) => current.id == item.id));
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  void _handleNavigationTap(int index) {
    final onNavigationTap = widget.onNavigationTap;
    if (onNavigationTap != null) {
      onNavigationTap(index);
    } else if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index != 2) {
      Navigator.of(context).maybePop();
    }
  }

  Widget _buildCartItem(int index) {
    final item = _items[index];
    final image = item.photo.isEmpty ? AppAssets.shoe : item.photo;
    final options = [
      if (item.color.isNotEmpty) 'Color: ${item.color}',
      if (item.size.isNotEmpty) 'Size: ${item.size}',
    ].join(', ');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppColors.cardBackground,
      elevation: 1,
      shadowColor: AppColors.border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.primaryLight),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: [
            SizedBox(
              width: 82,
              height: 74,
              child: Image(
                image: imageProviderFor(image),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Image.asset(AppAssets.shoe, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.icon,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeItem(item),
                        tooltip: 'Remove item',
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.iconInactive,
                        iconSize: 18,
                        constraints: const BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  if (options.isNotEmpty)
                    Text(
                      options,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${AppStrings.currencySymbol}${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.logoTeal,
                        ),
                      ),
                      const Spacer(),
                      QuantityStepper(
                        quantity: item.quantity,
                        onChanged: (quantity) =>
                            _changeQuantity(item, quantity),
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
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size: 52,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.cartEmpty,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(AppStrings.home),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.totalPrice,
          style: TextStyle(fontSize: 10, color: AppColors.icon),
        ),
        const SizedBox(height: 3),
        Text(
          _formatPrice(_totalPrice),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.logoTeal,
          ),
        ),
      ],
    );
  }

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
        title: const Text(AppStrings.cart),
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
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    if (_error == AppStrings.loginRequired)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginView(),
                          ),
                        ),
                        child: const Text(AppStrings.login),
                      )
                    else
                      TextButton(
                        onPressed: _loadCart,
                        child: const Text(AppStrings.retry),
                      ),
                  ],
                ),
              ),
            )
          : _items.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              itemCount: _items.length,
              itemBuilder: (_, index) => _buildCartItem(index),
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomActionBar(
            leading: _buildTotalPrice(),
            action: BottomBarButton(
              label: AppStrings.checkout,
              width: 108,
              onPressed: _items.isEmpty ? null : _openPayment,
            ),
          ),
          AppBottomNavBar(currentIndex: 2, onTap: _handleNavigationTap),
        ],
      ),
    );
  }
}

