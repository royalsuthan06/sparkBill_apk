import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/pos_provider.dart';
import '../models/bill.dart';
import '../widgets/invoice_dialog.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  String _activeFilter = 'Today';
  final List<String> _filters = ['Today', 'Yesterday', 'Last 7 Days', 'Custom'];
  DateTimeRange? _selectedDateRange;

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF43F5E), // primary rose
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF43F5E),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _selectedDateRange = range;
        _activeFilter = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final posProvider = context.watch<POSProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final timeFormat = DateFormat('HH:mm');

    // Filter bills based on date selection
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final last7DaysStart = todayStart.subtract(const Duration(days: 7));

    final filteredBills = posProvider.bills.where((bill) {
      if (_activeFilter == 'Today') {
        return bill.dateTime.isAfter(todayStart);
      } else if (_activeFilter == 'Yesterday') {
        return bill.dateTime.isAfter(yesterdayStart) && bill.dateTime.isBefore(todayStart);
      } else if (_activeFilter == 'Last 7 Days') {
        return bill.dateTime.isAfter(last7DaysStart);
      } else if (_activeFilter == 'Custom' && _selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59, 999);
        return bill.dateTime.isAfter(start.subtract(const Duration(microseconds: 1))) &&
               bill.dateTime.isBefore(end.add(const Duration(microseconds: 1)));
      }
      return true; // Fallback or Custom range
    }).toList();

    // Calculations for Summary Cards
    final double totalSalesSum = filteredBills.fold(0.0, (sum, bill) => sum + bill.grandTotal);
    final int totalBillsCount = filteredBills.length;

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
          // Summary Cards (High-end Bento Grid approach)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Total Sales Bento Card
                Expanded(
                  child: Container(
                    height: 96,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Sales',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          currencyFormat.format(totalSalesSum),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Total Bills Bento Card
                Expanded(
                  child: Container(
                    height: 96,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Bills',
                          style: GoogleFonts.workSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          totalBillsCount.toString(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips Horizontal Bar scrollable
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final bool isActive = filter == _activeFilter;

                String buttonText = filter;
                if (filter == 'Custom' && _selectedDateRange != null) {
                  final startStr = DateFormat('d MMM').format(_selectedDateRange!.start);
                  final endStr = DateFormat('d MMM').format(_selectedDateRange!.end);
                  buttonText = 'Custom ($startStr - $endStr)';
                }

                return GestureDetector(
                  onTap: () {
                    if (filter == 'Custom') {
                      _selectCustomDateRange();
                    } else {
                      setState(() {
                        _activeFilter = filter;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFF43F5E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? const Color(0xFFF43F5E) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.workSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Reports Inventory list of invoices
          Expanded(
            child: filteredBills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'No receipts logged for ${(_activeFilter == 'Custom' && _selectedDateRange != null) ? 'Custom (${DateFormat('d MMM').format(_selectedDateRange!.start)} - ${DateFormat('d MMM').format(_selectedDateRange!.end)})' : _activeFilter}.',
                          style: GoogleFonts.workSans(
                            color: const Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: filteredBills.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Invoice Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${bill.id}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${timeFormat.format(bill.dateTime)} • ${bill.totalItemCount} Items',
                                  style: GoogleFonts.workSans(
                                    fontSize: 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            // Actions & total price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${bill.grandTotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Export PDF Action
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFF43F5E), size: 18),
                                  onPressed: () {
                                    // Trigger Print view (reprint)
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return InvoiceDialog(bill: bill, isReprint: true);
                                      },
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                // Delete Action
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                                  onPressed: () => _confirmDelete(context, bill),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Void Sales Bill', style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete and void transaction #${bill.id} for ₹${bill.grandTotal.toStringAsFixed(0)}?',
            style: GoogleFonts.workSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.workSans(color: const Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                context.read<POSProvider>().deleteBill(bill.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bill #${bill.id} voided and removed from sales logs.'),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              },
              child: Text('VOID BILL', style: GoogleFonts.workSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
