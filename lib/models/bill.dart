import 'billed_item.dart';

class Bill {
  final String id;
  final String customerPhone;
  final String customerName;
  final DateTime dateTime;
  final List<BilledItem> items;
  final double subtotal;
  final double discount;
  final double grandTotal;

  Bill({
    required this.id,
    required this.customerPhone,
    required this.customerName,
    required this.dateTime,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
