import 'product.dart';

class BilledItem {
  final Product product;
  int quantity;
  final int pricePaise;

  BilledItem({
    required this.product,
    required this.quantity,
    required this.pricePaise,
  });

  int get total => pricePaise * quantity;

  factory BilledItem.fromJson(Map<String, dynamic> json) {
    return BilledItem(
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      pricePaise: (json['pricePaise'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'pricePaise': pricePaise,
    };
  }
}
