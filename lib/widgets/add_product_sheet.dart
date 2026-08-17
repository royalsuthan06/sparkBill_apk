import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../providers/pos_provider.dart';

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'One Sound Crackers';
  final List<String> _categories = [
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
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFF43F5E);

    return Padding(
      // Ensure the keyboard doesn't cover input fields
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator bar
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEEF0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Sheet title
              Text(
                'Add Inventory Product',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // SKU Input
              TextFormField(
                controller: _skuController,
                maxLength: 20,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'SKU Code',
                  hintText: 'e.g. 152',
                  counterText: '',
                  prefixIcon: const Icon(Icons.qr_code, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'SKU code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Name Input
              TextFormField(
                controller: _nameController,
                maxLength: 50,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  hintText: 'e.g. 7 HILLS (60 ITEM BOX)',
                  counterText: '',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Product name is required' : null,
              ),
              const SizedBox(height: 12),
              // Category Dropdown Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: GoogleFonts.workSans(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Price Input
              TextFormField(
                controller: _priceController,
                maxLength: 10,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Price (₹)',
                  counterText: '',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SAVE PRODUCT',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        sku: _skuController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
      );

      // Add to inventory
      context.read<POSProvider>().addNewProduct(newProduct);

      // Close bottom sheet
      Navigator.pop(context);

      // Show success toast/snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${newProduct.name} successfully added to inventory.',
            style: GoogleFonts.workSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF006947), // Tertiary green
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
