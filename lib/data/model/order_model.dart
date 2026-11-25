import '../../domain/entities/order.dart';

class OrderModel extends CustomerOrder {
  OrderModel({
    required super.id,
    required super.status,
    required super.total,
    required super.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final totalValue = json['total'] ?? json['total_amount'] ?? 0;
    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      total: totalValue is num
          ? totalValue
          : num.tryParse(totalValue.toString()) ?? 0,
      paymentMethod: (json['payment_method'] ?? '').toString(),
    );
  }
}
