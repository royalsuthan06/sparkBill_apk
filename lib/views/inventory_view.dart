import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../utils/money.dart';
import '../widgets/add_product_sheet.dart';
import '../screens/backup_settings_screen.dart';

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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final useGrid = screenWidth > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter products based on search query, selected category & price range
    final filteredProducts = posProvider.products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All Categories' || p.category == _selectedCategory;
      
      bool matchesPrice = true;
      if (_priceFilterRange == 'under_100') {
        matchesPrice = p.pricePaise < 10000;
      } else if (_priceFilterRange == '100_500') {
        matchesPrice = p.pricePaise >= 10000 && p.pricePaise <= 50000;
      } else if (_priceFilterRange == 'over_500') {
        matchesPrice = p.pricePaise > 50000;
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

        int compareSkus(String a, String b) {
          final numA = int.tryParse(a);
          final numB = int.tryParse(b);
          if (numA != null && numB != null) {
            return numA.compareTo(numB);
          }
          return a.compareTo(b);
        }

        if (aSku == q && bSku != q) return -1;
        if (bSku == q && aSku != q) return 1;
        if (aSku == q && bSku == q) return compareSkus(aSku, bSku);

        final aStarts = aSku.startsWith(q);
        final bStarts = bSku.startsWith(q);
        if (aStarts && !bStarts) return -1;
        if (bStarts && !aStarts) return 1;
        if (aStarts && bStarts) return compareSkus(aSku, bSku);

        final aContains = aSku.contains(q);
        final bContains = bSku.contains(q);
        if (aContains && !bContains) return -1;
        if (bContains && !aContains) return 1;
        if (aContains && bContains) return compareSkus(aSku, bSku);

        final aNameStarts = aName.startsWith(q);
        final bNameStarts = bName.startsWith(q);
        if (aNameStarts && !bNameStarts) return -1;
        if (bNameStarts && !aNameStarts) return 1;
        if (aNameStarts && bNameStarts) return compareSkus(aSku, bSku);

        return compareSkus(aSku, bSku);
      });
    }

    if (_priceSort == 'low_to_high') {
      filteredProducts.sort((a, b) => a.pricePaise.compareTo(b.pricePaise));
    } else if (_priceSort == 'high_to_low') {
      filteredProducts.sort((a, b) => b.pricePaise.compareTo(a.pricePaise));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFF43F5E)),
            tooltip: 'Backup & Restore Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackupSettingsScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Panel
          Container(
            color: Theme.of(context).colorScheme.surface,
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
                            fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
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
                                  color: isSelected ? const Color(0xFFDC2C4F) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFF43F5E) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: GoogleFonts.workSans(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                : useGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3.2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(context, filteredProducts[index]);
                        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  product.category,
                  style: GoogleFonts.workSans(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF515F74),
                  ),
                ),
              ],
            ),
          ),
          // Price & Delete Button Row
          Row(
            children: [
              Text(
                formatMoney(product.pricePaise),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
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
