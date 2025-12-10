import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../history/detail_order_page.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {

  String filter = "all";
  late TabController _tabController;
  // final DateFormat _df = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // FILTER WAKTU
  List<OrderHistory> get filteredTimeHistory {
    final now = DateTime.now();
    return dummyHistory.where((item) {
      final d = _parseDate(item.date);
      switch (filter) {
        case 'today':
          return d.year == now.year && d.month == now.month && d.day == now.day;
        case 'week':
          final diff = now.difference(d).inDays;
          return diff >= 0 && diff < 7;
        case 'month':
          return d.year == now.year && d.month == now.month;
        default:
          return true;
      }
    }).toList();
  }

  // FILTER STATUS (Pending / Selesai)
  List<OrderHistory> get filteredHistory {
    final selected = _tabController.index == 0 ? "pending" : "selesai";
    return filteredTimeHistory
        .where((x) => x.status.toLowerCase() == selected)
        .toList()
        .reversed
        .toList();
  }

  DateTime _parseDate(String s) {
    try {
      return DateFormat('d MMM yyyy').parse(s);
    } catch (_) {
      try {
        return DateTime.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('selesai') || st.contains('complete')) return Colors.green;
    if (st.contains('pending')) return Colors.orange;
    if (st.contains('cancel')) return Colors.red;
    return Colors.grey;
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          onTap: (_) => setState(() {}), // update status filter
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Selesai"),
          ],
        ),
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

  // UI CHIP FILTER
  Widget _filterChip(String label, String value) {
    final sel = filter == value;
    return InkWell(
      onTap: () => setState(() => filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF00C853).withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? const Color(0xFF00C853) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            if (sel) const Icon(Icons.check, size: 16, color: Color(0xFF00C853)),
            if (sel) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: sel ? const Color(0xFF00C853) : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI CARD
  Widget _historyCard(BuildContext context, OrderHistory item) {
    final statusColor = _statusColor(item.status);

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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: _buildImage(item.imageUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.courtName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rp ${item.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: 140,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 140,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      );
    } else {
      return Image.asset(url, height: 140, width: double.infinity, fit: BoxFit.cover);
    }
  }
}
