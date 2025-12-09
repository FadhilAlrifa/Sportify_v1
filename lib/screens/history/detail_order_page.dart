import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

class DetailOrderPage extends StatelessWidget {
  final OrderHistory order;
  const DetailOrderPage({super.key, required this.order});

  Future<void> downloadPdf() async {
    final pdf = pw.Document();
    final df = DateFormat.yMMMd();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Sportify — Invoice", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Nama Lapangan: ${order.courtName}"),
            pw.Text("Tanggal: ${order.date}"),
            pw.Text("Waktu: ${order.time}"),
            pw.Text("Harga: Rp ${order.price}"),
            pw.Text("Status: ${order.status}"),
            pw.SizedBox(height: 16),
            pw.Text("Generated: ${df.format(DateTime.now())}", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('complete')) return Colors.green;
    if (st.contains('cancel')) return Colors.red;
    if (st.contains('pending')) return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.6,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // hero image with bottom curve
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: order.imageUrl.startsWith('http')
                      ? Image.network(order.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _imageFallback())
                      : Image.asset(order.imageUrl, fit: BoxFit.cover),
                ),
                // gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.black26, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                  ),
                ),
                // rounded bottom white block
                Positioned(
                  bottom: -20,
                  left: 0,
                  right: 0,
                  child: Container(height: 40, decoration: const BoxDecoration(color: Colors.transparent)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(order.courtName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),

            const SizedBox(height: 18),

            // info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))]),
                child: Column(
                  children: [
                    _rowItem(Icons.calendar_today, 'Tanggal', order.date),
                    const Divider(height: 22),
                    _rowItem(Icons.access_time, 'Waktu', order.time),
                    const Divider(height: 22),
                    _rowItem(Icons.payments, 'Harga', 'Rp ${order.price}', isBold: true),
                    const Divider(height: 22),
                    Row(
                      children: [
                        Icon(Icons.info, color: statusColor),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Status', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                            child: Text(order.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                          )
                        ])
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => downloadPdf(),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 64, color: Colors.white70),
    );
  }

  Widget _rowItem(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: Colors.green, size: 26),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    ]);
  }
}
