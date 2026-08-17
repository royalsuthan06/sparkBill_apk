import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _billGenerated = false;
  Uint8List? _generatedPdfBytes;

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
              color: const Color(0xFFF43F5E), // Elegant Brand Red
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isReprint ? 'REPRINT RECEIPT' : 'BILL CONFIRMED',
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

            // Receipt Paper Preview with Brand Identity Border
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFF43F5E), width: 2), // Brand red border
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
                                  color: const Color(0xFFF43F5E), // Brand Red
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
                        Container(height: 1, color: const Color(0xFFF43F5E).withOpacity(0.5)),
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
                        Container(height: 1, color: const Color(0xFFF43F5E).withOpacity(0.5)),
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
                                  color: const Color(0xFFF43F5E),
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
                                  color: const Color(0xFFF43F5E),
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
                                  color: const Color(0xFFF43F5E),
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
                                  color: const Color(0xFFF43F5E),
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
                                  color: const Color(0xFFF43F5E),
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
                        Container(height: 1.5, color: const Color(0xFFF43F5E)),
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
                                color: const Color(0xFFF43F5E),
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
                                  color: const Color(0xFFF43F5E),
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

            // Generate Bill + Share Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Generate Bill button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final pdfBytes = await _generateInvoicePdf(widget.bill);
                          _generatedPdfBytes = pdfBytes;
                          if (mounted) {
                            setState(() {
                              _billGenerated = true;
                            });
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error generating PDF: $e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF43F5E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.receipt_long, size: 20),
                      label: Text(
                        'GENERATE BILL',
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Share row - visible only after bill is generated
                  if (_billGenerated) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // WhatsApp
                        _shareIcon(
                          icon: Icons.chat,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () => _shareViaWhatsApp(),
                        ),
                        const SizedBox(width: 16),
                        // Email
                        _shareIcon(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: const Color(0xFF1A73E8),
                          onTap: () => _shareViaEmail(),
                        ),
                        const SizedBox(width: 16),
                        // Print
                        _shareIcon(
                          icon: Icons.print,
                          label: 'Print',
                          color: const Color(0xFF64748B),
                          onTap: () => _printBill(),
                        ),
                      ],
                    ),
                  ],
                ],
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
            color: const Color(0xFFF43F5E),
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

  Widget _shareIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.workSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_generatedPdfBytes == null) return;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Invoice_${widget.bill.id}.pdf');
    await file.writeAsBytes(_generatedPdfBytes!);
    await Share.shareXFiles([XFile(file.path)], text: 'Invoice ${widget.bill.id}');
  }

  Future<void> _shareViaEmail() async {
    if (_generatedPdfBytes == null) return;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Invoice_${widget.bill.id}.pdf');
    await file.writeAsBytes(_generatedPdfBytes!);
    final uri = Uri(
      scheme: 'mailto',
      query: 'subject=Invoice ${widget.bill.id}&body=Please find attached the invoice for your order.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _printBill() async {
    if (_generatedPdfBytes == null) return;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => _generatedPdfBytes!,
      name: 'Invoice_${widget.bill.id}',
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
