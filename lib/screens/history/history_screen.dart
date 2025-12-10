import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'detail_order_page.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = "all";
  
  final DateFormat _dateFormatter = DateFormat('d MMM yyyy'); 
  final DateFormat _df = DateFormat.yMMMd(); 

  // Helper untuk parsing tanggal (tetap)
  DateTime _parseDate(String s) {
    try {
      return _dateFormatter.parse(s); 
    } catch (_) {
      try {
        return _df.parse(s); 
      } catch (_) {
        return DateTime.now(); 
      }
    }
  }

  // FILTER WAKTU (tetap)
  List<OrderHistory> get filteredHistory {
    final now = DateTime.now();
    List<OrderHistory> baseList = dummyHistory.reversed.toList(); 

    return baseList.where((item) {
      final d = _parseDate(item.date);
      
      final dateOnly = DateTime(d.year, d.month, d.day);
      final nowOnly = DateTime(now.year, now.month, now.day);
      
      switch (filter) {
        case 'today':
          return dateOnly.isAtSameMomentAs(nowOnly); 
        case 'week':
          final startOfWeek = nowOnly.subtract(Duration(days: nowOnly.weekday - 1));
          return dateOnly.isAfter(startOfWeek.subtract(const Duration(days: 1))) && dateOnly.isBefore(nowOnly.add(const Duration(days: 1)));
        case 'month':
          return d.year == now.year && d.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // Fungsi penentu warna status (tetap)
  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('selesai') || st.contains('complete')) return Colors.green;
    if (st.contains('pending')) return Colors.orange;
    if (st.contains('cancel')) return Colors.red;
    if (st.contains('belum dibayar')) return Colors.red.shade700;
    return Colors.grey;
  }
  
  // UI CARD
  Widget _historyCard(BuildContext context, OrderHistory item) {
    final statusColor = _statusColor(item.status);
    final priceFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final formattedPrice = priceFormatter.format(item.price);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailOrderPage(order: item)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14), // Langsung ke Padding utama, tidak ada ClipRRect dan Image
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAMA LAPANGAN (Tetap)
                    Text(item.courtName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10), // Tambah jarak karena tidak ada gambar di atas
                    // WAKTU & TANGGAL (Tetap)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(item.date, style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(item.time, style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ],
                ),
              ),

              // Bagian Kanan (Harga, Status, Detail)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold)), 
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(item.status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailOrderPage(order: item)),
                    ),
                    child: const Text('Detail'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildImage (tidak dipanggil di _historyCard, tapi tetap dipertahankan
  // jika sewaktu-waktu dibutuhkan atau dipanggil di tempat lain)
  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    } else {
      return Image.asset(url, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildImageFallback());
    }
  }

  Widget _buildImageFallback() {
    return Container(
      height: 140,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  // UI CHIP FILTER (tetap)
  Widget _filterChip(String label, String value) {
    final sel = filter == value;
    final primaryColor = Colors.green.shade700;
    
    return InkWell(
      onTap: () => setState(() => filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? primaryColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? primaryColor : Colors.grey.shade200,
          ),
          boxShadow: [
            if (!sel) BoxShadow(color: Colors.black12.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]
        ),
        child: Row(
          children: [
            if (sel) Icon(Icons.check, size: 16, color: primaryColor),
            if (sel) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: sel ? primaryColor : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.6,
      ),

      body: Column(
        children: [
          // FILTER WAKTU 
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _filterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _filterChip('Hari ini', 'today'),
                const SizedBox(width: 8),
                _filterChip('Minggu ini', 'week'),
                const SizedBox(width: 8),
                _filterChip('Bulan ini', 'month'),
                // Tambahkan Tahun ini jika perlu
              ],
            ),
          ),

          // LIST HISTORY
          Expanded(
            child: filteredHistory.isEmpty
                ? Center(
                    child: Text(
                      "Tidak ada riwayat",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredHistory.length,
                    itemBuilder: (ctx, i) =>
                        _historyCard(context, filteredHistory[i]),
                  ),
          ),
        ],
      ),
    );
  }
}