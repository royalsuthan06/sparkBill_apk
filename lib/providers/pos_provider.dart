import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/billed_item.dart';
import '../models/bill.dart';
import '../data/initial_products.dart';

class POSProvider extends ChangeNotifier {
  static const String _kProductsKey = 'sparkbill_products';
  static const String _kBillsKey = 'sparkbill_bills';
  static const String _kBillCounterKey = 'sparkbill_bill_counter';

  // Inventory Lists
  final List<Product> _products = [];

  // Billed Invoices List
  final List<Bill> _bills = [];

  // Active Checkout state
  final List<BilledItem> _cart = [];
  String _customerPhone = '';
  String _customerName = '';

  // Sequential invoice number counter
  int _billCounter = 1;

  SharedPreferences? _prefs;

  // Getters
  List<Product> get products => List.unmodifiable(_products);
  List<BilledItem> get cart => List.unmodifiable(_cart);
  List<Bill> get bills => List.unmodifiable(_bills);
  String get customerPhone => _customerPhone;
  String get customerName => _customerName;

  int get subtotal => _cart.fold(0, (sum, item) => sum + item.total);
  int get discount => 0;
  int get grandTotal => subtotal;

  /// Loads persisted products/bills and seeds initial data on first run.
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      final productsJson = _prefs?.getString(_kProductsKey);
      if (productsJson != null && productsJson.isNotEmpty) {
        _products.addAll(_decodeProducts(productsJson));
      } else {
        _loadInitialProducts();
        _persistProducts();
      }

      final billsJson = _prefs?.getString(_kBillsKey);
      if (billsJson != null && billsJson.isNotEmpty) {
        _bills.addAll(_decodeBills(billsJson));
        _billCounter = _prefs?.getInt(_kBillCounterKey) ?? _fallbackBillCounter();
      } else {
        _initMockBills();
        _persistBills();
      }
    } catch (e) {
      debugPrint('Error loading persisted data: $e');
    }
    notifyListeners();
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

  List<Product> _decodeProducts(String jsonString) {
    try {
      final List decoded = json.decode(jsonString);
      return decoded
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error decoding products: $e');
      return [];
    }
  }

  List<Bill> _decodeBills(String jsonString) {
    try {
      final List decoded = json.decode(jsonString);
      return decoded
          .map((e) => Bill.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error decoding bills: $e');
      return [];
    }
  }

  void _persistProducts() {
    _prefs?.setString(
      _kProductsKey,
      json.encode(_products.map((p) => p.toJson()).toList()),
    );
  }

  void _persistBills() {
    _prefs?.setString(
      _kBillsKey,
      json.encode(_bills.map((b) => b.toJson()).toList()),
    );
  }

  void _persistBillCounter() {
    _prefs?.setInt(_kBillCounterKey, _billCounter);
  }

  int _fallbackBillCounter() {
    var maxSeq = 0;
    for (final b in _bills) {
      final seq = int.tryParse(b.id.replaceAll('BL-', ''));
      if (seq != null && seq > maxSeq) maxSeq = seq;
    }
    return maxSeq + 1;
  }

  String _nextBillId() {
    final id = 'BL-${_billCounter.toString().padLeft(6, '0')}';
    _billCounter++;
    _persistBillCounter();
    return id;
  }

  void _initMockBills() {
    final now = DateTime.now();
    if (_products.length < 10) return;

    // Bill 4092
    final item0 = _products[5]; // SKU: 006, Price: 55
    final item1 = _products[6]; // SKU: 007, Price: 70
    final item2 = _products[7]; // SKU: 008, Price: 35

    final int sub1 = (item0.pricePaise * 2) + item1.pricePaise + (item2.pricePaise * 3);
    _bills.add(Bill(
      id: _nextBillId(),
      customerPhone: '9876543210',
      customerName: 'Karthik Raja',
      dateTime: DateTime(now.year, now.month, now.day, 14, 32),
      items: [
        BilledItem(product: item0, quantity: 2, pricePaise: item0.pricePaise),
        BilledItem(product: item1, quantity: 1, pricePaise: item1.pricePaise),
        BilledItem(product: item2, quantity: 3, pricePaise: item2.pricePaise),
      ],
      subtotalPaise: sub1,
      discountPaise: 0,
      grandTotalPaise: sub1,
    ));

    // Bill 4091
    final item3 = _products[3]; // SKU: 004, Price: 38
    final item4 = _products[1]; // SKU: 002, Price: 15

    final int sub2 = (item3.pricePaise * 5) + (item4.pricePaise * 4);
    _bills.add(Bill(
      id: _nextBillId(),
      customerPhone: '9001234567',
      customerName: 'Suresh Kumar',
      dateTime: DateTime(now.year, now.month, now.day, 14, 15),
      items: [
        BilledItem(product: item3, quantity: 5, pricePaise: item3.pricePaise),
        BilledItem(product: item4, quantity: 4, pricePaise: item4.pricePaise),
      ],
      subtotalPaise: sub2,
      discountPaise: 0,
      grandTotalPaise: sub2,
    ));

    // Bill 4090
    final item5 = _products[1]; // SKU: 002, Price: 15
    final item6 = _products[0]; // SKU: 001, Price: 9

    final int sub3 = item5.pricePaise + item6.pricePaise;
    _bills.add(Bill(
      id: _nextBillId(),
      customerPhone: '9845012345',
      customerName: 'Anitha P',
      dateTime: DateTime(now.year, now.month, now.day, 13, 50),
      items: [
        BilledItem(product: item5, quantity: 1, pricePaise: item5.pricePaise),
        BilledItem(product: item6, quantity: 1, pricePaise: item6.pricePaise),
      ],
      subtotalPaise: sub3,
      discountPaise: 0,
      grandTotalPaise: sub3,
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
        pricePaise: product.pricePaise,
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
      subtotalPaise: subtotal,
      discountPaise: discount,
      grandTotalPaise: grandTotal,
    );
  }

  Bill confirmTransaction() {
    final bill = buildCurrentReceipt(_nextBillId());

    _bills.insert(0, bill); // Insert at beginning of reports
    _persistBills();
    clearCart();
    notifyListeners();
    return bill;
  }

  // Delete invoice
  void deleteBill(String id) {
    _bills.removeWhere((b) => b.id == id);
    _persistBills();
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
    _persistProducts();
    notifyListeners();
  }

  void removeProduct(String sku) {
    _products.removeWhere((p) => p.sku == sku);
    _persistProducts();
    notifyListeners();
  }
}
