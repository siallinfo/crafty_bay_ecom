import 'package:crafty_bay_ecom/core/app_colors.dart';
import 'package:crafty_bay_ecom/core/app_strings.dart';
import 'package:crafty_bay_ecom/data/service/cache/cache_service.dart';
import 'package:crafty_bay_ecom/data/service/order_service.dart';
import 'package:flutter/material.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key, required this.totalAmount});

  final num totalAmount;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _orderService = OrderService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!CacheService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginRequired)),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      final response = await _orderService.createOrder(
        paymentMethod: 'cod',
        shippingAddress: _addressController.text.trim(),
      );
      if (!mounted) return;
      final data = response['data'];
      final message = response['msg']?.toString() ??
          (data is Map ? data['msg']?.toString() : null) ??
          'Order placed successfully';
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order placed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.payment)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.totalPrice,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppStrings.currencySymbol}${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.logoTeal,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            const Text(
              'Shipping address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: AppStrings.shippingAddress,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? AppStrings.fieldRequired
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payments_outlined, color: AppColors.logoTeal),
              title: Text(AppStrings.cashOnDelivery),
              subtitle: Text('Pay when your order arrives'),
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.onlinePaymentUnavailable,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _placeOrder,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : const Text(AppStrings.placeOrder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
