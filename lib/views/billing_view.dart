import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../widgets/stepper_input.dart';
import '../widgets/invoice_dialog.dart';

class BillingView extends StatefulWidget {
  const BillingView({super.key});

  @override
  State<BillingView> createState() => _BillingViewState();
}

class _BillingViewState extends State<BillingView> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Product? _selectedProduct;
  int _quantitySelected = 1;
  List<Product> _searchResults = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _phoneController.addListener(_onPhoneChanged);
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _phoneController.removeListener(_onPhoneChanged);
    _nameController.removeListener(_onNameChanged);
    _phoneController.dispose();
    _nameController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    context.read<POSProvider>().setCustomerPhone(_phoneController.text);
  }

  void _onNameChanged() {
    context.read<POSProvider>().setCustomerName(_nameController.text);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    final provider = context.read<POSProvider>();
    final matches = provider.products.where((product) {
      final nameMatch = product.name.toLowerCase().contains(query.toLowerCase());
      final skuMatch = product.sku.toLowerCase().contains(query.toLowerCase());
      return nameMatch || skuMatch;
    }).toList();

    matches.sort((a, b) {
      final q = query.toLowerCase();
      final aSku = a.sku.toLowerCase();
      final bSku = b.sku.toLowerCase();
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();

      // SKU exact match first
      if (aSku == q && bSku != q) return -1;
      if (bSku == q && aSku != q) return 1;

      // SKU starts-with match
      if (aSku.startsWith(q) && !bSku.startsWith(q)) return -1;
      if (bSku.startsWith(q) && !aSku.startsWith(q)) return 1;

      // SKU contains match
      if (aSku.contains(q) && !bSku.contains(q)) return -1;
      if (bSku.contains(q) && !aSku.contains(q)) return 1;

      // Name starts-with
      if (aName.startsWith(q) && !bName.startsWith(q)) return -1;
      if (bName.startsWith(q) && !aName.startsWith(q)) return 1;

      return 0;
    });

    setState(() {
      _searchResults = matches;
      _showSuggestions = matches.isNotEmpty;
    });
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _searchController.text = product.name;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
  }

  void _addItemToCart() {
    if (_selectedProduct == null) {
      // Try resolving directly from input if user typed full SKU
      final typedText = _searchController.text.trim().toUpperCase();
      final provider = context.read<POSProvider>();
      final directMatch = provider.products.firstWhere(
        (p) => p.sku.toUpperCase() == typedText || p.name.toUpperCase() == typedText.toUpperCase(),
        orElse: () => Product(sku: '', name: '', category: '', price: 0),
      );

      if (directMatch.sku.isNotEmpty) {
        _selectedProduct = directMatch;
      }
    }

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a valid product first.',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    context.read<POSProvider>().addProductToCart(_selectedProduct!, _quantitySelected);

    // Reset selectors
    setState(() {
      _selectedProduct = null;
      _searchController.clear();
      _quantitySelected = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<POSProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6), // surface-container-low
      appBar: AppBar(
        title: Text(
          'Arun Crackers',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
            color: const Color(0xFFB90538), // primary rose
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Customer Section (Compact)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    // Mobile Field
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Mobile No.',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                              borderSide: BorderSide(color: Color(0xFFB90538), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Name Field
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: GoogleFonts.workSans(fontSize: 13, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Customer Name',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                              borderSide: BorderSide(color: Color(0xFFB90538), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // SKU Entry Panel
              Container(
                color: const Color(0xFFF2F4F6),
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Search line
                      SizedBox(
                        height: 44,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            hintText: 'Search SKU or Item name...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFB90538), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Stepper + Add Button row
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: StepperInput(
                              value: _quantitySelected,
                              onChanged: (newQty) {
                                setState(() {
                                  _quantitySelected = newQty;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _addItemToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB90538),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'ADD ITEM',
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Billed List Headers
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        'ITEM',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'PRICE',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'QTY',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'TOTAL',
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 32), // space for delete action
                  ],
                ),
              ),

              // Billed Items High-Density List
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: posProvider.cart.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 48,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Cart is empty. Add products to start billing.',
                                style: GoogleFonts.workSans(
                                  color: const Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: posProvider.cart.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                            indent: 12,
                            endIndent: 12,
                          ),
                          itemBuilder: (context, index) {
                            final item = posProvider.cart[index];
                            final itemNo = (index + 1).toString().padLeft(2, '0');

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  // Number
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      itemNo,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  // Product Name
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      item.product.name,
                                      style: GoogleFonts.workSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Retail Price
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.price.toStringAsFixed(2),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  // Qty Stepper display or simple pill button
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E3E5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.quantity.toString(),
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Total Billed Price
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.total.toStringAsFixed(2),
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  // Delete Action
                                  SizedBox(
                                    width: 32,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                                      onPressed: () async {
                                        final bool? confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              title: Text(
                                                'Remove Item',
                                                style: GoogleFonts.workSans(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                              content: Text(
                                                'Are you sure you want to remove "${item.product.name}" from the cart?',
                                                style: GoogleFonts.workSans(
                                                  color: const Color(0xFF475569),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text(
                                                    'CANCEL',
                                                    style: GoogleFonts.workSans(
                                                      fontWeight: FontWeight.w600,
                                                      color: const Color(0xFF64748B),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFEF4444),
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'REMOVE',
                                                    style: GoogleFonts.workSans(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirmed == true) {
                                          posProvider.removeProductFromCart(item.product.sku);
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Bottom Calculations + Checkout Buttons
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtotal Line
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      color: const Color(0xFFFFFFFF),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal (${posProvider.cart.fold<int>(0, (sum, item) => sum + item.quantity)} items)',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            posProvider.subtotal.toStringAsFixed(2),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    // Grand Total Accordion Action Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFF8FAFC),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Total summary details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GRAND TOTAL',
                                  style: GoogleFonts.workSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF64748B),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currencyFormat.format(posProvider.grandTotal),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                           // CANCEL button
                           TextButton.icon(
                             onPressed: posProvider.cart.isEmpty
                                 ? null
                                 : () async {
                                     final bool? confirmed = await showDialog<bool>(
                                       context: context,
                                       builder: (BuildContext context) {
                                         return AlertDialog(
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(12),
                                           ),
                                           title: Text(
                                             'Clear Cart',
                                             style: GoogleFonts.workSans(
                                               fontWeight: FontWeight.bold,
                                               color: const Color(0xFF0F172A),
                                             ),
                                           ),
                                           content: Text(
                                             'Are you sure you want to clear all items in the cart?',
                                             style: GoogleFonts.workSans(
                                               color: const Color(0xFF475569),
                                             ),
                                           ),
                                           actions: [
                                             TextButton(
                                               onPressed: () => Navigator.pop(context, false),
                                               child: Text(
                                                 'NO',
                                                 style: GoogleFonts.workSans(
                                                   fontWeight: FontWeight.w600,
                                                   color: const Color(0xFF64748B),
                                                 ),
                                               ),
                                             ),
                                             ElevatedButton(
                                               onPressed: () => Navigator.pop(context, true),
                                               style: ElevatedButton.styleFrom(
                                                 backgroundColor: const Color(0xFFEF4444),
                                                 foregroundColor: Colors.white,
                                                 elevation: 0,
                                                 shape: RoundedRectangleBorder(
                                                   borderRadius: BorderRadius.circular(6),
                                                 ),
                                               ),
                                               child: Text(
                                                 'CLEAR ALL',
                                                 style: GoogleFonts.workSans(
                                                   fontWeight: FontWeight.bold,
                                                 ),
                                               ),
                                             ),
                                           ],
                                         );
                                       },
                                     );
                                     if (confirmed == true) {
                                       posProvider.clearCart();
                                       _phoneController.clear();
                                       _nameController.clear();
                                     }
                                   },
                             icon: const Icon(Icons.close, size: 16),
                             label: Text(
                               'CANCEL',
                               style: GoogleFonts.workSans(fontWeight: FontWeight.w600, fontSize: 13),
                             ),
                             style: TextButton.styleFrom(
                               foregroundColor: const Color(0xFF64748B),
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                               side: const BorderSide(color: Color(0xFFCBD5E1)),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                             ),
                           ),
                          const SizedBox(width: 8),
                          // CONFIRM button
                          ElevatedButton.icon(
                            onPressed: posProvider.cart.isEmpty
                                ? null
                                : () {
                                    // Confirm, deduction and receipt show
                                    final currentBill = posProvider.confirmTransaction();
                                    _phoneController.clear();
                                    _nameController.clear();

                                    // Show dialog with printable invoice mock
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return InvoiceDialog(bill: currentBill);
                                      },
                                    );
                                  },
                            icon: const Icon(Icons.print, size: 16),
                            label: Text(
                              'CONFIRM',
                              style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB90538),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Suggestion list overlays for SKU autocomplete search
          if (_showSuggestions && _searchResults.isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              top: 156, // Positioned right under the search input
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          item.name,
                          style: GoogleFonts.workSans(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        subtitle: Text(
                          '${item.sku} • ${item.category}',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: const Color(0xFF64748B)),
                        ),
                        trailing: Text(
                          '₹${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, color: const Color(0xFFB90538)),
                        ),
                        onTap: () => _selectProduct(item),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
