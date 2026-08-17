import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../widgets/add_product_sheet.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _priceSort = 'none'; // 'low_to_high', 'high_to_low', 'none'
  String _priceFilterRange = 'all'; // 'all', 'under_100', '100_500', 'over_500'

  final List<String> _categories = [
    'All Categories',
    'One Sound Crackers',
    'Ground Chakkars',
    'Spinner Chakkars',
    'Flower Pots',
    'Atom Bomb',
    'Paper Bomb',
    'Rockets',
    'Bijili Crackers',
    'Twinkling Star',
    'Pencils',
    'Fancy Novelties',
    'Fountain',
    'Kids Special',
    'Deluxe Crackers ( Big )',
    'Garland ( Half Count )',
    'Garland ( Full Count )',
    'Aerial Novelties ( Single Pipe )',
    'Fancy Repeating Shots',
    'Fancy Multi Shots',
    '7 CM Sparklers',
    '10 CM Sparklers',
    '12 CM Sparklers',
    '30 CM Sparklers',
    '50 CM Sparklers',
    'New Significant Varities',
    'Gift Box'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<POSProvider>();

    // Filter products based on search query, selected category & price range
    final filteredProducts = posProvider.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Categories' || p.category == _selectedCategory;
      
      bool matchesPrice = true;
      if (_priceFilterRange == 'under_100') {
        matchesPrice = p.price < 100;
      } else if (_priceFilterRange == '100_500') {
        matchesPrice = p.price >= 100 && p.price <= 500;
      } else if (_priceFilterRange == 'over_500') {
        matchesPrice = p.price > 500;
      }

      return matchesSearch && matchesCategory && matchesPrice;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredProducts.sort((a, b) {
        final aSku = a.sku.toLowerCase();
        final bSku = b.sku.toLowerCase();
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();

        if (aSku == q && bSku != q) return -1;
        if (bSku == q && aSku != q) return 1;
        if (aSku.startsWith(q) && !bSku.startsWith(q)) return -1;
        if (bSku.startsWith(q) && !aSku.startsWith(q)) return 1;
        if (aSku.contains(q) && !bSku.contains(q)) return -1;
        if (bSku.contains(q) && !aSku.contains(q)) return 1;
        if (aName.startsWith(q) && !bName.startsWith(q)) return -1;
        if (bName.startsWith(q) && !aName.startsWith(q)) return 1;

        return 0;
      });
    }

    if (_priceSort == 'low_to_high') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_priceSort == 'high_to_low') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6), // surface-container-low
      appBar: AppBar(
        title: Text(
          'Arun Crackers',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
            color: const Color(0xFFF43F5E), // primary rose
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              children: [
                // Search Input Field & Add Product Row
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          maxLength: 20,
                          style: GoogleFonts.workSans(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search SKU or Name...',
                            counterText: '',
                            prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add Product button
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) => const AddProductSheet(),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Categories Horizontal List scroll
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final isSelected = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFDC2C4F) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFF43F5E) : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tune Icon button with PopupMenu for filtering/sorting by price
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      onSelected: (String value) {
                        setState(() {
                          if (value == 'low_to_high' || value == 'high_to_low' || value == 'sort_none') {
                            _priceSort = value == 'sort_none' ? 'none' : value;
                          } else {
                            _priceFilterRange = value;
                          }
                        });
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Text(
                            'SORT BY PRICE',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'low_to_high',
                          checked: _priceSort == 'low_to_high',
                          child: Text('Price: Low to High', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'high_to_low',
                          checked: _priceSort == 'high_to_low',
                          child: Text('Price: High to Low', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'sort_none',
                          checked: _priceSort == 'none',
                          child: Text('No Sort (Default)', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Text(
                            'FILTER BY PRICE',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'all',
                          checked: _priceFilterRange == 'all',
                          child: Text('All Prices', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'under_100',
                          checked: _priceFilterRange == 'under_100',
                          child: Text('Under ₹100', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: '100_500',
                          checked: _priceFilterRange == '100_500',
                          child: Text('₹100 - ₹500', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                        CheckedPopupMenuItem<String>(
                          value: 'over_500',
                          checked: _priceFilterRange == 'over_500',
                          child: Text('Over ₹500', style: GoogleFonts.workSans(fontSize: 13)),
                        ),
                      ],
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: (_priceSort != 'none' || _priceFilterRange != 'all') 
                              ? const Color(0xFFF43F5E) 
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (_priceSort != 'none' || _priceFilterRange != 'all') 
                                ? const Color(0xFFF43F5E) 
                                : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Icon(
                          Icons.tune, 
                          size: 16, 
                          color: (_priceSort != 'none' || _priceFilterRange != 'all') 
                              ? Colors.white 
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Inventory List
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'No products found matching filters.',
                          style: GoogleFonts.workSans(color: const Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SKU, Product Name, Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.sku,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: GoogleFonts.workSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  product.category,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: const Color(0xFF515F74),
                  ),
                ),
              ],
            ),
          ),
          // Price & Delete Button Row
          Row(
            children: [
              Text(
                '₹${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                onPressed: () => _confirmDelete(context, product),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Product', style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to remove ${product.name} (${product.sku}) from inventory?',
            style: GoogleFonts.workSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.workSans(color: const Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                context.read<POSProvider>().removeProduct(product.sku);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted successfully.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              },
              child: Text('DELETE', style: GoogleFonts.workSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
