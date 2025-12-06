import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final dynamic courtId;
  final DateTime date;
  final String time;
  final int duration;
  final double totalCost;

  const PaymentSummaryWidget({
    super.key,
    required this.courtId,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalCost,
  });

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row("Lapangan", courtId.toString()),
          _row("Tanggal", DateFormat('dd MMM yyyy').format(date)),
          _row("Jam Mulai", time),
          _row("Durasi", "$duration Jam"),
          const Divider(),
          _row(
            "Total Pembayaran",
            "Rp ${NumberFormat('#,##0', 'id_ID').format(totalCost)}",
            bold: true,
          ),
        ],
      ),
    );
  }
}
