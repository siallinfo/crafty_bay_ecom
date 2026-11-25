class CustomerOrder {
  final String id;
  final String status;
  final num total;
  final String paymentMethod;

  CustomerOrder({
    required this.id,
    required this.status,
    required this.total,
    required this.paymentMethod,
  });
}
