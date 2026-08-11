class Product {
  final String sku;
  final String name;
  final String category;
  final double price;

  Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.price,
  });

  Product copyWith({
    String? sku,
    String? name,
    String? category,
    double? price,
  }) {
    return Product(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
    );
  }

  // Deserializes product from JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Serializes product to JSON map
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'price': price,
    };
  }
}
