import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import '../../models/order.dart';

class DetailOrderPage extends StatelessWidget {
  final OrderHistory order;
  const DetailOrderPage({super.key, required this.order});

  Future<void> downloadPdf() async {
    final pdf = pw.Document();
    final df = DateFormat.yMMMd();
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );
    final formattedTotal = priceFormatter.format(order.totalCost);
    final formattedPrice = priceFormatter.format(order.basePrice);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Sportify — Invoice",
                  style: pw.TextStyle(
                    fontSize: 20, 
                    fontWeight: pw.FontWeight.bold
                  ),
                ),
                pw.Text(
                  "ID: ${order.id.substring(0, 8)}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
            
            pw.Divider(),
            pw.SizedBox(height: 15),
            
            // Informasi Lapangan
            pw.Text(
              "Lapangan: ${order.courtName}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Tanggal: ${order.formattedDate}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Waktu: ${order.time} (${order.duration} jam)",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Metode Pembayaran: ${order.paymentMethod}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              "Status: ${order.status.toUpperCase()}",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            
            pw.SizedBox(height: 15),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            // Detail Harga
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Harga per jam:", style: pw.TextStyle(fontSize: 12)),
                pw.Text(formattedPrice, style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Durasi:", style: pw.TextStyle(fontSize: 12)),
                pw.Text("${order.duration} jam", style: pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 5),
            
            // Total
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "TOTAL:",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formattedTotal,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            // Footer
            pw.Text(
              "Generated: ${df.format(DateTime.now())}",
              style: pw.TextStyle(
                fontSize: 10, 
                color: PdfColors.grey700
              ),
            ),
            pw.Text(
              "Sportify - Booking Lapangan Olahraga",
              style: pw.TextStyle(
                fontSize: 10, 
                color: PdfColors.grey700
              ),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? iconColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF00B47A)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF00B47A),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ));
  }

  // WIDGET untuk tombol aksi berdasarkan status - HILANGKAN DIBATALKAN
  Widget _buildActionButton(BuildContext context) {
    final statusLower = order.status.toLowerCase();
    final isPending = statusLower.contains('pending') || 
                     statusLower.contains('menunggu');
    final isCompleted = statusLower.contains('selesai') || 
                       statusLower.contains('completed') || 
                       statusLower.contains('confirmed');

    if (isPending) {
      // Status Pending
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pesanan sedang diproses. Menunggu konfirmasi dari Admin.',
                  style: TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isCompleted) {
      // Status Selesai - Tampilkan tombol download PDF
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pesanan telah selesai dan dikonfirmasi.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => downloadPdf(),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'Download Invoice PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default/Status lainnya (termasuk dibatalkan) - tidak tampilkan apa-apa
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID', 
      symbol: 'Rp ', 
      decimalDigits: 0
    );
    final formattedTotal = priceFormatter.format(order.totalCost);
    final formattedPrice = priceFormatter.format(order.basePrice);

    // Tentukan warna status - HILANGKAN MERAH UNTUK DIBATALKAN
    final statusLower = order.status.toLowerCase();
    Color statusColor;
    IconData statusIcon;
    String displayStatus;
    
    if (statusLower.contains('selesai') || statusLower.contains('completed')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      displayStatus = 'SELESAI';
    } else if (statusLower.contains('pending') || statusLower.contains('menunggu')) {
      statusColor = Colors.orange;
      statusIcon = Icons.access_time;
      displayStatus = 'PENDING';
    } else {
      // Untuk status lain (dibatalkan), gunakan warna abu-abu
      statusColor = Colors.grey;
      statusIcon = Icons.info;
      displayStatus = order.status.toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0.6,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header dengan ID pesanan
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    order.courtName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID Pesanan: ${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card Informasi Pesanan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status dengan warna - HILANGKAN MERAH
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displayStatus,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Detail informasi
                    _buildDetailRow(
                      Icons.sports_soccer,
                      'Lapangan',
                      order.courtName,
                      iconColor: const Color(0xFF00B47A),
                    ),
                    
                    Divider(color: Colors.grey.shade200),

                    _buildDetailRow(
                      Icons.calendar_today,
                      'Tanggal',
                      order.formattedDate,
                      iconColor: Colors.blue,
                    ),
                    
                    Divider(color: Colors.grey.shade200),

                    _buildDetailRow(
                      Icons.access_time,
                      'Waktu',
                      '${order.time} (${order.duration} jam)',
                      iconColor: Colors.green,
                    ),
                    
                    Divider(color: Colors.grey.shade200),

                    _buildDetailRow(
                      Icons.payment,
                      'Metode Pembayaran',
                      order.paymentMethod,
                      iconColor: Colors.purple,
                    ),
                    
                    Divider(color: Colors.grey.shade200),

                    // Detail harga
                    Row(
                      children: [
                        const Icon(
                          Icons.money,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detail Harga',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$formattedPrice/jam × ${order.duration} jam',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total: $formattedTotal',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF00B47A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol aksi berdasarkan status
            _buildActionButton(context),

            const SizedBox(height: 32),

            // Info tambahan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Untuk pertanyaan atau perubahan pesanan, hubungi customer service kami.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}