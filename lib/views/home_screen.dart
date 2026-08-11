import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'billing_view.dart';
import 'inventory_view.dart';
import 'reports_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const BillingView(),
    const InventoryView(),
    const ReportsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'Billing', Icons.receipt_long),
            _buildNavItem(1, 'Inventory', Icons.inventory_2),
            _buildNavItem(2, 'Reports', Icons.assessment),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final bool isActive = _currentIndex == index;
    final activeContainer = const Color(0xFFD5E3FC); // secondary-container (d5e3fc) from design keys
    final activeText = const Color(0xFF0D1C2E); // on-secondary-fixed (0d1c2e)
    final inactiveText = const Color(0xFF515F74); // secondary (515f74)

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? Border.all(color: const Color(0xFFB9C7DF), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? activeText : inactiveText,
              size: 20,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.workSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: activeText,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
