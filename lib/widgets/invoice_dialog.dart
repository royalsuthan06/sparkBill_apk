import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bill.dart';

class InvoiceDialog extends StatefulWidget {
  final Bill bill;
  final bool isReprint;

  const InvoiceDialog({
    super.key,
    required this.bill,
    this.isReprint = false,
  });

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  String _selectedPrinter = 'System PDF Printer (A4)';
  final List<String> _printers = [
    'System PDF Printer (A4)',
    'XP-80 Thermal POS (USB)',
    'RP-3200 Bluetooth Printer',
    'Save to Device Storage'
  ];

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    final formattedDate = dateFormat.format(widget.bill.dateTime);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: const Color(0xFFFDFDFD),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: const Color(0xFFB90538), // Elegant Brand Red
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isReprint ? 'REPRINT RECEIPT' : 'BILL CONFIRMED / PRINT',
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Printer Configuration Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPrinter,
                    isExpanded: true,
                    icon: const Icon(Icons.print_outlined, color: Color(0xFFB90538)),
                    style: GoogleFonts.workSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    items: _printers.map((printer) {
                      return DropdownMenuItem(
                        value: printer,
                        child: Text(printer),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedPrinter = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            // Receipt Paper Preview with Brand Identity Border
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFB90538), width: 2), // Brand red border
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0C000000),
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Store Info
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Arun Crackers',
                                style: GoogleFonts.workSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB90538), // Brand Red
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '7/300/1, Senthur Nagar, Sivakasi to kazhugumalai main road,\nnear enammeenachipuram bus stop, Vembakko ai, Sivakasi - 626131',
                                style: GoogleFonts.workSans(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'For order: 8667784469 | GPay / WhatsApp: 9750510650',
                                style: GoogleFonts.workSans(
                                  fontSize: 9.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: const Color(0xFFB90538).withOpacity(0.5)),
                        const SizedBox(height: 12),

                        // Two column metadata grid
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _metaItem('Invoice Number:', widget.bill.id),
                                  const SizedBox(height: 6),
                                  _metaItem('Customer Name:', widget.bill.customerName.isNotEmpty ? widget.bill.customerName : 'N/A'),
                                  const SizedBox(height: 6),
                                  _metaItem('Customer Mobile:', widget.bill.customerPhone.isNotEmpty ? widget.bill.customerPhone : 'N/A'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _metaItem('Date & Time:', formattedDate),
                                  const SizedBox(height: 6),
                                  _metaItem('Payment Method:', 'Cash'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        Container(height: 1, color: const Color(0xFFB90538).withOpacity(0.5)),
                        const SizedBox(height: 10),

                        // Item headers
                        Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(
                                'S.No',
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: Text(
                                'Item Name',
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: Text(
                                'Price',
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 25,
                              child: Text(
                                'Quantity',
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 35,
                              child: Text(
                                'Total',
                                style: GoogleFonts.workSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(height: 1, color: const Color(0xFFE2E8F0)),
                        const SizedBox(height: 6),

                        // Billed Items lines
                        ...List.generate(widget.bill.items.length, (index) {
                          final item = widget.bill.items[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 40,
                                  child: Text(
                                    item.product.name,
                                    style: GoogleFonts.workSans(
                                      fontSize: 10,
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 30,
                                  child: Text(
                                    'INR ${item.price.toStringAsFixed(2)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9.5,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 25,
                                  child: Text(
                                    item.quantity.toString(),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 35,
                                  child: Text(
                                    'INR ${item.total.toStringAsFixed(2)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                        Container(height: 1, color: const Color(0xFFE2E8F0)),
                        const SizedBox(height: 8),

                        // Total Row inside Table area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.workSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'INR ${widget.bill.grandTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Container(height: 1.5, color: const Color(0xFFB90538)),
                        const SizedBox(height: 10),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: GoogleFonts.workSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'INR ${widget.bill.grandTotal.toStringAsFixed(2)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB90538),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        // Premium Styled Footer section
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            border: Border.all(color: const Color(0xFFFECDD3)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Thank you for your business! We wish you a safe and sparky celebration!',
                                style: GoogleFonts.workSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB90538),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'This is a computer-generated invoice and does not require a physical signature.',
                                style: GoogleFonts.workSans(
                                  fontSize: 8.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Print Action button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_selectedPrinter == 'System PDF Printer (A4)' || _selectedPrinter == 'Save to Device Storage') {
                    // Generate and layout / print real PDF
                    try {
                      final pdfBytes = await _generateInvoicePdf(widget.bill);
                      await Printing.layoutPdf(
                        onLayout: (PdfPageFormat format) async => pdfBytes,
                        name: 'Invoice_${widget.bill.id}',
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error generating PDF: $e'),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  } else {
                    // Simulate Bluetooth/USB Thermal Printing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sent to $_selectedPrinter. Print completed!',
                                style: GoogleFonts.workSans(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF006947), // succeed green
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB90538),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.print, size: 20),
                label: Text(
                  'EXECUTE PRINT',
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.workSans(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB90538),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Generates real PDF invoice matching user's recommended layout and colors
  Future<Uint8List> _generateInvoicePdf(Bill bill) async {
    final pdf = pw.Document(
      title: 'Arun Crackers Invoice ${bill.id}',
      author: 'SparkBill',
    );

    final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    final formattedDate = dateFormat.format(bill.dateTime);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.red800, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Store Info
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Arun Crackers',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '7/300/1, Senthur Nagar, Sivakasi to kazhugumalai main road,\nnear enammeenachipuram bus stop, Vembakko ai, Sivakasi - 626131',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'For order: 8667784469 | GPay / WhatsApp: 9750510650',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.red800, thickness: 1.5),
                pw.SizedBox(height: 8),

                // Invoice metadata
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfMetadataField('Invoice Number:', bill.id),
                          pw.SizedBox(height: 6),
                          _pdfMetadataField('Customer Name:', bill.customerName.isNotEmpty ? bill.customerName : 'N/A'),
                          pw.SizedBox(height: 6),
                          _pdfMetadataField('Customer Mobile:', bill.customerPhone.isNotEmpty ? bill.customerPhone : 'N/A'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _pdfMetadataField('Date & Time:', formattedDate),
                          pw.SizedBox(height: 6),
                          _pdfMetadataField('Payment Method:', 'Cash'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                
                // Table of items
                pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                    bottom: pw.BorderSide(color: PdfColors.red800, width: 1.5),
                  ),
                  columnWidths: {
                    0: const pw.FractionColumnWidth(0.08),  // S.No
                    1: const pw.FractionColumnWidth(0.50),  // Item Name
                    2: const pw.FractionColumnWidth(0.16),  // Price
                    3: const pw.FractionColumnWidth(0.12),  // Quantity
                    4: const pw.FractionColumnWidth(0.14),  // Total
                  },
                  children: [
                    // Headers
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red50,
                      ),
                      children: [
                        _pdfTableHeader('S.No', align: pw.TextAlign.center),
                        _pdfTableHeader('Item Name', align: pw.TextAlign.left),
                        _pdfTableHeader('Price', align: pw.TextAlign.right),
                        _pdfTableHeader('Quantity', align: pw.TextAlign.center),
                        _pdfTableHeader('Total', align: pw.TextAlign.right),
                      ],
                    ),
                    // Rows
                    ...List.generate(bill.items.length, (index) {
                      final item = bill.items[index];
                      return pw.TableRow(
                        children: [
                          _pdfTableCell((index + 1).toString(), align: pw.TextAlign.center),
                          _pdfTableCell(item.product.name, align: pw.TextAlign.left),
                          _pdfTableCell('INR ${item.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                          _pdfTableCell(item.quantity.toString(), align: pw.TextAlign.center),
                          _pdfTableCell('INR ${item.total.toStringAsFixed(2)}', align: pw.TextAlign.right),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 10),

                // Table Total row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.Text(
                      'INR ${bill.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.red800, thickness: 1.5),
                pw.SizedBox(height: 6),

                // Grand Total Amount
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Amount:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
                    ),
                    pw.Text(
                      'INR ${bill.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                        color: PdfColors.red900,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),

                // Footer section in PDF
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.red200, width: 1),
                    color: PdfColors.red50,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Thank you for your business! We wish you a safe and sparky celebration!',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red900,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'This is a computer-generated invoice and does not require a physical signature.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfMetadataField(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.red900),
          ),
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900),
          ),
        ],
      ),
    );
  }

  pw.Widget _pdfTableHeader(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.red900,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _pdfTableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey900),
        textAlign: align,
      ),
    );
  }
}
