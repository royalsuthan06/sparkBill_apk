import 'product.dart';

class BilledItem {
  final Product product;
  int quantity;
  final double price;

  BilledItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get total => price * quantity;
}
