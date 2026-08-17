class Product {
  final String sku;
  final String name;
  final String category;
  final int pricePaise;

  Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.pricePaise,
  });

  Product copyWith({
    String? sku,
    String? name,
    String? category,
    int? pricePaise,
  }) {
    return Product(
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePaise: pricePaise ?? this.pricePaise,
    );
  }

  // Deserializes product from JSON map (price stored in rupees, e.g. 9.5)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      pricePaise: (((json['price'] as num?)?.toDouble() ?? 0.0) * 100).round(),
    );
  }

  // Serializes product to JSON map (price in rupees)
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'name': name,
      'category': category,
      'price': pricePaise / 100,
    };
  }
}
