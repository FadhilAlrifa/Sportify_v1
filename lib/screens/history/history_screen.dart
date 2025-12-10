import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../history/detail_order_page.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String filter = "all";

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('complete')) return Colors.green;
    if (st.contains('cancel')) return Colors.red;
    if (st.contains('pending')) return Colors.orange;
    return Colors.grey;
  }

  List<OrderHistory> applyFilter(List<OrderHistory> list) {
    final now = DateTime.now();

    return list.where((item) {
      final d = item.date;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Riwayat Pemesanan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.6,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Tidak ada riwayat',
                        style: TextStyle(color: Colors.grey[600])),
                  );
                }

                final data = snap.data!.docs.map((e) {
                  return OrderHistory.fromFirestore(
                    e.data() as Map<String, dynamic>,
                    e.id,
                  );
                }).toList();

                final filtered = applyFilter(data);

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _historyCard(context, filtered[i]),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _chip('Semua', 'all'),
          const SizedBox(width: 8),
          _chip('Hari ini', 'today'),
          const SizedBox(width: 8),
          _chip('Minggu ini', 'week'),
          const SizedBox(width: 8),
          _chip('Bulan ini', 'month'),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
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
              color: sel ? const Color(0xFF00C853) : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            if (sel)
              const Icon(Icons.check, size: 16, color: Color(0xFF00C853)),
            if (sel) const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  color: sel ? const Color(0xFF00C853) : Colors.black87,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(BuildContext context, OrderHistory item) {
    final statusColor = _statusColor(item.status);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
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
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.asset(
                item.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('d/MM/yyyy').format(item.date),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(item.time),
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rp ${item.price}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.status,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold)),
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
}
