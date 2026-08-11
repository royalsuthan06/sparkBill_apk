import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/billed_item.dart';
import '../models/bill.dart';
import '../data/initial_products.dart';

class POSProvider extends ChangeNotifier {
  // Inventory Lists
  final List<Product> _products = [];

  // Billed Invoices List
  final List<Bill> _bills = [];

  // Active Checkout state
  final List<BilledItem> _cart = [];
  String _customerPhone = '';
  String _customerName = '';

  POSProvider() {
    _loadInitialProducts();
    _initMockBills();
  }

  void _loadInitialProducts() {
    try {
      final List decoded = json.decode(initialProductsJson);
      for (final item in decoded) {
        _products.add(Product.fromJson(item));
      }
    } catch (e) {
      debugPrint('Error loading initial products: $e');
    }
  }

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  List<BilledItem> get cart => List.unmodifiable(_cart);
  List<Bill> get bills => List.unmodifiable(_bills);
  String get customerPhone => _customerPhone;
  String get customerName => _customerName;

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.total);
  double get discount => 0.0;
  double get grandTotal => subtotal;

  void _initMockBills() {
    final now = DateTime.now();
    if (_products.length < 10) return;

    // Bill 4092
    final item0 = _products[5]; // SKU: 006, Price: 55
    final item1 = _products[6]; // SKU: 007, Price: 70
    final item2 = _products[7]; // SKU: 008, Price: 35

    final double sub1 = (item0.price * 2) + item1.price + (item2.price * 3);
    _bills.add(Bill(
      id: 'BL-4092',
      customerPhone: '9876543210',
      customerName: 'Karthik Raja',
      dateTime: DateTime(now.year, now.month, now.day, 14, 32),
      items: [
        BilledItem(product: item0, quantity: 2, price: item0.price),
        BilledItem(product: item1, quantity: 1, price: item1.price),
        BilledItem(product: item2, quantity: 3, price: item2.price),
      ],
      subtotal: sub1,
      discount: 0.0,
      grandTotal: sub1,
    ));

    // Bill 4091
    final item3 = _products[3]; // SKU: 004, Price: 38
    final item4 = _products[1]; // SKU: 002, Price: 15

    final double sub2 = (item3.price * 5) + (item4.price * 4);
    _bills.add(Bill(
      id: 'BL-4091',
      customerPhone: '9001234567',
      customerName: 'Suresh Kumar',
      dateTime: DateTime(now.year, now.month, now.day, 14, 15),
      items: [
        BilledItem(product: item3, quantity: 5, price: item3.price),
        BilledItem(product: item4, quantity: 4, price: item4.price),
      ],
      subtotal: sub2,
      discount: 0.0,
      grandTotal: sub2,
    ));

    // Bill 4090
    final item5 = _products[1]; // SKU: 002, Price: 15
    final item6 = _products[0]; // SKU: 001, Price: 9

    final double sub3 = item5.price + item6.price;
    _bills.add(Bill(
      id: 'BL-4090',
      customerPhone: '9845012345',
      customerName: 'Anitha P',
      dateTime: DateTime(now.year, now.month, now.day, 13, 50),
      items: [
        BilledItem(product: item5, quantity: 1, price: item5.price),
        BilledItem(product: item6, quantity: 1, price: item6.price),
      ],
      subtotal: sub3,
      discount: 0.0,
      grandTotal: sub3,
    ));
  }

  // Customer state setters
  void setCustomerPhone(String phone) {
    _customerPhone = phone;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  // Cart operations
  void addProductToCart(Product product, int quantity) {
    if (quantity <= 0) return;

    // Check if product already in cart
    final index = _cart.indexWhere((item) => item.product.sku == product.sku);
    if (index != -1) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(BilledItem(
        product: product,
        quantity: quantity,
        price: product.price,
      ));
    }
    notifyListeners();
  }

  void updateCartQty(String sku, int newQty) {
    final index = _cart.indexWhere((item) => item.product.sku == sku);
    if (index != -1) {
      if (newQty <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void removeProductFromCart(String sku) {
    _cart.removeWhere((item) => item.product.sku == sku);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _customerName = '';
    _customerPhone = '';
    notifyListeners();
  }

  // Finalize sale checkout
  Bill buildCurrentReceipt(String billId) {
    return Bill(
      id: billId,
      customerPhone: _customerPhone,
      customerName: _customerName.isEmpty ? 'Walk-in Customer' : _customerName,
      dateTime: DateTime.now(),
      items: List.from(_cart),
      subtotal: subtotal,
      discount: discount,
      grandTotal: grandTotal,
    );
  }

  Bill confirmTransaction() {
    final randomId = 'BL-${Random().nextInt(9000) + 1000}';
    final bill = buildCurrentReceipt(randomId);

    _bills.insert(0, bill); // Insert at beginning of reports
    clearCart();
    notifyListeners();
    return bill;
  }

  // Delete invoice
  void deleteBill(String id) {
    _bills.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  // Inventory Management
  void addNewProduct(Product product) {
    // Check if sku exists
    final index = _products.indexWhere((p) => p.sku.toUpperCase() == product.sku.toUpperCase());
    if (index != -1) {
      // Overwrite
      _products[index] = product;
    } else {
      _products.add(product);
    }
    notifyListeners();
  }

  void removeProduct(String sku) {
    _products.removeWhere((p) => p.sku == sku);
    notifyListeners();
  }
}
