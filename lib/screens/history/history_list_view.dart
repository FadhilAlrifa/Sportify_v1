// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../models/order.dart';
// import 'detail_order_page.dart'; // Pastikan path ke DetailOrderPage benar

// typedef StatusColorGetter = Color Function(String status);
// typedef PayNowCallback = void Function(OrderHistory order);

// class HistoryListView extends StatelessWidget {
//   final List<OrderHistory> historyList;
//   final StatusColorGetter statusColor;
//   final PayNowCallback onPayNow;
//   final String currentStatus; // Status yang sedang ditampilkan (Pending, Belum Dibayar, Selesai)

//   const HistoryListView({
//     super.key,
//     required this.historyList,
//     required this.statusColor,
//     required this.onPayNow,
//     required this.currentStatus,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (historyList.isEmpty) {
//       return Center(
//         child: Text(
//           "Tidak ada riwayat untuk status '$currentStatus'.",
//           style: TextStyle(color: Colors.grey[600]),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       itemCount: historyList.length,
//       itemBuilder: (ctx, i) => _historyCard(context, historyList[i]),
//     );
//   }

//   // UI CARD
//   Widget _historyCard(BuildContext context, OrderHistory item) {
//     final color = statusColor(item.status);
//     final priceFormatter = NumberFormat.currency(
//         locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
//     final formattedPrice = priceFormatter.format(item.price);

//     // Logika Status yang Sederhana
//     final isPendingPayment = currentStatus == 'Belum Dibayar';
//     final isPendingAdmin = currentStatus == 'Pending';


//     return GestureDetector(
//       // Hanya non-payment cards yang bisa langsung ke Detail via onTap card
//       onTap: isPendingPayment ? null : () => Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DetailOrderPage(order: item)),
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 6),
//             )
//           ],
//         ),
//         child: Column(
//           children: [
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
//               child: _buildImage(item.imageUrl),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(item.courtName,
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
//                             const SizedBox(width: 6),
//                             Text(item.date, style: TextStyle(color: Colors.grey[700])),
//                             const SizedBox(width: 12),
//                             const Icon(Icons.access_time, size: 14, color: Colors.grey),
//                             const SizedBox(width: 6),
//                             Text(item.time, style: TextStyle(color: Colors.grey[700])),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Bagian Kanan (Aksi & Status)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       // LOGIKA 1: BELUM DIBAYAR (TAMPILKAN HARGA & TOMBOL BAYAR)
//                       if (isPendingPayment) ...[
//                         const Text('Total Bayar:', style: TextStyle(fontSize: 12, color: Colors.black54)),
//                         Text(formattedPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
//                         const SizedBox(height: 8),

//                         ElevatedButton(
//                           onPressed: () => onPayNow(item),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade700,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                             minimumSize: Size.zero,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: const Text('Bayar Sekarang', style: TextStyle(fontSize: 12)),
//                         ),
//                       ]
//                       // LOGIKA 2: PENDING (HANYA MENUNGGU KONFIRMASI)
//                       else if (isPendingAdmin) ...[
//                         _buildStatusChip(item.status, color),
//                         const SizedBox(height: 6),
//                         Text('Menunggu Konfirmasi', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//                         const SizedBox(height: 6),
//                       ]
//                       // LOGIKA 3: SELESAI (TAMPILKAN STATUS & TOMBOL DETAIL)
//                       else ...[
//                         _buildStatusChip(item.status, color),
//                         const SizedBox(height: 6),
//                         TextButton(
//                           onPressed: () => Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (_) => DetailOrderPage(order: item)),
//                           ),
//                           child: const Text('Detail'),
//                         ),
//                       ]
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper untuk Status Chip
//   Widget _buildStatusChip(String status, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(status,
//           style: TextStyle(color: color, fontWeight: FontWeight.bold)),
//     );
//   }

//   // Helper untuk Gambar
//   Widget _buildImage(String url) {
//     if (url.startsWith('http')) {
//       return Image.network(
//         url,
//         height: 140,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         errorBuilder: (_, __, ___) => Container(
//           height: 140,
//           color: Colors.grey[300],
//           alignment: Alignment.center,
//           child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
//         ),
//       );
//     } else {
//       return Image.asset(url, height: 140, width: double.infinity, fit: BoxFit.cover);
//     }
//   }
// }