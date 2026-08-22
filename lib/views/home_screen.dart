import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _views = [
    const BillingView(),
    const InventoryView(),
    const ReportsView(),
  ];

  final List<String> _labels = ['Billing', 'Inventory', 'Reports'];
  final List<IconData> _icons = [
    Icons.receipt_long,
    Icons.inventory_2,
    Icons.assessment,
  ];

  @override
  Widget build(BuildContext context) {
    final useRail = Responsive.useNavRail(context);

    if (useRail) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 24),
                ...List.generate(_labels.length, (index) {
                  final isActive = _currentIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: GestureDetector(
                      onTap: () => _pageController.jumpToPage(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive ? (isDark ? const Color(0xFF334155) : const Color(0xFFD5E3FC)) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isActive ? Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFB9C7DF), width: 1) : null,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _icons[index],
                              color: isActive ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0D1C2E)) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF515F74)),
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labels[index].toUpperCase(),
                              style: GoogleFonts.workSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: isActive ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0D1C2E)) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF515F74)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _views,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _views,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.transparent : const Color(0x0F000000), blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_labels.length, (index) {
            final isActive = _currentIndex == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? (isDark ? const Color(0xFF334155) : const Color(0xFFD5E3FC)) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isActive ? Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFB9C7DF), width: 1) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      color: isActive ? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0D1C2E)) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF515F74)),
                      size: 20,
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Text(
                        _labels[index].toUpperCase(),
                        style: GoogleFonts.workSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0D1C2E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
